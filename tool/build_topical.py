#!/usr/bin/env python3
"""Build starter topical reading plans from audited Nave/Torrey data (Phase F).

Sources (license gate PASSED, see plan):
  - Nave's Topical Bible (1896) + Torrey's New Topical Textbook (1897):
    US public domain. Normalized assertions via
    j86schroeder/topical-bible-search (MIT code; data per that repo's
    public-domain-derivation statement; 0 unresolved refs upstream).
  - Pinned input: dist/*topics.jsonl + dist/*assertions.jsonl fetched
    2026-10-04 (rerun deliberately; record new SHAs below when you do).

Pipeline: normalize -> merge overlaps -> canonical order -> greedy
word-count split -> curated-shape JSON with attribution/license fields.
Every emitted ref must resolve against word_counts bounds (asserted);
the Dart asset test re-validates all of this independently.

Usage:  python3 tool/build_topical.py
"""
import hashlib
import json
from pathlib import Path

TOPICAL_DIR = Path(
    "/var/folders/5p/g571cd451cbctttb3w58m9dh0000gn/T/opencode/topical")
ROOT = Path(__file__).resolve().parent.parent
WC = json.load(open(ROOT / "assets" / "data" / "word_counts.json"))

PLANS = {
    "prayer": ("topical_prayer_21", "A Life of Prayer — 21 Days",
               "Twenty-one days of Scripture on prayer: asking, intercession, "
               "patience and praise, drawn from Nave and Torrey.", 21),
    "faith": ("topical_faith_21", "The Way of Faith — 21 Days",
              "Three weeks on trust, belief and faithfulness across the "
              "canon, drawn from Nave and Torrey.", 21),
    "praise": ("topical_praise_14", "Songs of Praise — 14 Days",
               "Two weeks of psalms and songs celebrating God, drawn from "
               "Nave and Torrey.", 14),
    "covenant": ("topical_covenant_7", "The Covenant Story — 7 Days",
                 "One week tracing God's covenants from Noah to the new "
                 "covenant, drawn from Nave and Torrey.", 7),
}

ATTRIBUTION = ("References from Nave's Topical Bible (1896) and Torrey's New "
               "Topical Textbook (1897), public domain; normalized via "
               "j86schroeder/topical-bible-search (MIT).")
LICENSE = "Public domain sources (US); plan arrangement original."


def words(book, ch, v):
    return WC[book][str(ch)]["verses"][str(v)]


def chapter_verses(book, ch):
    return sorted(int(x) for x in WC[book][str(ch)]["verses"].keys())


def load_ranges(slug):
    """(book, sc, sv, ec, ev) normalized refs for a topic slug."""
    out = []
    skipped = 0
    for f in ("dist_nave_assertions.jsonl", "dist_torrey_assertions.jsonl"):
        for line in open(TOPICAL_DIR / f):
            a = json.loads(line)
            if a.get("sourceTopicSlug") != slug:
                continue
            b = a.get("book")
            cs, vs, ce, ve = (a.get("chapterStart"), a.get("verseStart"),
                              a.get("chapterEnd"), a.get("verseEnd"))
            if b not in WC or cs is None or str(cs) not in WC[b]:
                skipped += 1
                continue
            if vs is None:
                vs = 1
            if ce is None or str(ce) not in WC[b]:
                ce = cs
            if ve is None:
                ve = max(chapter_verses(b, ce))
            # Clamp to canon bounds (upstream errata covers the rest).
            if vs < 1 or ve < vs:
                skipped += 1
                continue
            maxv = max(chapter_verses(b, ce))
            if ve > maxv:
                skipped += 1
                continue
            out.append((b, cs, vs, ce, ve))
    return out, skipped


def split_chapters(ranges):
    """Split cross-chapter ranges into per-chapter (book,ch,lo,hi)."""
    out = []
    for (b, sc, sv, ec, ev) in ranges:
        for ch in range(sc, ec + 1):
            lo = sv if ch == sc else 1
            hi = ev if ch == ec else max(chapter_verses(b, ch))
            out.append((b, ch, lo, hi))
    return out


