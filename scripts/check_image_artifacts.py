"""Check all 10 Power PDF KB articles for image artifacts in Resolution__c."""
import re
import subprocess
import json

IDS = [
    "ka0dN000000RqiTQAS", "ka0dN000000RqiUQAS", "ka0dN000000RqiVQAS",
    "ka0dN000000RqiWQAS", "ka0dN000000RqiXQAS", "ka0dN000000RqiYQAS",
    "ka0dN000000RqiZQAS", "ka0dN000000RqiaQAC", "ka0dN000000RqibQAC",
    "ka0dN000000RqicQAC",
]
ids_str = "','".join(IDS)
query = f"SELECT Title, Resolution__c FROM Knowledge__kav WHERE Id IN ('{ids_str}')"

result = subprocess.run(
    ["sf", "data", "query", "--query", query, "--target-org", "gptfy-poc1", "--result-format", "json"],
    capture_output=True, text=True
)
data = json.loads(result.stdout)
records = data.get("result", {}).get("records", [])

img_pattern = re.compile(
    r'\S+\.(png|jpg|jpeg|gif|svg|webp|bmp)\b'
    r'|\[image\]'
    r'|alt text'
    r'|\bà\b'       # common encoding artifact from arrows/images
    r'|\ufffd',     # unicode replacement char
    re.IGNORECASE
)

any_found = False
for r in records:
    title = r.get("Title", "")
    text = r.get("Resolution__c", "") or ""
    hits = img_pattern.findall(text)
    artifacts = [m for m in re.findall(r'[^\x09\x0a\x0d\x20-\x7e\x80-\xff]', text)]
    print(f"Title: {title[:70]}")
    print(f"  Image artifacts: {hits if hits else 'NONE'}")
    print(f"  Non-printable chars: {list(set(artifacts))[:5] if artifacts else 'NONE'}")
    # Show any lines containing arrows or odd chars
    odd_lines = [ln.strip() for ln in text.split("\n") if re.search(r'[^\x09\x0a\x0d\x20-\x7e]', ln)]
    if odd_lines:
        print(f"  Odd lines: {odd_lines[:3]}")
    print()
    if hits or artifacts:
        any_found = True

if not any_found:
    print("=== All 10 articles: No image artifacts or non-printable characters found ===")
