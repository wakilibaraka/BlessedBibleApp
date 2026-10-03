#!/usr/bin/env python3
"""Regenerate assets/data/word_counts.json from the offline database.

Source of truth: `verses WHERE translation_id='kjv'` in assets/bible/bible.db
plus book names from lib/data/bible_books.dart (index+1 == book_number).

Replaces test/word_count_generator_test.dart (a code generator masquerading
as a test that rewrote assets on every `flutter test` run).

Tokenization must match the app exactly: split on whitespace, drop empty
tokens and standalone paragraph markers ('¶').
"""
import json
import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB = ROOT / "assets" / "bible" / "bible.db"
BOOKS_DART = ROOT / "lib" / "data" / "bible_books.dart"
OUT = ROOT / "assets" / "data" / "word_counts.json"


def book_names():
    names = []
    for line in BOOKS_DART.read_text().splitlines():
        line = line.strip()
        if line.startswith("'") and line.endswith("',"):
            names.append(line[1:-2])
    assert len(names) == 66, f"expected 66 books, got {len(names)}"
    return names


def main():
    names = book_names()
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    rows = con.execute(
        "SELECT book_number, chapter, verse, text FROM verses "
        "WHERE translation_id='kjv' "
        "ORDER BY book_number, chapter, verse"
    ).fetchall()
    con.close()

    result = {}
    total_words = 0
    for book_num, chapter, verse, text in rows:
        book = names[book_num - 1]
        chapter_s, verse_s = str(chapter), str(verse)
        count = sum(
            1 for t in re.split(r"\s+", text.strip()) if t and t != "¶"
        )
        book_map = result.setdefault(book, {})
        ch = book_map.setdefault(
            chapter_s, {"total": 0, "verses": {}}
        )
        ch["verses"][verse_s] = count
        ch["total"] += count
        total_words += count

    # Byte-compatible with Dart's jsonEncode: compact separators, raw UTF-8.
    OUT.write_text(
        json.dumps(result, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    books = len(result)
    chapters = sum(len(v) for v in result.values())
    print(f"verses={len(rows)} books={books} chapters={chapters} "
          f"total_words={total_words} -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    sys.exit(main())
