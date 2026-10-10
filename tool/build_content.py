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
# Legacy full 9-translation source DB (pre-split). It no longer lives in the
# tree; to rebuild from scratch, materialize it from git history (LFS) and
# pass --full-source <path>. Day-to-day verification uses --check-only.
CORE_IDS = ("kjv", "bbe")
BUNDLED_PACK_IDS = ("swh_ulb", "ita_dio", "fra_lsg", "ron_btf", "tgl_ulb")
# Upload packs rebuildable from a legacy full source DB.
FULL_SOURCE_PACKS = ("web", "kjv_strongs")
# Upload packs whose only durable source is their content_packs file itself
# (original stray DBs were removed after extraction).
SELF_SOURCED_PACKS = ("deu_l12", "nld_", "por_blj", "spa_r09")
EXPECTED_UPLOAD_IDS = ("web", "kjv_strongs",
                       "deu_l12", "nld_", "por_blj", "spa_r09")
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
        assert tids == ["bbe", "kjv"], f"core translations: {tids}"
        assert count(con, "SELECT COUNT(*) FROM verses") == 62204, \
            "core verse count"
        assert count(con, "SELECT COUNT(*) FROM verses WHERE"
                          " translation_id='bbe'") == 31102
    finally:
        con.close()
    for tid in BUNDLED_PACK_IDS:
        p = PACKS_DIR / f"{tid}.db"
        assert p.exists(), f"missing pack {tid}"
        quick_check(p)
    manifest_path = UPLOAD_DIR / "manifest.json"
    assert manifest_path.exists(), "upload manifest missing"
    manifest = json.loads(manifest_path.read_text())
    assert sorted(manifest["upload_packs"].keys()) == sorted(
        EXPECTED_UPLOAD_IDS), f"upload ids: {sorted(manifest['upload_packs'].keys())}"
    for tid in EXPECTED_UPLOAD_IDS:
        p = UPLOAD_DIR / f"{tid}.db"
        assert p.exists(), f"missing upload pack {tid}"
        quick_check(p)
        c = sqlite3.connect(f"file:{p}?mode=ro", uri=True)
        try:
            n = count(c, "SELECT COUNT(*) FROM verses")
        finally:
            c.close()
        assert n > 30000, f"{tid}: only {n} verses"
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

    args = sys.argv[1:]
    if "--refresh-manifest" in args:
        return refresh_upload_manifest()
    full_source = None
    for a in args:
        if a.startswith("--full-source="):
            full_source = Path(a.split("=", 1)[1])
    if full_source is None:
        print("usage:")
        print("  python3 tool/build_content.py --check-only")
        print("  python3 tool/build_content.py --refresh-manifest")
        print("  python3 tool/build_content.py --full-source=/tmp/full.db")
        print("      (rebuilds web + kjv_strongs upload packs from a legacy")
        print("       9-translation source DB; materialize from git history)")
        return 1

    # Sanity on the legacy source before touching anything.
    assert full_source.exists(), f"missing full source: {full_source}"
    src = sqlite3.connect(f"file:{full_source}?mode=ro", uri=True)
    try:
        tids = sorted(r[0] for r in src.execute(
            "SELECT translation_id FROM translations"))
        for need in ("web", "kjv_strongs"):
            assert need in tids, f"full source lacks {need}: {tids}"
    finally:
        src.close()

    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    manifest_path = UPLOAD_DIR / "manifest.json"
    manifest = json.loads(manifest_path.read_text())

    print("== upload packs from full source ==")
    for tid in FULL_SOURCE_PACKS:
        out = UPLOAD_DIR / f"{tid}.db"
        info = build_pack(full_source, tid, out, downloaded=True)
        manifest["upload_packs"][tid] = manifest_entry(out, info)
        print(f"  {tid}: {info['verses']} verses, "
              f"{mb(out):.2f} MB  sha256={manifest['upload_packs'][tid]['sha256'][:12]}…")

    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    print("BUILD OK — re-upload changed packs, then update the sha256 in")
    print("TranslationDownloader._storagePack entries to match.")


def refresh_upload_manifest():
    """Recompute size/sha/counts for content_packs from the files on disk
    (preserves stored translation metadata)."""
    manifest_path = UPLOAD_DIR / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    for tid in EXPECTED_UPLOAD_IDS:
        out = UPLOAD_DIR / f"{tid}.db"
        assert out.exists(), f"missing upload pack {tid}"
        quick_check(out)
        con = sqlite3.connect(f"file:{out}?mode=ro", uri=True)
        try:
            n = count(con, "SELECT COUNT(*) FROM verses")
        finally:
            con.close()
        assert n > 30000, f"{tid}: only {n} verses"
        entry = manifest["upload_packs"].get(tid, {})
        meta = entry.get("meta", {})
        manifest["upload_packs"][tid] = manifest_entry(
            out, {"id": tid, "verses": n, "meta": meta})
        print(f"  {tid}: {n} verses, {mb(out):.2f} MB")
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    print("MANIFEST REFRESHED")


if __name__ == "__main__":
    sys.exit(main())
