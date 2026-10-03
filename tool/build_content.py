#!/usr/bin/env python3
"""Build the offline-first content layout (P2).

Reads the full content-source database (all translations) and produces:
  - assets/bible/bible.db   CORE: kjv + kjv_strongs + cross_references +
                            dictionary + strongs_lexicon (+ app tables at
                            runtime). Never deletable, always self-healed.
  - assets/packs/<id>.db    Bundled, user-deletable packs:
                            swh_ulb, ita_dio, fra_lsg, ron_btf, tgl_ulb
                            (copied to the device on first run; restore =
                            copy from APK, instant and offline).
  - content_packs/<id>.db   Upload-ready downloadable packs (NOT bundled):
                            bbe, web (from the full source) and deu_l12,
                            nld_, por_blj, spa_r09 (from assets/bible stray
                            DBs). Publish to Firebase Storage; see manifest.
  - content_packs/manifest.json  sha256/bytes/verse-counts + metadata for
                            the downloader registry and size display.

Pack format (uniform with core queries): tables `verses` (same 6 columns,
including translation_id) + single-row `translations` (same columns as
core, incl. is_downloaded) + index on (book_number, chapter, verse).

Usage:  python3 tool/build_content.py [--check-only]

--check-only verifies the current assets/ layout without modifying it.
"""
import hashlib
import json
import shutil
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FULL_DB = ROOT / "assets" / "bible" / "bible.db"
CORE_IDS = ("kjv", "kjv_strongs")
BUNDLED_PACK_IDS = ("swh_ulb", "ita_dio", "fra_lsg", "ron_btf", "tgl_ulb")
HOSTED_PACK_SOURCES = {
    # pack_id: source db path (full source covers bbe/web)
    "bbe": FULL_DB,
    "web": FULL_DB,
    "deu_l12": ROOT / "assets" / "bible" / "bible_deu_l12.db",
    "nld_": ROOT / "assets" / "bible" / "bible_nld_.db",
    "por_blj": ROOT / "assets" / "bible" / "bible_por_blj.db",
    "spa_r09": ROOT / "assets" / "bible" / "bible_spa_r09.db",
}
PACKS_DIR = ROOT / "assets" / "packs"
UPLOAD_DIR = ROOT / "content_packs"

VERSES_DDL = """CREATE TABLE verses (
  translation_id TEXT NOT NULL,
  language_code  TEXT NOT NULL,
  book_number    INTEGER NOT NULL,
  chapter        INTEGER NOT NULL,
  verse          INTEGER NOT NULL,
  text           TEXT NOT NULL
)"""
TRANSLATIONS_DDL = """CREATE TABLE translations (
  translation_id   TEXT PRIMARY KEY,
  language_code    TEXT NOT NULL,
  language_name    TEXT NOT NULL,
  translation_name TEXT NOT NULL,
  abbreviation     TEXT NOT NULL,
  license          TEXT NOT NULL,
  is_complete      INTEGER NOT NULL DEFAULT 0,
  is_downloaded    INTEGER NOT NULL DEFAULT 0
)"""
PACK_INDEX = ("CREATE INDEX idx_verses_pack ON "
              "verses(book_number, chapter, verse)")

