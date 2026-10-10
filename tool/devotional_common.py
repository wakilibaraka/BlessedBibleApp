#!/usr/bin/env python3
"""Shared constants for The Graham Bible -> BlessedBibleApp port tooling.

Data source: graham-devotional's public Supabase REST endpoint.
The anon key below is published in that project's viewer/config.js and is
protected by Row Level Security; it only grants read access to the
devotional spreads table. Do NOT put private keys in this file.
"""

import json
import os
import sys
import time
import urllib.request

SUPABASE_URL = "https://zekbemqgvupzmukpntog.supabase.co/rest/v1/grahams_devotional_spreads"
ANON_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
    "eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpla2JlbXFndnVwem11a3BudG9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NjI2MTIsImV4cCI6MjA4MDEzODYxMn0."
    "D6YxknCEeqhp1-9MBS-CZ31Bu4_dH6JV5T1d5Ud92Bo"
)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DEVOTIONAL = os.path.join(REPO_ROOT, "assets", "devotional")
STORIES_DIR = os.path.join(ASSETS_DEVOTIONAL, "stories")
ART_DIR = os.path.join(ASSETS_DEVOTIONAL, "art")
FONTS_DIR = os.path.join(REPO_ROOT, "assets", "fonts")
TOOLS_DATA_DIR = os.path.join(REPO_ROOT, "tool", "data")

ATTRIBUTION = (
    "Scripture quotations are from the King James Version (public domain). "
    "Narrative summaries adapted from The Graham Bible (grahambible.com); "
    "AI-assisted, human reviewed. Artwork: Gustave Dore (1832-1883), public domain, "
    "via Wikimedia Commons."
)

# spread_code prefix -> (display name, testament, grouping, chronological order)
SECTIONS = [
    ("GEN", "Genesis", "OT", "Torah", 0),
    ("EXO", "Exodus", "OT", "Torah", 1),
    ("LEV", "Leviticus", "OT", "Torah", 2),
    ("NUM", "Numbers", "OT", "Torah", 3),
    ("DEU", "Deuteronomy", "OT", "Torah", 4),
    ("JOS", "Joshua", "OT", "History", 5),
    ("JDG", "Judges", "OT", "History", 6),
    ("RUT", "Ruth", "OT", "History", 7),
    ("1SA", "1 Samuel", "OT", "History", 8),
    ("2SA", "2 Samuel", "OT", "History", 9),
    ("1KI", "1 Kings", "OT", "History", 10),
    ("2KI", "2 Kings", "OT", "History", 11),
    ("1CH", "1 Chronicles", "OT", "History", 12),
    ("2CH", "2 Chronicles", "OT", "History", 13),
    ("EZR", "Ezra", "OT", "History", 14),
    ("NEH", "Nehemiah", "OT", "History", 15),
    ("EST", "Esther", "OT", "History", 16),
    ("JOB", "Job", "OT", "Poetry", 17),
    ("PSA", "Psalms", "OT", "Poetry", 18),
    ("PRO", "Proverbs", "OT", "Poetry", 19),
    ("ECC", "Ecclesiastes", "OT", "Poetry", 20),
    ("SNG", "Song of Solomon", "OT", "Poetry", 21),
    ("ISA", "Isaiah", "OT", "Prophets", 22),
    ("JER", "Jeremiah", "OT", "Prophets", 23),
    ("LAM", "Lamentations", "OT", "Prophets", 24),
    ("EZK", "Ezekiel", "OT", "Prophets", 25),
    ("DAN", "Daniel", "OT", "Prophets", 26),
    ("HOS", "Hosea", "OT", "Prophets", 27),
    ("JOE", "Joel", "OT", "Prophets", 28),
    ("AMO", "Amos", "OT", "Prophets", 29),
    ("OBA", "Obadiah", "OT", "Prophets", 30),
    ("JON", "Jonah", "OT", "Prophets", 31),
    ("MIC", "Micah", "OT", "Prophets", 32),
    ("NAH", "Nahum", "OT", "Prophets", 33),
    ("HAB", "Habakkuk", "OT", "Prophets", 34),
    ("ZEP", "Zephaniah", "OT", "Prophets", 35),
    ("HAG", "Haggai", "OT", "Prophets", 36),
    ("ZEC", "Zechariah", "OT", "Prophets", 37),
    ("MAL", "Malachi", "OT", "Prophets", 38),
    ("GSP", "The Gospels", "NT", "Gospels", 39),
    ("ACT", "Acts", "NT", "Acts", 40),
    ("ROM", "Romans", "NT", "Epistles", 41),
    ("1CO", "1 Corinthians", "NT", "Epistles", 42),
    ("2CO", "2 Corinthians", "NT", "Epistles", 43),
    ("GAL", "Galatians", "NT", "Epistles", 44),
    ("EPH", "Ephesians", "NT", "Epistles", 45),
    ("PHP", "Philippians", "NT", "Epistles", 46),
    ("COL", "Colossians", "NT", "Epistles", 47),
    ("1TH", "1 Thessalonians", "NT", "Epistles", 48),
    ("2TH", "2 Thessalonians", "NT", "Epistles", 49),
    ("1TI", "1 Timothy", "NT", "Epistles", 50),
    ("2TI", "2 Timothy", "NT", "Epistles", 51),
    ("TIT", "Titus", "NT", "Epistles", 52),
    ("PHM", "Philemon", "NT", "Epistles", 53),
    ("HEB", "Hebrews", "NT", "Epistles", 54),
    ("JAS", "James", "NT", "Epistles", 55),
    ("1PE", "1 Peter", "NT", "Epistles", 56),
    ("2PE", "2 Peter", "NT", "Epistles", 57),
    ("1JO", "1 John", "NT", "Epistles", 58),
    ("2JO", "2 John", "NT", "Epistles", 59),
    ("3JO", "3 John", "NT", "Epistles", 60),
    ("JUD", "Jude", "NT", "Epistles", 61),
    ("REV", "Revelation", "NT", "Revelation", 62),
]

SECTION_MAP = {code: (name, testament, grouping, order) for code, name, testament, grouping, order in SECTIONS}


def log(msg: str) -> None:
    print(msg, flush=True)


def ensure_dirs() -> None:
    for d in (ASSETS_DEVOTIONAL, STORIES_DIR, ART_DIR, TOOLS_DATA_DIR):
        os.makedirs(d, exist_ok=True)


def http_get(url: str, headers=None, timeout: int = 60, retries: int = 4) -> bytes:
    """GET with retry and exponential backoff."""
    hdrs = {"User-Agent": "BlessedBibleApp-port-tooling/1.0 (contact: developer)"}
    if headers:
        hdrs.update(headers)
    last_err = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=hdrs)
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.read()
        except Exception as e:  # noqa: BLE001
            last_err = e
            wait = min(2 ** attempt * 2, 30)
            log(f"  retry {attempt + 1}/{retries} in {wait}s: {e}")
            time.sleep(wait)
    raise RuntimeError(f"GET failed for {url}: {last_err}")


def supabase_query(params: str, timeout: int = 120) -> list:
    """GET rows from the public spreads view. params uses PostgREST syntax."""
    url = f"{SUPABASE_URL}?{params}"
    data = http_get(url, headers={"apikey": ANON_KEY}, timeout=timeout)
    rows = json.loads(data)
    if isinstance(rows, dict):  # error payload
        raise RuntimeError(f"Supabase error: {rows}")
    return rows


def save_json(path: str, obj, sort_keys: bool = False) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, separators=(",", ":"), sort_keys=sort_keys)


def die(msg: str) -> None:
    log(f"ERROR: {msg}")
    sys.exit(1)
