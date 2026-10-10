#!/usr/bin/env python3
"""Refill verses that the old pack builder dropped.

tool/build_bible_db.dart used to keep only plain-string verse pieces
(`.whereType<String>()`). helloao.org stores poetry lines as objects
({"text": ..., "poem": n}), so every poetic verse (most of Psalms, Job,
Proverbs, Song of Solomon, Lamentations ...) was written as ''.

This script re-fetches ONLY the chapters that contain empty verses from
https://bible.helloao.org, flattens poetry correctly, and fills the blanks
in place (rows that are missing entirely are inserted). Nothing else in the
pack is touched. Requires network access; stdlib only.

Usage (from the repo root):
    python3 tool/repair_pack_poetry.py --dry-run          # report only
    python3 tool/repair_pack_poetry.py                    # repair all known packs
    python3 tool/repair_pack_poetry.py assets/packs/fra_lsg.db
Then:  python3 tool/build_content.py --check-only  (and refresh the manifest
for content_packs/ before uploading), and commit the .db files (Git LFS).
"""
import json
import sqlite3
import sys
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
API = 'https://bible.helloao.org/api'

# pack translation_id -> helloao translation id
API_IDS = {
    'fra_lsg': 'fra_lsg', 'ita_dio': 'ita_dio', 'deu_l12': 'deu_l12',
    'spa_r09': 'spa_r09', 'ron_btf': 'ron_btf', 'swh_ulb': 'swh_ulb',
    'tgl_ulb': 'tgl_ulb', 'nld_': 'nld_', 'por_blj': 'por_blj',
    'web': 'ENGWEBP',
}
DEFAULT_PACKS = [
    'assets/packs/fra_lsg.db', 'assets/packs/ita_dio.db',
    'content_packs/deu_l12.db', 'content_packs/spa_r09.db',
    'content_packs/web.db',
]
USFM = ('GEN EXO LEV NUM DEU JOS JDG RUT 1SA 2SA 1KI 2KI 1CH 2CH EZR NEH EST '
        'JOB PSA PRO ECC SNG ISA JER LAM EZK DAN HOS JOL AMO OBA JON MIC NAM '
        'HAB ZEP HAG ZEC MAL MAT MRK LUK JHN ACT ROM 1CO 2CO GAL EPH PHP COL '
        '1TH 2TH 1TI 2TI TIT PHM HEB JAS 1PE 2PE 1JN 2JN 3JN JUD REV').split()

# Same normalization the builder applies to every verse.
REPLACEMENTS = [('’', "'"), ('‘', "'"), ('“', '"'),
                ('”', '"'), ('—', '--'), ('–', '-')]


def flatten(pieces):
    """helloao verse content -> plain text (strings, poetry, line breaks)."""
    out = []
    for p in pieces:
        if isinstance(p, str):
            out.append(p)
        elif isinstance(p, dict):
            if isinstance(p.get('text'), str):
                out.append(p['text'])
            elif p.get('lineBreak'):
                out.append(' ')
            # noteId / heading markers carry no verse text
    text = ' '.join(s.strip() for s in out if s and s.strip())
    for a, b in REPLACEMENTS:
        text = text.replace(a, b)
    return ' '.join(text.split())


def fetch_chapter(api_id, book_no, chapter):
    url = f'{API}/{api_id}/{USFM[book_no - 1]}/{chapter}.json'
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'BlessedBible-content-repair'})
            with urllib.request.urlopen(req, timeout=30) as r:
                data = json.load(r)
            verses = {}
            for item in data['chapter']['content']:
                if item.get('type') == 'verse':
                    verses[int(item['number'])] = flatten(item.get('content', []))
            return verses
        except Exception as e:  # noqa: BLE001 - retry any transient failure
            if attempt == 3:
                raise RuntimeError(f'{url}: {e}') from e
            time.sleep(1.5 * (attempt + 1))


def repair(path, dry_run):
    con = sqlite3.connect(path)
    tid, lang = con.execute(
        'SELECT translation_id, language_code FROM translations LIMIT 1').fetchone()
    api_id = API_IDS.get(tid)
    if not api_id:
        print(f'{path}: no helloao mapping for {tid}, skipped')
        return 0
    chapters = con.execute(
        "SELECT DISTINCT book_number, chapter FROM verses "
        "WHERE text IS NULL OR trim(text) = '' ORDER BY 1, 2").fetchall()
    before = con.execute(
        "SELECT count(*) FROM verses WHERE text IS NULL OR trim(text) = ''").fetchone()[0]
    print(f'{path} ({tid}): {before} empty verses in {len(chapters)} chapters')
    if dry_run or not chapters:
        return before
    filled = still_empty = 0
    for i, (book, ch) in enumerate(chapters, 1):
        src = fetch_chapter(api_id, book, ch)
        rows = con.execute(
            "SELECT verse FROM verses WHERE book_number=? AND chapter=? "
            "AND (text IS NULL OR trim(text)='')", (book, ch)).fetchall()
        for (v,) in rows:
            text = src.get(v, '')
            if text:
                con.execute('UPDATE verses SET text=? WHERE book_number=? AND '
                            'chapter=? AND verse=?', (text, book, ch, v))
                filled += 1
            else:
                still_empty += 1
        if i % 25 == 0:
            con.commit()
            print(f'  {i}/{len(chapters)} chapters ...')
        time.sleep(0.15)  # be polite to the free API
    con.commit()
    con.execute('VACUUM')
    ok = con.execute('PRAGMA quick_check').fetchone()[0]
    con.close()
    print(f'  filled {filled}, still empty {still_empty} '
          f'(verses genuinely absent from this translation), quick_check={ok}')
    return still_empty


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    dry = '--dry-run' in sys.argv
    paths = args or DEFAULT_PACKS
    for p in paths:
        full = ROOT / p if not Path(p).is_absolute() else Path(p)
        if not full.exists():
            print(f'{p}: missing, skipped')
            continue
        repair(str(full), dry)


if __name__ == '__main__':
    main()
