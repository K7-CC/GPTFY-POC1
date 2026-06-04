"""
Read first N rows from powerpdf-faq-kb.csv and:
1. Write a reformatted preview CSV (answer first, question second, lowercase headers)
2. Generate an Apex script to insert them as Draft Knowledge__kav articles
"""
import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_CSV = ROOT / "data" / "powerpdf-faq-kb.csv"
PREVIEW_CSV = ROOT / "data" / "powerpdf-preview-10.csv"
APEX_OUT = ROOT / "scripts" / "apex" / "importPowerPDFKB.apex"
N = 10


def make_url_name(title: str, idx: int) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", title)[:80].strip("-").lower()
    return f"{slug}-ppdf-{idx}"


def apex_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "")


rows = list(csv.DictReader(SRC_CSV.open(encoding="utf-8-sig")))[:N]

# 1 — Rewrite preview CSV: answer first, question second, lowercase headers
with PREVIEW_CSV.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(f, fieldnames=["answer", "question"])
    writer.writeheader()
    for row in rows:
        writer.writerow({
            "answer": row.get("Answer", row.get("answer", "")),
            "question": row.get("Question", row.get("question", "")),
        })
print(f"Preview CSV updated: {PREVIEW_CSV} ({len(rows)} rows)")

# 2 — Generate Apex
APEX_OUT.parent.mkdir(parents=True, exist_ok=True)
lines = []
lines.append("// Import first 10 Power PDF KB articles as Draft Knowledge articles")
lines.append("// Tagged with cursor-test marker for easy cleanup")
lines.append(f"String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');")
lines.append("List<Knowledge__kav> articles = new List<Knowledge__kav>();")
lines.append("")

for i, row in enumerate(rows, 1):
    q = apex_escape(row.get("Question", row.get("question", "")).strip())
    a = apex_escape(row.get("Answer", row.get("answer", "")).strip())
    url = make_url_name(row.get("Question", row.get("question", "")), i)
    lines.append(f"// Article {i}")
    lines.append("articles.add(new Knowledge__kav(")
    lines.append(f"    Title = '{q[:255]}',")
    lines.append(f"    UrlName = '{url}',")
    lines.append(f"    Resolution__c = '{a[:32000]}',")
    lines.append(f"    Summary = 'Power PDF KB - imported via cursor-test',")
    lines.append(f"    Language = 'en_US'")
    lines.append("));")
    lines.append("")

lines.append("insert articles;")
lines.append("")
lines.append("System.debug('=== CURSOR TEST COMPLETE ===');")
lines.append("System.debug('Marker: ' + marker);")
lines.append("System.debug('Articles inserted: ' + articles.size());")
lines.append("for (Knowledge__kav kav : articles) {")
lines.append("    System.debug('ID: ' + kav.Id + ' | Title: ' + kav.Title);")
lines.append("}")

APEX_OUT.write_text("\n".join(lines), encoding="utf-8")
print(f"Apex script written: {APEX_OUT}")
