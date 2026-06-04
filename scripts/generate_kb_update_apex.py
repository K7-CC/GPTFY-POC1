"""Generate Apex to UPDATE Resolution__c on the 10 existing KB articles (solution-only text)."""
import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREVIEW_CSV = ROOT / "data" / "powerpdf-preview-10.csv"
APEX_OUT = ROOT / "scripts" / "apex" / "updatePowerPDFKB.apex"

# The 10 IDs inserted in the previous run, in the same order as the CSV rows
KAV_IDS = [
    "ka0dN000000RqiTQAS",
    "ka0dN000000RqiUQAS",
    "ka0dN000000RqiVQAS",
    "ka0dN000000RqiWQAS",
    "ka0dN000000RqiXQAS",
    "ka0dN000000RqiYQAS",
    "ka0dN000000RqiZQAS",
    "ka0dN000000RqiaQAC",
    "ka0dN000000RqibQAC",
    "ka0dN000000RqicQAC",
]


def apex_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "")


rows = list(csv.DictReader(PREVIEW_CSV.open(encoding="utf-8-sig")))

lines = ["// Update Resolution__c on 10 Power PDF KB articles — solution-only content"]
lines.append("List<Knowledge__kav> toUpdate = new List<Knowledge__kav>();")
lines.append("")

for i, (row, kav_id) in enumerate(zip(rows, KAV_IDS), 1):
    answer = apex_escape(row.get("answer", row.get("Answer", "")).strip())
    question = row.get("question", row.get("Question", "")).strip()
    lines.append(f"// Article {i}: {question[:60]}")
    lines.append(f"toUpdate.add(new Knowledge__kav(Id = '{kav_id}', Resolution__c = '{answer[:32000]}'));")
    lines.append("")

lines.append("update toUpdate;")
lines.append("System.debug('Updated ' + toUpdate.size() + ' KB articles — solution-only content');")

APEX_OUT.write_text("\n".join(lines), encoding="utf-8")
print(f"Apex update script written: {APEX_OUT} ({len(rows)} articles)")
