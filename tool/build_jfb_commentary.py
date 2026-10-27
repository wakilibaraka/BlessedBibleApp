#!/usr/bin/env python3
"""Build the compact offline JFB commentary pack from CCEL's plain text.

CCEL identifies the print basis as 1871 and rights as public domain. The
source checksum prevents silently importing a changed edition/layout.

From the repository root:
  python3 tool/build_jfb_commentary.py --write
  python3 tool/build_jfb_commentary.py --check
"""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "assets/commentary/jfb.json.gz"
SOURCE_URL = "https://www.ccel.org/j/jamieson/jfb/cache/jfb.txt"
SOURCE = "Commentary Critical and Explanatory on the Whole Bible (1871)"
AUTHOR = "Robert Jamieson, A. R. Fausset and David Brown"
LICENSE_URL = "https://creativecommons.org/publicdomain/mark/1.0/"
SOURCE_SHA256 = "de2727aab8a63273a5a0826e1e17ac9270c7bf27976f3317e9be9a7542342a33"
USER_AGENT = "BlessedBibleApp-commentary-builder/1.0"

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

# Canonical KJV chapter counts in the same order as BOOKS.
CHAPTER_COUNTS = [
    50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36, 10, 13, 10, 42,
    150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3, 9, 1, 4, 7, 3, 3, 3, 2, 14,
    4, 28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13,
    5, 5, 3, 5, 1, 1, 1, 22,
]
SECTION_MARKER = re.compile(r"^\s*Commentary by\s+.+$", re.M)
CHAPTER_MARKER = re.compile(r"^\s*CHAPTER\s+(\d+)\s*$", re.I)
PSALM_MARKER = re.compile(r"^\s*PSALM\s+(\d+)\s*$", re.I)
LAMENTATION_MARKER = re.compile(r"^\s*CHAPTER\s+\(ELEGY\)\s+(\d+)\s*$", re.I)
VERSE_START = re.compile(r"^(\d{1,3}(?:\s*,\s*\d{1,3})*)\.\s+(.+)$", re.S)


