"""
Batch-import Power PDF KB articles into Salesforce Knowledge (Draft).

Steps:
  1. Post-process existing powerpdf-faq-kb.csv (342 rows) with solution-only extraction
  2. Scrape missing articles 343-431 fresh
  3. Skip articles 1-10 (already inserted)
  4. Insert articles 11-431 in batches of 50 via Apex
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from scripts.scrape_tungsten_kb import (
    PRODUCT_CONFIG,
    ArticleQA,
    collect_search_result_links,
    dedupe_rows,
    extract_article,
    extract_solution_only,
    wait_for_search_results,
    with_page_param,
    write_csv,
    REQUEST_DELAY_SEC,
)
from playwright.sync_api import sync_playwright

FULL_CSV = ROOT / "data" / "powerpdf-faq-kb.csv"
BATCH_DIR = ROOT / "scripts" / "apex" / "batches"
BATCH_SIZE = 50
SKIP_FIRST = 10          # articles 1-10 already in org
TOTAL_TARGET = 431


def make_url_name(title: str, idx: int) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", title)[:80].strip("-").lower()
    return f"{slug}-ppdf-{idx}"


def apex_escape(s: str) -> str:
    return (
        s.replace("\\", "\\\\")
         .replace("'", "\\'")
         .replace("\n", "\\n")
         .replace("\r", "")
    )


def post_process_existing_rows(rows: list[dict]) -> list[ArticleQA]:
    """Apply solution-only extraction to already-scraped full-body rows."""
    result = []
    for row in rows:
        q = row.get("Question", row.get("question", "")).strip()
        a = row.get("Answer", row.get("answer", "")).strip()
        url = row.get("Source_URL", row.get("source_url", "")).strip()
        ct = row.get("Content_Type", row.get("content_type", "KB_Article")).strip()
        clean_a = extract_solution_only(a)
        if q and len(clean_a) >= 20:
            result.append(ArticleQA(question=q, answer=clean_a, source_url=url, content_type=ct))
    return result


def scrape_missing(existing_count: int, target: int) -> list[ArticleQA]:
    """Scrape articles from existing_count+1 through target."""
    cfg = PRODUCT_CONFIG["powerpdf"]
    entry_url = cfg["entry_url"]

    # Work out which search pages cover the missing articles
    # rpp=50, so article N is on page ceil(N/50)
    start_page = (existing_count // 50) + 1
    print(f"\nScraping missing articles {existing_count + 1}-{target} from search page {start_page}+")

    rows: list[ArticleQA] = []
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        seen_urls: set[str] = set()
        article_links: list[tuple[str, str]] = []

        pg_num = start_page
        while len(article_links) + existing_count < target and pg_num <= 200:
            pg_url = with_page_param(entry_url, pg_num)
            page.goto(pg_url, wait_until="domcontentloaded", timeout=60000)
            wait_for_search_results(page)
            batch = collect_search_result_links(page)
            if not batch:
                break
            for title, url in batch:
                if url not in seen_urls:
                    seen_urls.add(url)
                    article_links.append((title, url))
            print(f"  Search page {pg_num}: {len(batch)} links (total collected: {len(article_links)})")
            pg_num += 1

        print(f"Crawling {len(article_links)} new articles...")
        for idx, (title, url) in enumerate(article_links, start=1):
            try:
                qa = extract_article(page, url, fallback_title=title)
                if qa:
                    rows.append(qa)
                    print(f"  [{idx}/{len(article_links)}] OK: {qa.question[:65]}")
                else:
                    print(f"  [{idx}/{len(article_links)}] SKIP: {url}")
            except Exception as e:
                print(f"  [{idx}/{len(article_links)}] ERROR: {e}")
            time.sleep(REQUEST_DELAY_SEC)

        browser.close()
    return rows


def get_sf_credentials() -> tuple[str, str]:
    """Return (instance_url, access_token) from sf CLI."""
    result = subprocess.run(
        "sf org display --target-org gptfy-poc1 --json",
        capture_output=True, text=True, shell=True
    )
    data = json.loads(result.stdout[result.stdout.index("{"):])
    r = data["result"]
    return r["instanceUrl"], r["accessToken"]


def insert_batch_rest(batch: list[ArticleQA], start_idx: int, batch_num: int) -> bool:
    """Insert a batch of articles via Salesforce REST API (no Apex size limits)."""
    import urllib.request, urllib.error

    instance_url, access_token = get_sf_credentials()
    api_url = f"{instance_url}/services/data/v59.0/sobjects/Knowledge__kav"
    headers_base = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    }

    inserted = 0
    failed = 0
    for i, qa in enumerate(batch):
        global_idx = start_idx + i
        payload = json.dumps({
            "Title": qa.question[:255],
            "UrlName": make_url_name(qa.question, global_idx),
            "Resolution__c": qa.answer[:32000],
            "Language": "en_US",
        }).encode("utf-8")
        req = urllib.request.Request(api_url, data=payload, headers=headers_base, method="POST")
        try:
            with urllib.request.urlopen(req) as resp:
                body = json.loads(resp.read())
                inserted += 1
                if (i + 1) % 10 == 0 or (i + 1) == len(batch):
                    print(f"    [{i + 1}/{len(batch)}] {body.get('id','?')} | {qa.question[:55]}")
        except urllib.error.HTTPError as e:
            err = e.read().decode()
            print(f"    [{i + 1}/{len(batch)}] HTTP {e.code}: {err[:120]}")
            failed += 1
        time.sleep(0.15)

    print(f"  Batch {batch_num}: {inserted} inserted, {failed} failed")
    return failed == 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Generate Apex files only, do not run them")
    args = parser.parse_args()

    # Step 1: Load and post-process existing CSV rows
    print(f"Loading existing CSV: {FULL_CSV}")
    existing_rows_raw = list(csv.DictReader(FULL_CSV.open(encoding="utf-8-sig")))
    print(f"  Found {len(existing_rows_raw)} rows in CSV")

    all_rows = post_process_existing_rows(existing_rows_raw)
    print(f"  After solution-only post-processing: {len(all_rows)} rows")

    # Step 2: Scrape missing articles if needed
    if len(all_rows) < TOTAL_TARGET:
        missing = scrape_missing(len(all_rows), TOTAL_TARGET)
        all_rows.extend(missing)
        # Save updated full CSV
        write_csv(dedupe_rows(all_rows), FULL_CSV)
        print(f"  Full CSV updated: {len(all_rows)} rows")
    else:
        print(f"  CSV already has {len(all_rows)} rows — no re-scrape needed")

    # Step 3: Dedupe and take up to TOTAL_TARGET
    all_rows = dedupe_rows(all_rows)[:TOTAL_TARGET]
    print(f"\nTotal articles to process: {len(all_rows)}")

    # Step 4: Skip first 10, batch insert the rest
    to_insert = all_rows[SKIP_FIRST:]
    print(f"Inserting articles {SKIP_FIRST + 1}-{SKIP_FIRST + len(to_insert)} in batches of {BATCH_SIZE}")

    total_inserted = 0
    batch_num = 1
    for i in range(0, len(to_insert), BATCH_SIZE):
        batch = to_insert[i: i + BATCH_SIZE]
        start_idx = SKIP_FIRST + i + 1
        print(f"\nBatch {batch_num}: articles {start_idx}-{start_idx + len(batch) - 1}")

        if args.dry_run:
            print("  [dry-run] Skipping execution")
        else:
            ok = insert_batch_rest(batch, start_idx, batch_num)
            if ok:
                total_inserted += len(batch)
                print(f"  Running total in org: {total_inserted + SKIP_FIRST}")
            else:
                print(f"  Some failures in batch {batch_num} — continuing to next batch")
        batch_num += 1

    print(f"\n=== Done ===")
    print(f"Total inserted this run: {total_inserted}")
    print(f"Total in org (including first 10): {total_inserted + SKIP_FIRST}")


if __name__ == "__main__":
    main()
