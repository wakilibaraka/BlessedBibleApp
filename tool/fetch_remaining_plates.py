#!/usr/bin/env python3
"""One-shot patient downloader for remaining Doré plates.

Uses the same thumburl cache as fetch_dore_art.py but with very patient
backoff (Wikimedia rate limits). Run repeatedly until 'ALL DONE'.
"""

import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from devotional_common import ART_DIR, TOOLS_DATA_DIR, http_get, log, save_json  # noqa: E402
from fetch_dore_art import PLATES, category_thumb_urls, process, thumbify  # noqa: E402

WANTED = ["daniel-lions", "revelation-throne", "isaiah-vision", "solomon-temple"]


def main() -> None:
    credits_path = os.path.join(TOOLS_DATA_DIR, "dore_credits.json")
    credits = json.load(open(credits_path))
    plates = credits["plates"]
    urls = category_thumb_urls()

    remaining = []
    for slug in WANTED:
        if slug in plates and os.path.exists(os.path.join(ART_DIR, f"{slug}.webp")):
            continue
        caption, topics, candidates = PLATES[slug]
        file = next((c for c in candidates if c in urls), None)
        if not file:
            log(f"{slug}: no candidate in cache: {candidates}")
            continue
        remaining.append((slug, caption, topics, file, urls[file]))

    if not remaining:
        log("ALL DONE - nothing to fetch")
        return

    for slug, caption, topics, file, url in remaining:
        try:
            raw = http_get(thumbify(url), timeout=120, retries=8)
            meta = process(raw, slug)
            plates[slug] = {"caption": caption, "source": file, "url": url, **meta}
            save_json(credits_path, credits, sort_keys=True)
            log(f"ok {slug} <- {file} ({meta['bytes'] // 1024} KB)")
        except Exception as e:  # noqa: BLE001
            log(f"FAIL {slug}: {e}")
        time.sleep(10)


if __name__ == "__main__":
    main()
