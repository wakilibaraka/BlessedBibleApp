#!/usr/bin/env python3
"""Check that every downloadable translation in the app resolves on the
Free Use Bible API (bible.helloao.org) and has a complete 66-book text.

Usage:
  python3 tool/check_translation_sources.py           # verify the catalog
  python3 tool/check_translation_sources.py --find ron deu   # list API
      translations for these ISO 639-3 language codes (id, name, license)

The catalog is read from lib/services/translation_downloader.dart: the
`_helloao('<id>', ...)` entries, plus 'prebuilt' packs (downloaded and
sha256-checked). CI runs the verify mode.
"""
import hashlib
import json
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG = os.path.join(ROOT, "lib", "services", "translation_downloader.dart")
API = "https://bible.helloao.org/api"


def get_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "blessed-bible-ci/1.0"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.load(r)


def catalog_ids():
    """Download ids of the `_helloao('<id>', ...)` catalog entries."""
    src = open(CATALOG, encoding="utf-8").read()
    return re.findall(r"_helloao\(\s*'([^']+)'", src)


def prebuilt_packs():
    """(id, url, sha256) for 'prebuilt' entries, resolving the Dart const."""
    src = open(CATALOG, encoding="utf-8").read()
    base = re.search(r"_repoPacksBase =\s*'([^']+)'", src).group(1)
    packs = []
    for block in re.findall(r"\{[^{}]*'source':\s*'prebuilt'[^{}]*\}", src):
        pid = re.search(r"'id':\s*'([^']+)'", block).group(1)
        url = re.search(r"'url':\s*'([^']+)'", block).group(1).replace("$_repoPacksBase", base)
        sha = re.search(r"'sha256':\s*'([0-9a-f]{64})'", block).group(1)
        packs.append((pid, url, sha))
    return packs


def find(langs):
    data = get_json(f"{API}/available_translations.json")
    for t in data["translations"]:
        if t.get("language") in langs:
            print(json.dumps({k: t.get(k) for k in (
                "id", "name", "englishName", "language", "shortName",
                "licenseUrl", "website", "numberOfBooks", "totalNumberOfChapters",
                "totalNumberOfVerses")}, ensure_ascii=False))


def verify():
    ids = catalog_ids()
    if not ids:
        sys.exit("No helloao entries found in the catalog")
    available = {t["id"]: t for t in get_json(f"{API}/available_translations.json")["translations"]}
    failed = False
    for tid in ids:
        meta = available.get(tid)
        if meta is None:
            print(f"FAIL {tid}: not listed in available_translations.json")
            failed = True
            continue
        complete = get_json(f"{API}/{tid}/complete.json")
        books = [b for b in complete["books"] if not b.get("isApocryphal")]
        verses = sum(
            1
            for b in books
            for c in b["chapters"]
            for item in c["chapter"]["content"]
            if item.get("type") == "verse"
        )
        ok = len(books) == 66 and verses > 30000
        failed |= not ok
        print(f"{'OK  ' if ok else 'FAIL'} {tid}: {meta.get('englishName')} | books={len(books)} verses={verses} | {meta.get('licenseUrl')}")
    for pid, url, sha in prebuilt_packs():
        req = urllib.request.Request(url, headers={"User-Agent": "blessed-bible-ci/1.0"})
        with urllib.request.urlopen(req, timeout=300) as r:
            digest = hashlib.sha256(r.read()).hexdigest()
        ok = digest == sha
        failed |= not ok
        print(f"{'OK  ' if ok else 'FAIL'} {pid}: prebuilt pack sha256 {'matches' if ok else 'is ' + digest}")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    if "--find" in sys.argv:
        find(sys.argv[sys.argv.index("--find") + 1:])
    else:
        verify()
