"""Debug Tungsten KB search page structure."""
from playwright.sync_api import sync_playwright
import json

URL = (
    "https://knowledge.tungstenautomation.com/search"
    "?groupByPub=false"
    "&labelkey=power_pdf"
    "&labelkey=power_pdf_advanced"
    "&labelkey=power_pdf_advanced_volume"
    "&labelkey=power_pdf_for_mac"
    "&rpp=50"
    "&sort.field=score"
    "&sort.value=desc"
)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto(URL, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(8000)

    print("Title:", page.title())
    print("Body snippet:", page.inner_text("body")[:800])
    print()

    selectors = [
        "a",
        "h2 a",
        "h3 a",
        ".search-result a",
        ".result a",
        "li a",
        "a[href*='page']",
        "a[href*='bundle']",
    ]
    for sel in selectors:
        count = page.locator(sel).count()
        print(f"{sel}: {count}")

    print("\nSAMPLE LINKS:")
    links = page.eval_on_selector_all(
        "a[href]",
        "els => els.map(e => ({text: (e.innerText||'').trim().slice(0,100), href: e.href}))"
        ".filter(l => l.href.includes('tungsten') && l.text.length > 3)"
        ".slice(0, 40)",
    )
    for link in links:
        print(json.dumps(link))

    browser.close()
