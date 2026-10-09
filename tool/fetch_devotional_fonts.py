#!/usr/bin/env python3
"""Fetch devotional OFL fonts (TTF) from the Fontsource CDN (jsDelivr).

Downloads latin subsets of:
  - Playfair Display 400/500/600/700 + italic 400   (headings)
  - Cormorant Garamond 400/500/600 + italic 400     (key verses)
  - IM Fell English 400 + italic 400                (flavor)

Also writes the OFL license for each family. Flutter requires TTF/OTF, so we
use Fontsource's TTF builds rather than Google Fonts' woff2.

Run:  python3 tools/fetch_devotional_fonts.py
"""

import os
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from devotional_common import FONTS_DIR, log  # noqa: E402

CDN = "https://cdn.jsdelivr.net/fontsource/fonts/{slug}@latest/latin-{weight}-{style}.ttf"
LICENSE_URL = "https://cdn.jsdelivr.net/fontsource/fonts/{slug}@latest/LICENSE"

FAMILIES = {
    "playfair-display": ("PlayfairDisplay", [400, 500, 600, 700], [400]),
    "cormorant-garamond": ("CormorantGaramond", [400, 500, 600], [400]),
    "im-fell-english": ("IMFellEnglish", [400], [400]),
}


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "BlessedBibleApp-port/1.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def main() -> None:
    out_dir = os.path.join(FONTS_DIR, "devotional")
    os.makedirs(out_dir, exist_ok=True)
    total = 0
    for slug, (prefix, weights, italics) in FAMILIES.items():
        for w in weights:
            dest = os.path.join(out_dir, f"{prefix}-{w}.ttf")
            if not os.path.exists(dest):
                data = fetch(CDN.format(slug=slug, weight=w, style="normal"))
                open(dest, "wb").write(data)
                log(f"  {prefix}-{w}.ttf  {len(data) // 1024} KB")
            else:
                log(f"  cached {prefix}-{w}.ttf")
            total += os.path.getsize(dest)
        for w in italics:
            dest = os.path.join(out_dir, f"{prefix}-{w}italic.ttf")
            if not os.path.exists(dest):
                data = fetch(CDN.format(slug=slug, weight=w, style="italic"))
                open(dest, "wb").write(data)
                log(f"  {prefix}-{w}italic.ttf  {len(data) // 1024} KB")
            else:
                log(f"  cached {prefix}-{w}italic.ttf")
            total += os.path.getsize(dest)
        lic = os.path.join(out_dir, f"{prefix}-LICENSE.txt")
        if not os.path.exists(lic):
            try:
                data = fetch(LICENSE_URL.format(slug=slug))
                open(lic, "wb").write(data)
                log(f"  {prefix}-LICENSE.txt {len(data) // 1024} KB")
            except Exception as e:  # noqa: BLE001
                log(f"  WARN license fetch failed for {slug}: {e}")
    log(f"Done. Total font bytes: {total / 1e6:.2f} MB in {out_dir}")


if __name__ == "__main__":
    main()
