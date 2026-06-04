"""Generate PDF from the project walkthrough markdown file."""
from pathlib import Path
import re

from fpdf import FPDF

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "docs" / "GPTfy-POC1-Project-Walkthrough.md"
PDF_PATH = ROOT / "docs" / "GPTfy-POC1-Project-Walkthrough.pdf"


class WalkthroughPDF(FPDF):
    def header(self):
        if self.page_no() > 1:
            self.set_font("Helvetica", "I", 8)
            self.set_text_color(120, 120, 120)
            self.cell(0, 8, "GPTfy POC1 - Project Walkthrough", align="R", new_x="LMARGIN", new_y="NEXT")
            self.ln(2)

    def footer(self):
        self.set_y(-12)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 8, f"Page {self.page_no()}", align="C")


def sanitize(text: str) -> str:
    replacements = {
        "\u2014": "-",
        "\u2013": "-",
        "\u2018": "'",
        "\u2019": "'",
        "\u201c": '"',
        "\u201d": '"',
        "\u2022": "-",
        "\u2192": "->",
        "\u2260": "!=",
        "\u00a0": " ",
    }
    for src, dst in replacements.items():
        text = text.replace(src, dst)
    return text.encode("latin-1", "replace").decode("latin-1")


def strip_md_inline(text: str) -> str:
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"\1", text)
    text = re.sub(r"\*([^*]+)\*", r"\1", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    return sanitize(text.strip())


def render_markdown(pdf: WalkthroughPDF, md_text: str) -> None:
    lines = md_text.splitlines()
    i = 0
    in_code = False
    code_lines: list[str] = []
    table_rows: list[list[str]] = []

    def reset_x() -> None:
        pdf.set_x(pdf.l_margin)

    def write_para(text: str, h: float = 5.5) -> None:
        reset_x()
        pdf.multi_cell(0, h, text)

    def flush_table() -> None:
        nonlocal table_rows
        if not table_rows:
            return
        col_count = max(len(r) for r in table_rows)
        usable = pdf.w - pdf.l_margin - pdf.r_margin
        col_w = usable / col_count
        pdf.set_font("Helvetica", "", 9)
        for row_idx, row in enumerate(table_rows):
            if row_idx == 1 and all(re.fullmatch(r"-+", c.strip()) for c in row):
                continue
            reset_x()
            pdf.set_font("Helvetica", "B" if row_idx == 0 else "", 9)
            for col_idx in range(col_count):
                cell = strip_md_inline(row[col_idx]) if col_idx < len(row) else ""
                pdf.cell(col_w, 7, cell[:80], border=1)
            pdf.ln(7)
        pdf.ln(3)
        table_rows = []

    while i < len(lines):
        raw = lines[i]
        line = raw.rstrip()

        if line.strip().startswith("```"):
            if in_code:
                pdf.set_font("Courier", "", 8)
                pdf.set_fill_color(245, 245, 245)
                for code_line in code_lines:
                    write_para(sanitize(code_line), 4.5)
                pdf.ln(2)
                code_lines = []
                in_code = False
            else:
                flush_table()
                in_code = True
            i += 1
            continue

        if in_code:
            code_lines.append(line)
            i += 1
            continue

        if line.startswith("|") and line.endswith("|"):
            cells = [c.strip() for c in line.strip("|").split("|")]
            table_rows.append(cells)
            i += 1
            continue
        flush_table()

        if not line.strip():
            pdf.ln(2)
            i += 1
            continue

        if line.startswith("# "):
            pdf.ln(4)
            pdf.set_font("Helvetica", "B", 18)
            pdf.set_text_color(20, 60, 120)
            write_para(strip_md_inline(line[2:]), 10)
            pdf.set_text_color(0, 0, 0)
            pdf.ln(2)
        elif line.startswith("## "):
            pdf.ln(3)
            pdf.set_font("Helvetica", "B", 14)
            pdf.set_text_color(30, 80, 140)
            write_para(strip_md_inline(line[3:]), 8)
            pdf.set_text_color(0, 0, 0)
            pdf.ln(1)
        elif line.startswith("### "):
            pdf.ln(2)
            pdf.set_font("Helvetica", "B", 11)
            write_para(strip_md_inline(line[4:]), 7)
        elif line.startswith("> "):
            pdf.set_font("Helvetica", "I", 10)
            write_para("    " + strip_md_inline(line[2:]))
        elif re.match(r"^[-*] ", line):
            pdf.set_font("Helvetica", "", 10)
            write_para("  - " + strip_md_inline(line[2:]))
        elif re.match(r"^\d+\. ", line):
            pdf.set_font("Helvetica", "", 10)
            write_para(strip_md_inline(line))
        elif line.strip() == "---":
            pdf.ln(2)
            y = pdf.get_y()
            pdf.set_draw_color(200, 200, 200)
            pdf.line(pdf.l_margin, y, pdf.w - pdf.r_margin, y)
            pdf.ln(4)
        else:
            pdf.set_font("Helvetica", "", 10)
            write_para(strip_md_inline(line))
        i += 1

    flush_table()


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    pdf = WalkthroughPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.set_margins(18, 18, 18)
    pdf.add_page()
    render_markdown(pdf, md_text)
    pdf.output(str(PDF_PATH))
    print(f"Wrote {PDF_PATH}")


if __name__ == "__main__":
    main()
