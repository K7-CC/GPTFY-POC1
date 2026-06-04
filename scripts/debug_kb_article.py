"""Debug single KB article page structure."""
from playwright.sync_api import sync_playwright
from bs4 import BeautifulSoup

URL = "https://knowledge.tungstenautomation.com/bundle/z-kb-articles-salesforce11/page/45172.html"

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto(URL, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(5000)

    html = page.content()
    soup = BeautifulSoup(html, "lxml")

    print("=== Candidate selectors ===")
    for sel in [
        "#content",
        "main",
        ".topic-content",
        "article",
        ".content",
        "[role='main']",
        ".topic-body",
        ".body",
        "#topic-content",
        ".zTopicContent",
    ]:
        el = soup.select_one(sel)
        if el:
            text = el.get_text(" ", strip=True)[:200]
            print(f"{sel}: {len(el.get_text())} chars -> {text[:120]}...")

    print("\n=== All ids in page ===")
    for el in soup.select("[id]")[:30]:
        print(el.name, el.get("id"), len(el.get_text()))

    print("\n=== All classes with topic/content ===")
    for el in soup.select("[class*='topic'], [class*='content'], [class*='article']")[:20]:
        cls = " ".join(el.get("class", []))
        print(el.name, cls[:80], len(el.get_text()))

    browser.close()