def merge(out_key_ranges):
    """Merge overlapping/adjacent verse intervals per (book, chapter)."""
    by_ch = {}
    for (b, ch, lo, hi) in out_key_ranges:
        by_ch.setdefault((b, ch), []).append((lo, hi))
    merged = []
    for (b, ch), ivs in by_ch.items():
        ivs.sort()
        cur_lo, cur_hi = ivs[0]
        for lo, hi in ivs[1:]:
            if lo <= cur_hi + 1:
                cur_hi = max(cur_hi, hi)
            else:
                merged.append((b, ch, cur_lo, cur_hi))
                cur_lo, cur_hi = lo, hi
        merged.append((b, ch, cur_lo, cur_hi))
    # Canonical order.
    order = {b: i for i, b in enumerate(WC.keys())}
    merged.sort(key=lambda t: (order[t[0]], t[1], t[2]))
    return merged


def ref_label(b, ch, lo, hi):
    maxv = max(chapter_verses(b, ch))
    if lo == 1 and hi == maxv:
        return f"{b} {ch}"
    if lo == hi:
        return f"{b} {ch}:{lo}"
    return f"{b} {ch}:{lo}-{hi}"


def range_words(b, ch, lo, hi):
    return sum(words(b, ch, v) for v in range(lo, hi + 1))


def build_plan(slug, plan_id, title, description, days):
    ranges, skipped = load_ranges(slug)
    merged = merge(split_chapters(ranges))
    weights = [(r, range_words(*r)) for r in merged]
    total = sum(w for _, w in weights)
    target = total / days
    # Pre-split oversized ranges (whole chapters) into verse chunks so
    # the day count is reachable; ranges stay contiguous and ordered.
    split = []
    for (b, ch, lo, hi), w in weights:
        parts = max(1, round(w / target))
        if parts <= 1 or hi - lo + 1 <= parts:
            split.append(((b, ch, lo, hi), w))
            continue
        size = (hi - lo + 1 + parts - 1) // parts
        start = lo
        while start <= hi:
            end = min(hi, start + size - 1)
            split.append(
                ((b, ch, start, end), range_words(b, ch, start, end)))
            start = end + 1
    weights = split
    # Cumulative-target cut: fill each day to ~target words, always
    # leaving enough ranges for the remaining days (no empty groups).
    day_groups, cur, cur_w = [], [], 0
    n = len(weights)
    for i, (r, w) in enumerate(weights):
        cur.append(r)
        cur_w += w
        remaining_groups = days - len(day_groups) - 1
        remaining_ranges = n - i - 1
        forced = (remaining_ranges == remaining_groups and
                  remaining_groups > 0)
        if ((cur_w >= target and remaining_groups > 0 and
                remaining_ranges >= remaining_groups) or forced):
            day_groups.append(cur)
            cur, cur_w = [], 0
    if cur:
        day_groups.append(cur)
    assert len(day_groups) == days, f"{slug}: got {len(day_groups)} groups"
    readings = []
    for i, group in enumerate(day_groups, start=1):
        passages = []
        for (b, ch, lo, hi) in group:
            label = ref_label(b, ch, lo, hi)
            passages.append({"label": label, "refs": [label]})
        first = passages[0]["label"]
        extra = f" (+{len(passages) - 1} more)" if len(passages) > 1 else ""
        readings.append({
            "day": i,
            "week": (i - 1) // 7 + 1,
            "title": f"{first}{extra}",
            "passages": passages,
        })
    return {
        "title": title,
        "id": plan_id,
        "description": description,
        "category": "Topical",
        "badge": f"{days} days",
        "totalDays": days,
        "attribution": ATTRIBUTION,
        "license": LICENSE,
        "readings": readings,
    }, skipped, total


def main():
    for slug, (pid, title, desc, days) in PLANS.items():
        plan, skipped, total = build_plan(slug, pid, title, desc, days)
        out = ROOT / "assets" / "reading_plans" / f"{pid}.json"
        out.write_text(json.dumps(plan, ensure_ascii=False, indent=2),
                       encoding="utf-8")
        print(f"{pid}: {len(plan['readings'])} days, "
              f"{sum(len(d['passages']) for d in plan['readings'])} passages, "
              f"~{total} words, skipped={skipped} -> {out.name}")


if __name__ == "__main__":
    main()
