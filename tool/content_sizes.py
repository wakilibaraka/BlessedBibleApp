#!/usr/bin/env python3
"""Report text-content storage sizes, highest to lowest.

Covers: bundled APK assets, standalone translation packs, downloadable
packs (Firebase Storage / helloao), and estimated on-device footprints.

Usage:  python3 tool/content_sizes.py
"""
import json
import os
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def mb(path):
    path = Path(path)
    if path.is_dir():
        total = 0
        for root, _dirs, files in os.walk(path):
            for f in files:
                try:
                    total += (Path(root) / f).stat().st_size
                except OSError:
                    pass
        return total / (1 << 20)
    return path.stat().st_size / (1 << 20)


def db_text_mb(path, translation_id=None):
    con = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    try:
        if translation_id:
            v = con.execute(
                "SELECT SUM(LENGTH(text)) FROM verses WHERE translation_id=?",
                (translation_id,),
            ).fetchone()[0]
        else:
            v = con.execute("SELECT SUM(LENGTH(text)) FROM verses").fetchone()[0]
        return (v or 0) / (1 << 20)
    finally:
        con.close()


def main():
    rows = []  # (label, mb, note)

    core = ROOT / "assets" / "bible" / "bible.db"
    rows.append(("Bible core DB (KJV + KJV-Strong's + xrefs + dictionary + Strong's lexicon)", mb(core), "bundled, never deletable"))

    packs_dir = ROOT / "assets" / "packs"
    if packs_dir.exists():
        for p in sorted(packs_dir.glob("*.db")):
            tid = p.stem
            rows.append((f"Pack (bundled, deletable): {tid}", mb(p), "restorable offline from APK"))

    rows.append(("Devotional art (Dore plates)", mb(ROOT / "assets" / "devotional" / "art"), "bundled"))
    rows.append(("Commentary (4,724 entries)", mb(ROOT / "assets" / "commentary" / "commentary.json"), "bundled"))
    rows.append(("Bible stories (66 books)", mb(ROOT / "assets" / "devotional" / "stories"), "bundled"))
    rows.append(("Reading plans", mb(ROOT / "assets" / "reading_plans"), "bundled"))
    rows.append(("Misc data (pericopes, word counts, ...)", mb(ROOT / "assets" / "data"), "bundled"))

    # Per-translation verse text inside the core DB.
    con = sqlite3.connect(f"file:{core}?mode=ro", uri=True)
    try:
        core_ids = [r[0] for r in con.execute("SELECT translation_id FROM translations")]
    finally:
        con.close()
    for tid in core_ids:
        rows.append((f"  - core translation text: {tid}", db_text_mb(core, tid), "verse text only"))

    up = ROOT / "content_packs" / "manifest.json"
    if up.exists():
        manifest = json.loads(up.read_text())
        for tid, info in sorted(manifest.get("upload_packs", {}).items()):
            rows.append((f"Downloadable pack: {tid} ({info['meta']['translation_name']})", info["sizeMB"], "Firebase Storage"))

    rows.sort(key=lambda r: r[1], reverse=True)
    total_bundled = mb(core)
    if packs_dir.exists():
        total_bundled += sum(mb(p) for p in packs_dir.glob("*.db"))
    print(f"{'CONTENT':62s} {'MB':>8s}  NOTE")
    print("-" * 100)
    for label, size, note in rows:
        print(f"{label:62s} {size:8.2f}  {note}")
    print("-" * 100)
    print(f"{'Bundled bible content (core + packs)':62s} {total_bundled:8.2f}")
    print()
    print("On-device after clear data: ~51 MB core + copied bundled packs")
    print("(~25 MB) unless the user deleted any; KJV backbone self-heals.")


if __name__ == "__main__":
    main()
