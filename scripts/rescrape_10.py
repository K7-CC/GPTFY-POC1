"""Re-scrape first 10 Power PDF articles with solution-only extraction and rewrite CSV."""
import csv
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from scripts.scrape_tungsten_kb import (
    PRODUCT_CONFIG,
    dedupe_rows,
    extract_article,
    wait_for_search_results,
    collect_search_result_links,
    with_page_param,
    BASE_URL,
    write_csv,
    REQUEST_DELAY_SEC,
)
from playwright.sync_api import sync_playwright
from urllib.parse import urljoin

N = 10
cfg = PRODUCT_CONFIG["powerpdf"]

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # Collect first 50 links (page 1) — enough for 10 articles
    url = with_page_param(cfg["entry_url"], 1)
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    wait_for_search_results(page)
    links = collect_search_result_links(page)[:N]
    print(f"Got {len(links)} links")

    rows = []
    for idx, (title, article_url) in enumerate(links, 1):
        try:
            qa = extract_article(page, article_url, fallback_title=title)
            if qa:
                rows.append(qa)
                print(f"  [{idx}] OK: {qa.question[:70]}")
                print(f"       ANS: {qa.answer[:150]}")
            else:
                print(f"  [{idx}] SKIP: {article_url}")
        except Exception as e:
            print(f"  [{idx}] ERROR: {e}")
        time.sleep(REQUEST_DELAY_SEC)

    browser.close()

# Overwrite the powerpdf-faq-kb.csv first 10 rows with clean data
# (preserve remaining rows from old CSV)
full_csv = ROOT / "data" / "powerpdf-faq-kb.csv"
old_rows = list(csv.DictReader(full_csv.open(encoding="utf-8-sig")))[N:]  # rows 11+

all_rows = dedupe_rows(rows)
write_csv(all_rows, ROOT / "data" / "powerpdf-preview-10.csv")
print(f"\nPreview CSV written: {len(all_rows)} rows")
