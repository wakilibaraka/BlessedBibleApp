"""Builds lib/l10n/app_<lang>.arb from the fragments in tool/l10n/parts/.

Each fragment is JSON: {"key": {"en": "...", "fr": "...", ..., "@": {meta}}}.
Splitting strings by area lets several people (or agents) add strings at
once without fighting over one huge file. Run after editing a fragment:

    python3 tool/l10n/merge_arb.py && flutter gen-l10n
"""
import glob
import json
import os
import sys

LANGS = ["en", "fr", "it", "ro", "sw", "tl"]
root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
out = {l: {"@@locale": l} for l in LANGS}
seen = {}
problems = []
for path in sorted(glob.glob(os.path.join(root, "tool/l10n/parts/*.json"))):
    with open(path, encoding="utf-8") as f:
        part = json.load(f)
    for key, entry in part.items():
        if key in seen:
            problems.append(f"{key}: defined in {seen[key]} and {path}")
            continue
        seen[key] = path
        for l in LANGS:
            if l not in entry:
                problems.append(f"{key}: missing {l} in {os.path.basename(path)}")
                continue
            out[l][key] = entry[l]
        if "@" in entry:
            out["en"]["@" + key] = entry["@"]
if problems:
    print("\n".join(problems))
    sys.exit(1)
for l in LANGS:
    with open(os.path.join(root, f"lib/l10n/app_{l}.arb"), "w", encoding="utf-8") as f:
        json.dump(out[l], f, ensure_ascii=False, indent=2)
        f.write("\n")
print(f"{len(seen)} strings x {len(LANGS)} languages")
