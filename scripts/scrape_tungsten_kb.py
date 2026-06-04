"""Scrape Tungsten Knowledge Portal FAQ/KB articles into CSV files.

Usage:
    python scripts/scrape_tungsten_kb.py --product powerpdf
    python scripts/scrape_tungsten_kb.py --product totalagility
    python scripts/scrape_tungsten_kb.py --product einvoicing
"""

from __future__ import annotations

import argparse
import csv
import html
import re
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import parse_qs, urlencode, urljoin, urlparse, urlunparse

from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"

BASE_URL = "https://knowledge.tungstenautomation.com"

PRODUCT_CONFIG = {
    "powerpdf": {
        "name": "Power PDF",
        "entry_url": (
            "https://knowledge.tungstenautomation.com/search"
            "?groupByPub=false"
            "&labelkey=power_pdf"
            "&labelkey=power_pdf_advanced"
            "&labelkey="
            "&labelkey=power_pdf_advanced_volume"
            "&labelkey=power_pdf_for_mac"
            "&rpp=50"
            "&sort.field=score"
            "&sort.value=desc"
        ),
        "output": DATA_DIR / "powerpdf-faq-kb.csv",
        "mode": "search",
    },
    "totalagility": {
        "name": "TotalAgility",
        "entry_url": (
            "https://knowledge.tungstenautomation.com/search"
            "?labelkey=totalagility"
            "&rpp=50"
            "&sort.field=score"
            "&sort.value=desc"
        ),
        "output": DATA_DIR / "totalagility-faq-kb.csv",
        "mode": "search",
        "max_pages": 2,   # top 100 articles
    },
    "einvoicing": {
        "name": "E-Invoicing",
        "entry_url": (
            "https://knowledge.tungstenautomation.com/search"
            "?labelkey=invoice_portal"
            "&rpp=50"
            "&sort.field=score"
            "&sort.value=desc"
        ),
        "output": DATA_DIR / "einvoicing-faq-kb.csv",
        "mode": "search",
    },
}

REQUEST_DELAY_SEC = 0.35


@dataclass
class ArticleQA:
    question: str
    answer: str
    source_url: str
    content_type: str


