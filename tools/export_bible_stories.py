#!/usr/bin/env python3
"""Export The Graham Bible story data (KJV text + narrative retellings) for BlessedBibleApp.

Fetches all 500 devotional spreads from graham-devotional's public Supabase REST
endpoint and writes:
  assets/devotional/stories/index.json        - light story index (all 500)
  assets/devotional/stories/<BOOK>.json       - full text per book (66 files)
  tools/data/export_manifest.json             - build report

Text rights: KJV is public domain. Narrative summaries are included per the
project owner's decision; attribution is embedded in each book file.
Run:  python3 tools/export_bible_stories.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from devotional_common import (  # noqa: E402
    ATTRIBUTION,
    SECTION_MAP,
    STORIES_DIR,
    TOOLS_DATA_DIR,
    ensure_dirs,
    log,
    save_json,
    supabase_query,
)

FIELDS = ",".join(
    [
        "spread_code",
        "testament",
        "book",
        "start_chapter",
        "start_verse",
        "end_chapter",
        "end_verse",
        "title",
        "kjv_passage_ref",
        "kjv_passage_text",
        "kjv_key_verse_ref",
        "kjv_key_verse_text",
        "paraphrase_text",
    ]
)

# Group books into per-file buckets keyed by spread prefix (66 expected, GSP merged none)
FILES = {}


def normalize_verse_text(text: str) -> str:
    """KJV passage text arrives newline-separated per verse."""
    if not text:
        return ""
    lines = [ln.strip() for ln in text.replace("\r", "\n").split("\n")]
    return "\n".join(ln for ln in lines if ln)


def clean_key_verse(text: str) -> str:
    """Strip markdown bold markers the source uses for emphasis."""
    if not text:
        return ""
    return text.replace("**", "").strip()


def main() -> None:
    ensure_dirs()
    log("Fetching spreads from Supabase (public anon read)...")
    rows = []
    page, page_size = 0, 300
    while True:
        chunk = supabase_query(
            f"select={FIELDS}&order=spread_code.asc&limit={page_size}&offset={page * page_size}",
            timeout=180,
        )
        rows.extend(chunk)
        log(f"  fetched {len(rows)} rows")
        if len(chunk) < page_size:
            break
        page += 1

    if not rows:
        die("no rows returned - check network or endpoint")

    by_prefix = {}
    for r in rows:
        code = r.get("spread_code", "")
        prefix = code.rsplit("-", 1)[0] if "-" in code else code
        if prefix not in SECTION_MAP:
            log(f"  WARN unknown prefix {prefix!r} ({code}) - skipping")
            continue
        by_prefix.setdefault(prefix, []).append(r)

    total_stories = 0
    books_out = []
    missing_paraphrase = 0
    for prefix, name, testament, grouping, order in sorted(
        ((p, *SECTION_MAP[p][:3], SECTION_MAP[p][3]) for p in by_prefix), key=lambda t: t[4]
    ):
        stories = []
        for r in sorted(by_prefix[prefix], key=lambda x: x["spread_code"]):
            para = (r.get("paraphrase_text") or "").strip()
            if not para:
                missing_paraphrase += 1
            stories.append(
                {
                    "id": r["spread_code"],
                    "title": (r.get("title") or "").strip(),
                    "ref": (r.get("kjv_passage_ref") or "").strip(),
                    "verse": (r.get("start_chapter"), r.get("start_verse")),
                    "keyVerseRef": (r.get("kjv_key_verse_ref") or "").strip(),
                    "keyVerse": clean_key_verse(r.get("kjv_key_verse_text") or ""),
                    "text": normalize_verse_text(r.get("kjv_passage_text") or ""),
                    "retelling": para,
                }
            )
        payload = {
            "book": name,
            "prefix": prefix,
            "testament": testament,
            "grouping": grouping,
            "order": order,
            "attribution": ATTRIBUTION,
            "stories": stories,
        }
        save_json(os.path.join(STORIES_DIR, f"{prefix}.json"), payload)
        books_out.append(
            {
                "prefix": prefix,
                "book": name,
                "testament": testament,
                "grouping": grouping,
                "order": order,
                "count": len(stories),
            }
        )
        total_stories += len(stories)

    # Light index for eager loading (no text bodies)
    index = {
        "version": 1,
        "generated": "export_bible_stories.py",
        "total": total_stories,
        "books": books_out,
    }
    save_json(os.path.join(STORIES_DIR, "index.json"), index)

    manifest = {
        "rows_fetched": len(rows),
        "books_written": len(books_out),
        "total_stories": total_stories,
        "stories_missing_retelling": missing_paraphrase,
    }
    save_json(os.path.join(TOOLS_DATA_DIR, "export_manifest.json"), manifest)
    log(f"Done: {total_stories} stories across {len(books_out)} book files ({missing_paraphrase} missing retellings)")


if __name__ == "__main__":
    main()
