#!/usr/bin/env python3
"""Refine dictionary underline tiers for difficult/contested-word marking.

Reads `assets/data/dictionary_words.json` (hand-curated base tiers:
term / tricky / common) plus the offline database, and writes:

1. `assets/data/dictionary_words.json` (updated in place):
   - `contested` tier for theologically contested or easily
     misunderstood words (hell, baptism, easter, ghost, ...). These were
     `term`/`tricky` before; classic scopes keep matching them, so
     classic behavior is unchanged.
   - New entries for contested words missing from the file
     (baptism verbs, singulars); definitions resolve via
     `dictionary_aliases.json`.
2. `assets/data/dictionary_names.json`: biblical proper names, derived
   from mid-verse capitalization in the KJV text (verse-initial tokens
   are skipped so sentence starts like "And" never qualify; a >=50%
   capitalization ratio separates true names from words capitalized
   only after intra-verse sentence breaks), intersected with words that
   actually have definitions.
3. `assets/data/dictionary_aliases.json`: token -> normalized_word for
   contested words whose definition lives under another headword
   (baptize -> baptism, seraph -> seraphim, ...). Verified against the
   `dictionary` table.

Tokenization matches the app exactly: `[a-zA-Z]+`, lowercased for
matching. Idempotent: re-running produces identical files.

Usage:
  python3 tool/build_dictionary_tiers.py [--check-only]
"""

import json
import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB = ROOT / "assets" / "bible" / "bible.db"
WORDS_JSON = ROOT / "assets" / "data" / "dictionary_words.json"
NAMES_JSON = ROOT / "assets" / "data" / "dictionary_names.json"
ALIASES_JSON = ROOT / "assets" / "data" / "dictionary_aliases.json"

# Words whose meaning is disputed across traditions, or whose KJV sense
# misleads modern readers. Drafted from standard KJV-controversy sets
# (hell/sheol/hades/gehenna, baptism, church, sabbath, soul/spirit/
# ghost, easter, charity, lucifer, LORD/Lord, ...). `lord` is in by
# design: LORD-vs-Lord is the classic contested typography question.
CONTESTED = [
    "hell", "sheol", "hades", "gehenna", "paradise",
    "baptism", "baptize", "church",
    "repent", "repentance", "atonement", "justification",
    "sanctification", "propitiation", "redemption", "reprobate",
    "spirit", "ghost", "sabbath", "tithe",
    "elder", "bishop", "deacon", "saint", "apostle", "disciple",
    "prophet", "priest", "temple", "tabernacle", "ark",
    "covenant", "testament", "altar", "sacrifice",
    "easter", "charity", "lucifer", "devil", "satan", "demon",
    "angel", "cherub", "miracle", "parable", "gospel",
    "zion", "amen", "hallelujah", "selah", "messiah",
    "lord", "jehovah", "seraph", "gentile", "kingdom",
]

# Token -> normalized_word, each target verified to exist in the
# `dictionary` table. Keeps every underline resolvable (the app never
# underlines a word with no definition).
ALIASES = {
    "baptize": "baptism",
    "seraph": "seraphim",
    "gentile": "gentiles",
    "kingdom": "kingdomofgod",
}

# Capitalized mid-verse but not a name for this feature's purposes.
# (`lord` is `contested` anyway; `god` stays an unmarked easy word.)
NAME_EXCLUSIONS = {"god", "lord", "ah", "aha", "nay"}


def main() -> int:
    check_only = "--check-only" in sys.argv
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)

    words = json.loads(WORDS_JSON.read_text())
    db_words = set(
        r[0] for r in con.execute("select distinct normalized_word from dictionary")
    )

    # --- 1. contested tier -------------------------------------------
    retiered, added = [], []
    for w in CONTESTED:
        target = ALIASES.get(w, w)
        assert target in db_words, f"contested word has no definition: {w} -> {target}"
        if w in words:
            if words[w] != "contested":
                words[w] = "contested"
                retiered.append(w)
        else:
            words[w] = "contested"
            added.append(w)

    # --- 2. names from mid-verse capitalization ------------------------
    # A true proper name is capitalized almost every time it appears
    # mid-verse (jesus, moses); ordinary words only pick up capitals
    # after intra-verse sentence breaks (brother, light). The >=50%
    # ratio separates the two without a hand list.
    cap_counts: dict[str, int] = {}
    total_counts: dict[str, int] = {}
    for (text,) in con.execute(
        "select text from verses where translation_id='kjv'"
    ):
        text = re.sub(r"\[[HG]\d+\]", "", text)
        toks = re.findall(r"[a-zA-Z]+", text)
        for tok in toks[1:]:  # skip verse-initial token (sentence case)
            if len(tok) < 2:
                continue
            w = tok.lower()
            total_counts[w] = total_counts.get(w, 0) + 1
            if re.fullmatch(r"[A-Z][a-z]+", tok):
                cap_counts[w] = cap_counts.get(w, 0) + 1
    names = sorted(
        w
        for w, n in cap_counts.items()
        if n >= 2
        and n / total_counts[w] >= 0.5
        and w in words
        and w not in NAME_EXCLUSIONS
    )

    outputs = {
        WORDS_JSON: json.dumps(words, indent=2, ensure_ascii=False) + "\n",
        NAMES_JSON: json.dumps(names, indent=2) + "\n",
        ALIASES_JSON: json.dumps(ALIASES, indent=2, sort_keys=True) + "\n",
    }

    if check_only:
        drift = [str(p) for p, want in outputs.items()
                 if not p.exists() or p.read_text() != want]
        if drift:
            print("DRIFT:", drift)
            return 1
        print("dictionary tiers: in sync "
              f"({len(retiered)} retiered, {len(added)} added, "
              f"{len(names)} names, {len(ALIASES)} aliases)")
        return 0

    for p, want in outputs.items():
        p.write_text(want)
    print(f"contested: {len(retiered)} retiered + {len(added)} added "
          f"({added})")
    print(f"names: {len(names)} | aliases: {len(ALIASES)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
