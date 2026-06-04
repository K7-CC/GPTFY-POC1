"""Debug pagination on Tungsten KB search."""
from playwright.sync_api import sync_playwright

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
    page.wait_for_timeout(5000)

    links = page.locator("h2 a").all()
    print(f"h2 a count: {len(links)}")
    for a in links[:5]:
        print(a.inner_text(), "->", a.get_attribute("href"))

    # pagination elements
    pag = page.locator("[class*='pag'], nav, button, a").all()
    for el in pag:
        try:
            txt = (el.inner_text() or "").strip()
            aria = el.get_attribute("aria-label") or ""
            href = el.get_attribute("href") or ""
            if any(k in (txt + aria).lower() for k in ["next", "page", "2", "previous", "prev"]):
                print(f"PAG: text={txt!r} aria={aria!r} href={href!r}")
        except Exception:
            pass

    browser.close()