def fetch_source() -> str:
    request = urllib.request.Request(SOURCE_URL, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read()
    digest = hashlib.sha256(data).hexdigest()
    if digest != SOURCE_SHA256:
        raise RuntimeError(f"CCEL source checksum changed: {digest}")
    return data.decode("utf-8")


def normalize_paragraphs(lines: list[str]) -> list[str]:
    text = "\n".join(line for line in lines if not re.fullmatch(r"\s*_{5,}\s*", line))
    paragraphs = []
    for block in re.split(r"\n\s*\n", text):
        words = [line.strip() for line in block.splitlines() if line.strip()]
        if not words:
            continue
        joined = ""
        for word in words:
            if joined:
                if joined.endswith("-") and word[:1].islower():
                    joined = joined[:-1] + word
                else:
                    joined += " " + word
            else:
                joined = word
        if joined.startswith(("file:///ccel/", "http://www.ccel.org/")):
            continue
        paragraphs.append(joined)
    return paragraphs


def parse_chapter(paragraphs: list[str]) -> tuple[dict[int, list[str]], list[str]]:
    verses: dict[int, list[str]] = {}
    introduction: list[str] = []
    current_verse: int | None = None
    for paragraph in paragraphs:
        match = VERSE_START.match(paragraph)
        if match:
            current_verse = int(match.group(1).split(",", 1)[0].strip())
            if not 1 <= current_verse <= 176:
                current_verse = None
                continue
            verses.setdefault(current_verse, []).append(paragraph[match.start(2):].strip())
        elif current_verse is None:
            introduction.append(paragraph)
        else:
            verses[current_verse].append(paragraph)
    return verses, introduction


def _entries_for_chapter(book_index: int, book: str, chapter: int,
                         paragraphs: list[str]) -> list[dict]:
    verses, introduction = parse_chapter(paragraphs)
    entries = []
    intro = "\n\n".join(introduction).strip()
    if intro:
        entries.append({
            "id": f"jfb_{book_index + 1:02}_{chapter:03}_intro",
            "author": AUTHOR,
            "source": SOURCE,
            "scope": {"type": "chapter", "book": book, "chapter": chapter},
            "text": intro,
        })
    for verse, notes in sorted(verses.items()):
        text = "\n\n".join(note for note in notes if note).strip()
        if text:
            entries.append({
                "id": f"jfb_{book_index + 1:02}_{chapter:03}_{verse:03}",
                "author": AUTHOR,
                "source": SOURCE,
                "scope": {"type": "verse", "book": book,
                          "chapter": chapter, "verse": verse},
                "text": text,
            })
    if not entries:
        raise RuntimeError(f"No JFB content parsed for {book} {chapter}")
    return entries


def parse_entries(text: str) -> list[dict]:
    lines = text.splitlines()
    markers = [i for i, line in enumerate(lines)
               if line.strip().startswith("Commentary by ")]
    if len(markers) != len(BOOKS):
        raise RuntimeError(f"Expected 66 ordered commentary sections, got {len(markers)}")

    entries: list[dict] = []
    covered: set[tuple[str, int]] = set()
    for book_index, book in enumerate(BOOKS):
        start = markers[book_index] + 1
        end = markers[book_index + 1] if book_index + 1 < len(markers) else len(lines)
        section = lines[start:end]
        if book == "Psalms":
            marker_pattern = PSALM_MARKER
        elif book == "Lamentations":
            marker_pattern = LAMENTATION_MARKER
        else:
            marker_pattern = CHAPTER_MARKER

        chapter_starts = []
        for i, line in enumerate(section):
            match = marker_pattern.fullmatch(line)
            if match:
                chapter_starts.append((int(match.group(1)), i))

        expected = CHAPTER_COUNTS[book_index]
        if book in {"Philemon", "2 John", "3 John", "Jude"}:
            chapter_starts = [(1, 0)]
        if len(chapter_starts) != expected:
            raise RuntimeError(
                f"{book}: expected {expected} chapter sections, found {len(chapter_starts)}"
            )

        for index, (chapter, section_start) in enumerate(chapter_starts):
            section_end = (chapter_starts[index + 1][1]
                           if index + 1 < len(chapter_starts) else len(section))
            body_start = section_start + (0 if book in {"Philemon", "2 John", "3 John", "Jude"} else 1)
            paragraphs = normalize_paragraphs(section[body_start:section_end])
            entries.extend(_entries_for_chapter(book_index, book, chapter, paragraphs))
            covered.add((book, chapter))

    expected_coverage = {
        (book, chapter)
        for book, count in zip(BOOKS, CHAPTER_COUNTS)
        for chapter in range(1, count + 1)
    }
    missing = sorted(expected_coverage - covered)
    if missing:
        raise RuntimeError(f"JFB import is missing {len(missing)} chapters, e.g. {missing[:10]}")
    if len({entry["id"] for entry in entries}) != len(entries):
        raise RuntimeError("Generated duplicate JFB entry IDs")
    return entries


def encode_pack(entries: list[dict]) -> bytes:
    payload = json.dumps({
        "format": "the-blessed-bible.commentary",
        "version": 1,
        "source": SOURCE,
        "sourceUrl": SOURCE_URL,
        "license": LICENSE_URL,
        "chapterCount": sum(CHAPTER_COUNTS),
        "count": len(entries),
        "entries": entries,
    }, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    return gzip.compress(payload, compresslevel=9, mtime=0)


def validate_pack(data: bytes) -> tuple[int, int]:
    decoded = json.loads(gzip.decompress(data).decode("utf-8"))
    entries = decoded.get("entries", [])
    if decoded.get("format") != "the-blessed-bible.commentary":
        raise RuntimeError("Unexpected JFB pack format")
    if decoded.get("count") != len(entries) or not entries:
        raise RuntimeError("JFB pack count mismatch or empty entries")
    ids = set()
    chapters = set()
    books = set()
    for entry in entries:
        scope = entry.get("scope", {})
        if not entry.get("id") or entry["id"] in ids:
            raise RuntimeError(f"Missing or duplicate JFB id: {entry.get('id')}")
        ids.add(entry["id"])
        if not entry.get("text", "").strip():
            raise RuntimeError(f"Empty JFB entry: {entry['id']}")
        if scope.get("type") in ("verse", "chapter"):
            chapters.add((scope["book"], scope["chapter"]))
            books.add(scope["book"])
    if len(books) != 66 or len(chapters) != sum(CHAPTER_COUNTS):
        raise RuntimeError(f"JFB coverage mismatch: {len(books)} books, {len(chapters)} chapters")
    for book, chapter, verse in (("Genesis", 1, 1), ("Exodus", 20, 8),
                                  ("Daniel", 8, 14), ("Revelation", 14, 12)):
        if not any(e["scope"].get("book") == book and
                   e["scope"].get("chapter") == chapter and
                   e["scope"].get("verse") == verse for e in entries):
            raise RuntimeError(f"Missing expected JFB reference {book} {chapter}:{verse}")
    return len(entries), len(chapters)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true", help="fetch CCEL text and write the asset")
    mode.add_argument("--check", action="store_true", help="validate the existing asset")
    args = parser.parse_args()
    if args.write:
        asset = encode_pack(parse_entries(fetch_source()))
        count, chapters = validate_pack(asset)
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT.write_bytes(asset)
    else:
        asset = OUTPUT.read_bytes()
        count, chapters = validate_pack(asset)
    print(f"JFB pack OK: {count:,} entries, {chapters:,} chapters; "
          f"{len(asset):,} bytes compressed; sha256={hashlib.sha256(asset).hexdigest()}")


if __name__ == "__main__":
    main()