def normalize_whitespace(text: str) -> str:
    text = html.unescape(text or "")
    text = text.replace("\xa0", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def strip_html(raw_html: str) -> str:
    soup = BeautifulSoup(raw_html or "", "lxml")
    # Remove all tags that produce no useful text
    for tag in soup(["script", "style", "noscript", "img", "figure",
                     "picture", "svg", "canvas", "video", "audio", "iframe"]):
        tag.decompose()
    text = soup.get_text("\n", strip=True)
    # Drop any leftover image filename references (e.g. something.png)
    text = re.sub(r'\S+\.(png|jpg|jpeg|gif|svg|webp|bmp|tiff?)\b', '', text, flags=re.IGNORECASE)
    # Drop unicode replacement chars and other non-printable characters
    text = re.sub(r'[\ufffd\u00ad]', '', text)
    text = re.sub(r'[^\x09\x0a\x0d\x20-\x7e\x80-\xff]', '', text)
    return normalize_whitespace(text)


def dedupe_rows(rows: list[ArticleQA]) -> list[ArticleQA]:
    seen: dict[str, ArticleQA] = {}
    for row in rows:
        key = re.sub(r"\s+", " ", row.question.lower()).strip()
        if not key:
            continue
        existing = seen.get(key)
        if existing is None or len(row.answer) > len(existing.answer):
            seen[key] = row
    return list(seen.values())


def wait_for_portal(page, timeout_ms: int = 45000) -> None:
    page.wait_for_load_state("domcontentloaded", timeout=timeout_ms)
    try:
        page.wait_for_load_state("networkidle", timeout=10000)
    except PlaywrightTimeout:
        pass
    page.wait_for_timeout(2000)


def wait_for_search_results(page) -> None:
    wait_for_portal(page)
    try:
        page.wait_for_selector("h2 a", timeout=30000)
    except PlaywrightTimeout:
        pass
    page.wait_for_timeout(1000)


def log(msg: str) -> None:
    print(msg, flush=True)


def with_page_param(url: str, page_num: int) -> str:
    parsed = urlparse(url)
    query = parse_qs(parsed.query, keep_blank_values=True)
    if page_num <= 1:
        query.pop("page", None)
    else:
        query["page"] = [str(page_num)]
    flat_query = []
    for key, values in query.items():
        for value in values:
            flat_query.append((key, value))
    new_query = urlencode(flat_query)
    return urlunparse(parsed._replace(query=new_query))


def collect_search_result_links(page) -> list[tuple[str, str]]:
    """Return list of (title, absolute_url) from current search results page."""
    links: list[tuple[str, str]] = []
    seen_urls: set[str] = set()

    for anchor in page.locator("h2 a").all():
        try:
            href = anchor.get_attribute("href") or ""
            if not href or href.startswith("#"):
                continue
            if "/bundle/" not in href or "/page/" not in href:
                continue
            abs_url = urljoin(BASE_URL, href.split("#")[0])
            if abs_url in seen_urls:
                continue
            title = normalize_whitespace(anchor.inner_text())
            if not title or len(title) < 5:
                continue
            seen_urls.add(abs_url)
            links.append((title, abs_url))
        except Exception:
            continue

    return links


def enumerate_search_articles(page, entry_url: str, cfg_override: dict | None = None) -> list[tuple[str, str]]:
    all_links: list[tuple[str, str]] = []
    seen_urls: set[str] = set()

    max_pages = cfg_override.get("max_pages", 200) if cfg_override else 200
    page_num = 1
    while page_num <= max_pages:
        page_url = with_page_param(entry_url, page_num)
        page.goto(page_url, wait_until="domcontentloaded", timeout=60000)
        wait_for_search_results(page)

        batch = collect_search_result_links(page)
        if not batch:
            print(f"  Search page {page_num}: no results, stopping pagination", flush=True)
            break

        new_count = 0
        for title, url in batch:
            if url not in seen_urls:
                seen_urls.add(url)
                all_links.append((title, url))
                new_count += 1

        log(f"  Search page {page_num}: found {len(batch)} links ({new_count} new, {len(all_links)} total)")

        if new_count == 0:
            break
        page_num += 1

    return all_links


def collect_hub_links(page, entry_url: str) -> list[tuple[str, str]]:
    page.goto(entry_url, wait_until="domcontentloaded", timeout=60000)
    wait_for_portal(page)

    links: list[tuple[str, str]] = []
    seen_urls: set[str] = set()

    anchors = page.locator("a[href*='/bundle/'], a[href*='/page/']").all()
    for anchor in anchors:
        try:
            href = anchor.get_attribute("href") or ""
            if not href or href.startswith("#"):
                continue
            abs_url = urljoin(BASE_URL, href.split("#")[0])
            if abs_url == entry_url.split("#")[0]:
                continue
            if "/search" in abs_url or "/pdf/" in abs_url:
                continue
            if abs_url in seen_urls:
                continue
            title = normalize_whitespace(anchor.inner_text())
            if not title or len(title) < 5:
                continue
            seen_urls.add(abs_url)
            links.append((title, abs_url))
        except Exception:
            continue

    log(f"  Hub page: found {len(links)} candidate links")
    return links


def extract_article(page, url: str, fallback_title: str = "") -> ArticleQA | None:
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    wait_for_portal(page)

    html_content = page.content()
    soup = BeautifulSoup(html_content, "lxml")

    for tag in soup(["script", "style", "noscript", "header", "footer", "nav"]):
        tag.decompose()

    title = ""
    for selector in ["h1", "h2.topic-title", ".topic-title", "title"]:
        el = soup.select_one(selector)
        if el and normalize_whitespace(el.get_text()):
            title = normalize_whitespace(el.get_text())
            break
    if not title:
        title = fallback_title

    content_root = (
        soup.select_one("article.kb-articles")
        or soup.select_one("article")
        or soup.select_one(".topic-content")
        or soup.select_one("#topic-content")
    )

    if content_root is None:
        content_root = soup.select_one("#content") or soup.select_one("main")

    if content_root:
        for noisy in content_root.select(
            ".breadcrumb, .toolbar, .share, .print, .save, .related, .feedback, "
            ".zDocsExportItem, .zDocsReusableButton, [class*='share'], "
            "[class*='toolbar'], [class*='breadcrumb'], [class*='Export']"
        ):
            noisy.decompose()

    full_text = strip_html(str(content_root)) if content_root else ""

    if title and full_text.startswith(title):
        full_text = full_text[len(title):].strip()

    full_text = re.sub(r"(?i)^(save pdf|share|print|skip to main content.*?\n)", "", full_text).strip()

    answer = extract_solution_only(full_text)

    if not title or len(answer) < 20:
        return None

    content_type = "FAQ" if "?" in title else "KB_Article"
    return ArticleQA(
        question=title,
        answer=answer,
        source_url=url,
        content_type=content_type,
    )


def extract_solution_only(text: str) -> str:
    """
    From full article body text, return only the solution/answer section.
    Strips ISSUE / PROBLEM / Question preamble sections and trailing REFERENCES / Applies to.
    Falls back to the full text if no known section markers are found.
    """
    # Markers that signal the START of the answer/solution
    answer_starts = [
        r"^SOLUTION\s*\n",
        r"^Resolution:\s*\n",
        r"^RESOLUTION\s*\n",
        r"^Answer:\s*\n",
        r"^Answer\s*\n",
        r"^FIX\s*\n",
        r"^Fix:\s*\n",
        r"^WORKAROUND\s*\n",
        r"^Workaround:\s*\n",
        r"^CAUSE AND RESOLUTION\s*\n",
        r"^Cause and Resolution:\s*\n",
        r"^HOW TO\s*\n",
    ]
    # Markers that signal the END of the answer (trailing noise)
    answer_ends = [
        r"\nREFERENCES\s*\n",
        r"\nReferences:\s*\n",
        r"\nApplies to:\s*\n",
        r"\nAPPLIES TO\s*\n",
        r"\nRelated articles",
        r"\nRELATED ARTICLES",
    ]

    best_start = len(text)
    matched_marker = False
    for pattern in answer_starts:
        m = re.search(pattern, text, re.MULTILINE | re.IGNORECASE)
        if m and m.end() < best_start:
            best_start = m.end()
            matched_marker = True

    if matched_marker:
        answer = text[best_start:]
    else:
        answer = text

    # Cut off trailing noise sections
    for pattern in answer_ends:
        m = re.search(pattern, answer, re.MULTILINE | re.IGNORECASE)
        if m:
            answer = answer[: m.start()]

    return answer.strip()


def write_csv(rows: list[ArticleQA], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=["answer", "question"])
        writer.writeheader()
        for row in rows:
            writer.writerow({"answer": row.answer, "question": row.question})


def scrape_product(product_key: str, headless: bool = True) -> list[ArticleQA]:
    cfg = PRODUCT_CONFIG[product_key]
    log(f"\n=== Scraping {cfg['name']} ===")
    log(f"Entry: {cfg['entry_url']}")
    log(f"Output: {cfg['output']}")

    rows: list[ArticleQA] = []
    skipped: list[str] = []
    cfg["output"].parent.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context(
            user_agent=(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            )
        )
        page = context.new_page()

        if cfg["mode"] == "search":
            article_links = enumerate_search_articles(page, cfg["entry_url"], cfg_override=cfg)
        else:
            article_links = collect_hub_links(page, cfg["entry_url"])

        if not article_links:
            log("WARNING: No article links discovered. Check selectors or portal access.")
            browser.close()
            return []

        log(f"\nCrawling {len(article_links)} articles...")
        for idx, (title, url) in enumerate(article_links, start=1):
            try:
                qa = extract_article(page, url, fallback_title=title)
                if qa:
                    rows.append(qa)
                    if idx % 10 == 0 or idx == len(article_links):
                        log(f"  [{idx}/{len(article_links)}] OK: {qa.question[:70]}...")
                        write_csv(dedupe_rows(rows), cfg["output"])
                else:
                    skipped.append(url)
                    log(f"  [{idx}/{len(article_links)}] SKIP (empty/short): {url}")
            except Exception as exc:
                skipped.append(url)
                log(f"  [{idx}/{len(article_links)}] ERROR: {url} -> {exc}")
            time.sleep(REQUEST_DELAY_SEC)

        browser.close()

    deduped = dedupe_rows(rows)
    write_csv(deduped, cfg["output"])

    log(f"\n=== {cfg['name']} complete ===")
    log(f"Articles crawled: {len(article_links)}")
    log(f"Rows extracted:   {len(rows)}")
    log(f"Rows after dedupe:{len(deduped)}")
    log(f"Skipped/failed:   {len(skipped)}")
    log(f"CSV written to:   {cfg['output']}")

    faq_count = sum(1 for r in deduped if r.content_type == "FAQ")
    kb_count = sum(1 for r in deduped if r.content_type == "KB_Article")
    log(f"FAQ rows:         {faq_count}")
    log(f"KB article rows:  {kb_count}")

    if deduped:
        log("\nSample rows:")
        for sample in deduped[:3]:
            log(f"  Q: {sample.question[:100]}")
            log(f"  A: {sample.answer[:160]}...")
            log(f"  URL: {sample.source_url}\n")

    return deduped


def main() -> int:
    parser = argparse.ArgumentParser(description="Scrape Tungsten KB into CSV")
    parser.add_argument(
        "--product",
        required=True,
        choices=sorted(PRODUCT_CONFIG.keys()),
        help="Product to scrape",
    )
    parser.add_argument(
        "--headed",
        action="store_true",
        help="Run browser in headed mode (for debugging)",
    )
    args = parser.parse_args()

    scrape_product(args.product, headless=not args.headed)
    return 0


if __name__ == "__main__":
    sys.exit(main())
