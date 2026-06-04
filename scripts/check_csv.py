"""Print first N rows of a product CSV for quality review."""
import csv
from pathlib import Path

CSV_PATH = Path(r"d:\Kesav-project-1\GPTFY POC1\data\powerpdf-faq-kb.csv")
PREVIEW_ROWS = 10
ANSWER_PREVIEW = 300

rows = list(csv.DictReader(CSV_PATH.open(encoding="utf-8-sig")))
print(f"Total rows in CSV: {len(rows)}\n")

for i, row in enumerate(rows[:PREVIEW_ROWS], 1):
    q = row.get("Question", "").strip()
    a = row.get("Answer", "").strip()
    url = row.get("Source_URL", "").strip()
    ct = row.get("Content_Type", "").strip()
    print(f"--- Row {i} ({ct}) ---")
    print(f"Q: {q}")
    print(f"A: {a[:ANSWER_PREVIEW]}{'...' if len(a) > ANSWER_PREVIEW else ''}")
    print(f"URL: {url}")
    print()