EXPECTED_CORE_TABLES = (
    "verses", "translations", "dictionary",
    "cross_references", "strongs_lexicon",
)


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(4 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def quick_check(path):
    con = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    try:
        val = con.execute("PRAGMA quick_check").fetchone()[0]
        assert val == "ok", f"{path}: quick_check={val}"
    finally:
        con.close()


def count(con, sql, args=()):
    return con.execute(sql, args).fetchone()[0]


def translation_row(con, tid):
    cols = ("translation_id, language_code, language_name, translation_name,"
            " abbreviation, license, is_complete")
    r = con.execute(
        f"SELECT {cols} FROM translations WHERE translation_id=?", (tid,)
    ).fetchone()
    assert r is not None, f"missing translations row for {tid}"
    keys = ("translation_id", "language_code", "language_name",
            "translation_name", "abbreviation", "license", "is_complete")
    return dict(zip(keys, r))


def build_pack(source_db, tid, out_path, downloaded):
    """Extract one translation into a standalone pack DB."""
    if out_path.exists():
        out_path.unlink()
    src = sqlite3.connect(f"file:{source_db}?mode=ro", uri=True)
    try:
        meta = translation_row(src, tid)
        n = count(src, "SELECT COUNT(*) FROM verses WHERE translation_id=?",
                  (tid,))
        assert n > 30000, f"{tid}: suspicious verse count {n}"
        dst = sqlite3.connect(out_path)
        try:
            dst.execute(VERSES_DDL)
            dst.execute(TRANSLATIONS_DDL)
            # Copy via attached source for speed and exactness.
            dst.execute(f"ATTACH DATABASE '{source_db}' AS source")
            dst.execute(
                "INSERT INTO verses SELECT translation_id, language_code,"
                " book_number, chapter, verse, text FROM source.verses"
                " WHERE translation_id=?", (tid,),
            )
            dst.execute(
                "INSERT INTO translations (translation_id, language_code,"
                " language_name, translation_name, abbreviation, license,"
                " is_complete, is_downloaded) VALUES (?,?,?,?,?,?,?,?)",
                (meta["translation_id"], meta["language_code"],
                 meta["language_name"], meta["translation_name"],
                 meta["abbreviation"], meta["license"],
                 meta["is_complete"], 1 if downloaded else 0),
            )
            dst.execute(PACK_INDEX)
            dst.commit()
            dst.execute("VACUUM")
        finally:
            dst.close()
    finally:
        src.close()
    # Verify: counts match + spot-read Gen 1:1 equals source text.
    s = sqlite3.connect(f"file:{source_db}?mode=ro", uri=True)
    p = sqlite3.connect(f"file:{out_path}?mode=ro", uri=True)
    try:
        want = count(s, "SELECT COUNT(*) FROM verses WHERE translation_id=?",
                     (tid,))
        got = count(p, "SELECT COUNT(*) FROM verses")
        assert want == got, f"{tid}: count {got} != {want}"
        w = s.execute("SELECT text FROM verses WHERE translation_id=? AND"
                      " book_number=1 AND chapter=1 AND verse=1",
                      (tid,)).fetchone()[0]
        g = p.execute("SELECT text FROM verses WHERE book_number=1 AND"
                      " chapter=1 AND verse=1").fetchone()[0]
        assert w == g, f"{tid}: Gen 1:1 mismatch"
        assert count(p, "SELECT COUNT(*) FROM translations") == 1
    finally:
        s.close()
        p.close()
    quick_check(out_path)
    meta["is_downloaded"] = 1 if downloaded else 0
    return {"id": tid, "verses": got, "meta": meta}


def build_core(full_db, out_path):
    import os
    import tempfile
    fd, tmp = tempfile.mkstemp(suffix=".db", dir=str(out_path.parent))
    os.close(fd)
    try:
        shutil.copy(full_db, tmp)
        con = sqlite3.connect(tmp)
        try:
            keep = ",".join(f"'{t}'" for t in CORE_IDS)
            con.execute(
                f"DELETE FROM verses WHERE translation_id NOT IN ({keep})")
            con.execute(
                f"DELETE FROM translations WHERE translation_id NOT IN ({keep})")
            con.commit()
            con.execute("VACUUM")
            tables = {r[0] for r in con.execute(
                "SELECT name FROM sqlite_master WHERE type='table'")}
            for t in EXPECTED_CORE_TABLES:
                assert t in tables, f"core missing table {t}"
            assert count(con, "SELECT COUNT(*) FROM verses WHERE"
                              " translation_id='kjv'") == 31102
            assert count(con, "SELECT COUNT(*) FROM verses WHERE"
                              " translation_id='kjv_strongs'") == 31102
            assert count(con, "SELECT COUNT(*) FROM translations") == 2
            assert count(con, "SELECT COUNT(*) FROM cross_references") == 857710
            assert count(con, "SELECT COUNT(*) FROM dictionary") == 8686
            assert count(con, "SELECT COUNT(*) FROM strongs_lexicon") == 14197
        finally:
            con.close()
        os.replace(tmp, out_path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)
    quick_check(out_path)


def mb(path):
    return path.stat().st_size / (1 << 20)


def manifest_entry(path, extra):
    return {
        "file": path.name,
        "bytes": path.stat().st_size,
        "sizeMB": round(mb(path), 2),
        "sha256": sha256_of(path),
        **extra,
    }


def check_only():
    """Verify the current assets/ layout without modifying it."""
    core = ROOT / "assets" / "bible" / "bible.db"
    assert core.exists(), "core db missing"
    quick_check(core)
    con = sqlite3.connect(f"file:{core}?mode=ro", uri=True)
    try:
        tids = [r[0] for r in con.execute(
            "SELECT translation_id FROM translations ORDER BY 1")]
        assert tids == ["kjv", "kjv_strongs"], f"core translations: {tids}"
        assert count(con, "SELECT COUNT(*) FROM verses") == 62204, \
            "core verse count"
    finally:
        con.close()
    for tid in BUNDLED_PACK_IDS:
        p = PACKS_DIR / f"{tid}.db"
        assert p.exists(), f"missing pack {tid}"
        quick_check(p)
    print(f"core: {mb(core):.1f} MB")
    total = mb(core)
    for tid in BUNDLED_PACK_IDS:
        m = mb(PACKS_DIR / f"{tid}.db")
        total += m
        print(f"pack {tid}: {m:.1f} MB")
    print(f"total bundled bible content: {total:.1f} MB")
    print("CHECK OK")


def main():
    if "--check-only" in sys.argv:
        return check_only()

    # Sanity on the source before touching anything.
    src = sqlite3.connect(f"file:{FULL_DB}?mode=ro", uri=True)
    try:
        tids = sorted(r[0] for r in src.execute(
            "SELECT translation_id FROM translations"))
        need = sorted([*CORE_IDS, *BUNDLED_PACK_IDS, "bbe", "web"])
        assert tids == need, f"source translations: {tids}"
    finally:
        src.close()

    PACKS_DIR.mkdir(parents=True, exist_ok=True)
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {"core": {}, "packs": {}, "upload_packs": {}}

    print("== bundled packs ==")
    for tid in BUNDLED_PACK_IDS:
        out = PACKS_DIR / f"{tid}.db"
        info = build_pack(FULL_DB, tid, out, downloaded=False)
        manifest["packs"][tid] = manifest_entry(out, info)
        print(f"  {tid}: {info['verses']} verses, "
              f"{mb(out):.2f} MB  sha256={manifest['packs'][tid]['sha256'][:12]}…")

    print("== upload packs ==")
    for tid, source in HOSTED_PACK_SOURCES.items():
        assert source.exists(), f"missing source for {tid}: {source}"
        out = UPLOAD_DIR / f"{tid}.db"
        info = build_pack(source, tid, out, downloaded=True)
        manifest["upload_packs"][tid] = manifest_entry(out, info)
        print(f"  {tid}: {info['verses']} verses, "
              f"{mb(out):.2f} MB  sha256={manifest['upload_packs'][tid]['sha256'][:12]}…")

    print("== core ==")
    build_core(FULL_DB, ROOT / "assets" / "bible" / "bible.db")
    core = ROOT / "assets" / "bible" / "bible.db"
    manifest["core"] = manifest_entry(core, {"translations": list(CORE_IDS)})

    (UPLOAD_DIR / "manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")

    total = mb(core) + sum(mb(PACKS_DIR / f"{t}.db") for t in BUNDLED_PACK_IDS)
    print(f"core: {mb(core):.1f} MB; bundled packs total: "
          f"{total - mb(core):.1f} MB; grand total: {total:.1f} MB")
    print("BUILD OK — verify, then delete the replaced full-size asset only")
    print("via P2 code review (row counts above are the acceptance check).")


if __name__ == "__main__":
    sys.exit(main())
