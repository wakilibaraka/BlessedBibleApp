#!/usr/bin/env python3
"""Import Matthew Henry's Concise Commentary into the bundled commentary JSON.

The source is the public-domain CCEL text cited by the CrossWire SWORD MHCC
module. Run from the repository root, optionally with --source PATH to use a
previously downloaded copy. The generated entries retain chapter-range headings
from the source and use chapter scope rather than inventing verse-level anchors.
"""
import argparse
import hashlib
import json
import re
import sqlite3
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_URL = "https://ccel.org/ccel/h/henry/mhcc/cache/mhcc.txt"
SOURCE_SHA256 = "7af7f0feef2a8522263d48825a170125f4c421d14250212d83db6aef6d4f5269"
COMMENTARY_PATH = ROOT / "assets/commentary/commentary.json"
BIBLE_DB_PATH = ROOT / "assets/bible/bible.db"
SOURCE_TITLE = "Matthew Henry's Concise Commentary on the Bible"

# OCR artifacts in the scanned CCEL text (ABBYY-style control words, spacing).
FIXES = {
    "\\rdblquote": '"',
    " ,": ",",
}

BOOKS = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua",
    "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings",
    "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job",
    "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah",
    "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel",
    "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
    "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark",
    "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians",
    "Galatians", "Ephesians", "Philippians", "Colossians",
    "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus",
    "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John",
    "2 John", "3 John", "Jude", "Revelation",
]


def load_source(path):
    if path:
        source = Path(path).read_bytes()
    else:
        request = urllib.request.Request(
            SOURCE_URL, headers={"User-Agent": "TheBlessedBible content importer"}
        )
        with urllib.request.urlopen(request, timeout=60) as response:
            source = response.read()
    if hashlib.sha256(source).hexdigest() != SOURCE_SHA256:
        raise ValueError("CCEL source checksum changed; inspect the new edition before importing")
    return source.decode("utf-8")


def reflow(text):
    paragraphs = re.split(r"\n\s*\n", text)
    cleaned = []
    for paragraph in paragraphs:
        lines = [line.strip() for line in paragraph.splitlines() if line.strip()]
        lines = [line for line in lines if not re.fullmatch(r"_{20,}", line)]
        if not lines:
            continue
        if re.fullmatch(r"Chapter Outline", lines[0]):
            # Preserve Henry's range headings to distinguish grouped passage commentary.
            cleaned.append("Chapter Outline\n" + "\n".join(lines[1:]))
        else:
            cleaned.append(" ".join(lines))
    text = "\n\n".join(cleaned).strip()
    for bad, good in FIXES.items():
        text = text.replace(bad, good)
    return text


def parse_entries(source):
    if SOURCE_TITLE not in source[:2000] or "Rights: Public Domain" not in source[:2000]:
        raise ValueError("Source header/title or public-domain statement did not match")
    source = source.split("\n                                    Indexes\n", 1)[0]
    book_matches = []
    for book in BOOKS:
        matches = list(re.finditer(r"^[ \t]{20,}" + re.escape(book) + r"[ \t]*$", source, re.M))
        if len(matches) != 1:
            raise ValueError(f"Expected one centered heading for {book}, found {len(matches)}")
        match = matches[0]
        book_matches.append((match.start(), match.end(), book))
    book_matches.sort()

    chapter_counts = {}
    with sqlite3.connect(f"file:{BIBLE_DB_PATH}?mode=ro", uri=True) as db:
        for book_number, book in enumerate(BOOKS, start=1):
            chapter_counts[book] = {
                row[0] for row in db.execute(
                    "SELECT DISTINCT chapter FROM verses "
                    "WHERE translation_id = 'kjv' AND book_number = ?",
                    (book_number,),
                )
            }

    result = []
    chapter_heading = re.compile(r"^Chapter (\d+)$", re.M)
    for index, (start, header_end, book) in enumerate(book_matches):
        end = book_matches[index + 1][0] if index + 1 < len(book_matches) else len(source)
        section = source[header_end:end]
        headings = list(chapter_heading.finditer(section))
        expected = chapter_counts[book]
        numbers = [int(match.group(1)) for match in headings]
        if not numbers or numbers != sorted(set(numbers)):
            raise ValueError(f"Invalid or missing chapter headings in {book}: {numbers}")
        missing_numbers = sorted(expected - set(numbers))
        if len(numbers) != len(expected) - len(missing_numbers) or missing_numbers not in ([], [1]):
            raise ValueError(f"Unexpected chapter coverage in {book}: {numbers}")
        if any(number not in expected for number in numbers):
            raise ValueError(f"Out-of-canon chapter in {book}: {numbers}")

        sections = []
        book_introduction = section[:headings[0].start()]
        if numbers[0] > 1:
            sections.append((1, book_introduction))
        for position, heading in enumerate(headings):
            stop = headings[position + 1].start() if position + 1 < len(headings) else len(section)
            chapter = int(heading.group(1))
            body = section[heading.end():stop]
            if chapter == 1 and numbers[0] == 1 and book_introduction.strip():
                body = book_introduction + "\n\n" + body
            sections.append((chapter, body))

        built = set()
        for chapter, body in sections:
            if chapter not in expected or chapter in built:
                raise ValueError(f"Invalid or duplicate chapter {book} {chapter}")
            text = reflow(body)
            if not text:
                raise ValueError(f"Empty commentary for {book} {chapter}")
            built.add(chapter)
            result.append({
                "id": f"mhcc_{BOOKS.index(book) + 1:02d}_{chapter:03d}",
                "author": "Matthew Henry",
                "source": SOURCE_TITLE,
                "scope": {"type": "chapter", "book": book, "chapter": chapter},
                "text": text,
            })
        if built != expected:
            raise ValueError(
                f"Chapter coverage mismatch for {book}: missing {sorted(expected - built)}"
            )
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", help="Path to the downloaded CCEL plaintext")
    parser.add_argument("--check", action="store_true", help="Verify entries without writing")
    args = parser.parse_args()

    entries = parse_entries(load_source(args.source))
    content = json.loads(COMMENTARY_PATH.read_text(encoding="utf-8"))
    existing = {entry.get("id"): entry for entry in content["entries"]}
    for entry in entries:
        previous = existing.get(entry["id"])
        if previous is not None and previous != entry:
            raise ValueError(f"Generated ID conflicts with existing entry: {entry['id']}")
    if args.check:
        missing = [entry["id"] for entry in entries if existing.get(entry["id"]) != entry]
        if missing:
            raise SystemExit(f"{len(missing)} Matthew Henry entries missing or changed")
        print(f"OK: {len(entries)} Matthew Henry chapter entries verified")
        return

    content["entries"].extend(entry for entry in entries if entry["id"] not in existing)
    content["count"] = len(content["entries"])
    COMMENTARY_PATH.write_text(
        json.dumps(content, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Wrote {len(entries)} Matthew Henry chapters; {content['count']} total entries")


if __name__ == "__main__":
    main()
