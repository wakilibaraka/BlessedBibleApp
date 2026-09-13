#!/usr/bin/env python3
"""
Scrapes Ellen G. White's "The Acts of the Apostles" (EGW Writings book 127)
and generates commentary entries mapped to Acts chapters/verses,
matching the existing commentary.json schema exactly.

Run from the project root:
    python3 scripts/build_egw_aa_commentary.py

Output: scripts/egw_aa_commentary_new.json
Then inspect and manually merge into assets/commentary/commentary.json.
"""

import json
import re
import time
import urllib.request
from html.parser import HTMLParser

# ── EGW AA TOC: chapter_node → (AA chapter title, Acts verse range string) ──
# We must verify the "based on" range by fetching each chapter.
# For safety we hard-code the TOC node IDs extracted from /en/book/127/toc.
TOC_NODES = [
    (22, "Chapter 1—God's Purpose for His Church"),
    (53, "Chapter 2—The Training of the Twelve"),
    (86, "Chapter 3—The Great Commission"),
    (128, "Chapter 4—Pentecost"),
    (180, "Chapter 5—The Gift of the Spirit"),
    (222, "Chapter 6—At the Temple Gate"),
    (281, "Chapter 7—A Warning Against Hypocrisy"),
    (312, "Chapter 8—Before the Sanhedrin"),
    (355, "Chapter 9—The Seven Deacons"),
    (396, "Chapter 10—The First Christian Martyr"),
    (422, "Chapter 11—The Gospel in Samaria"),
    (463, "Chapter 12—From Persecutor to Disciple"),
    (516, "Chapter 13—Days of Preparation"),
    (551, "Chapter 14—A Seeker for Truth"),
    (614, "Chapter 15—Delivered From Prison"),
    (672, "Chapter 16—The Gospel Message in Antioch"),
    (719, "Chapter 17—Heralds of the Gospel"),
    (772, "Chapter 18—Preaching Among the Heathen"),
    (824, "Chapter 19—Jew and Gentile"),
    (882, "Chapter 20—Exalting the Cross"),
    (926, "Chapter 21—In the Regions Beyond"),
    (972, "Chapter 22—Thessalonica"),
    (1020, "Chapter 23—Berea and Athens"),
    (1076, "Chapter 24—Corinth"),
    (1124, "Chapter 25—The Thessalonian Letters"),
    (1187, "Chapter 26—Apollos at Corinth"),
    (1240, "Chapter 27—Ephesus"),
    (1286, "Chapter 28—Days of Toil and Trial"),
    (1318, "Chapter 29—A Message of Warning and Entreaty"),
    (1365, "Chapter 30—Called to Reach a Higher Standard"),
    (1427, "Chapter 31—The Message Heeded"),
    (1476, "Chapter 32—A Liberal Church"),
    (1525, "Chapter 33—Laboring Under Difficulties"),
    (1582, "Chapter 34—A Consecrated Ministry"),
    (1638, "Chapter 35—Salvation to the Jews"),
    (1682, "Chapter 36—Apostasy in Galatia"),
    (1709, "Chapter 37—Paul's Last Journey to Jerusalem"),
    (1757, "Chapter 38—Paul a Prisoner"),
    (1849, "Chapter 39—The Trial at Caesarea"),
    (1890, "Chapter 40—Paul Appeals to Caesar"),
    (1909, "Chapter 41—\"Almost Thou Persuadest Me\""),
    (1939, "Chapter 42—The Voyage and Shipwreck"),
    (1976, "Chapter 43—In Rome"),
    (2039, "Chapter 44—Caesar's Household"),
    (2074, "Chapter 45—Written From Rome"),
    (2144, "Chapter 46—At Liberty"),
    (2162, "Chapter 47—The Final Arrest"),
    (2174, "Chapter 48—Paul Before Nero"),
    (2201, "Chapter 49—Paul's Last Letter"),
    (2250, "Chapter 50—Condemned to Die"),
    (2269, "Chapter 51—A Faithful Under-Shepherd"),
    (2335, "Chapter 52—Steadfast Unto the End"),
    (2377, "Chapter 53—John the Beloved"),
    (2409, "Chapter 54—A Faithful Witness"),
    (2454, "Chapter 55—Transformed by Grace"),
    (2496, "Chapter 56—Patmos"),
    (2541, "Chapter 57—The Revelation"),
    (2611, "Chapter 58—The Church Triumphant"),
]

ACTS_CHAPTERS = 28  # Acts has 28 chapters

class ParagraphExtractor(HTMLParser):
    """Extracts text of <p class="egw_content_wrapper ..."> paragraphs."""
    def __init__(self):
        super().__init__()
        self.paragraphs = []       # list of dicts: {text, based_on, refs}
        self._in_para = False
        self._capture = False
        self._buf = []
        self._current_class = ""

    def handle_starttag(self, tag, attrs):
        attrs_d = dict(attrs)
        if tag == "p" and "egw_content_wrapper" in attrs_d.get("class", ""):
            self._in_para = True
            self._capture = True
            self._buf = []
            self._current_class = attrs_d.get("class", "")
        if self._in_para and tag == "a":
            href = attrs_d.get("href", "")
            # collect inline bible references as text
            pass

    def handle_endtag(self, tag):
        if tag == "p" and self._capture:
            text = re.sub(r"\s+", " ", "".join(self._buf)).strip()
            # Remove "This chapter is based on..." prefix — capture the ref
            based_on = None
            m = re.search(r"This chapter is based on\s+(Acts\s+[\d:,\-–\s]+)", text, re.I)
            if m:
                based_on = m.group(1).strip()
            # Strip non-egw preface text that is purely the "based on" annotation
            if text and not text.startswith("This chapter is based on"):
                # Find inline Acts references in this paragraph
                refs = re.findall(r"Acts\s+(\d+):(\d+)(?:\s*[-–]\s*(\d+))?", text)
                self.paragraphs.append({
                    "text": text,
                    "based_on": based_on,
                    "refs": [(int(c), int(v)) for c, v, _ in refs]
                })
            self._in_para = False
            self._capture = False
            self._buf = []

    def handle_data(self, data):
        if self._capture:
            self._buf.append(data)


def fetch_page(node_id):
    url = f"https://m.egwwritings.org/en/book/127.{node_id}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        return resp.read().decode("utf-8", errors="replace")


def parse_based_on(html):
    """Extract the 'based on Acts X:Y–Z' info from the chapter HTML.
    The Acts reference may be inside an anchor tag, so we search across tags."""
    # Match 'This chapter is based on' followed by anything (incl. HTML tags) then 'Acts N:N'
    m = re.search(
        r"This chapter is based on.{0,200}?Acts\s+(\d+):(\d+)",
        html, re.I | re.DOTALL
    )
    if m:
        return (int(m.group(1)), int(m.group(2)))
    return None


def extract_acts_refs_from_range(range_str):
    """
    Parse a range like 'Acts 2:1-39' → [(2,1),(2,2),...] first verse only.
    Returns (chapter, start_verse) tuples for the first reference in the range.
    """
    refs = []
    for m in re.finditer(r"Acts\s+(\d+):(\d+)", range_str):
        refs.append((int(m.group(1)), int(m.group(2))))
    return refs


def make_id(acts_ch, acts_v, idx):
    return f"c_egw_aa_acts{acts_ch}_{acts_v}_{idx}"


def build_entry(text, acts_ch, acts_v, idx):
    return {
        "author": "Ellen G. White",
        "source": "The Acts of the Apostles",
        "scope": {
            "type": "verse",
            "book": "Acts",
            "chapter": acts_ch,
            "verse": acts_v,
            "topic": None,
            "custom": None
        },
        "text": text,
        "id": make_id(acts_ch, acts_v, idx)
    }


def distribute_paragraphs(paragraphs, acts_ch, start_verse, min_per_chapter=3):
    """
    Map paragraphs to verses.
    Priority: if a paragraph explicitly mentions Acts X:V, bind to that verse.
    Otherwise, evenly spread first N paragraphs across start_verse, start_verse+1, ...
    Guarantees at least min_per_chapter entries for this chapter.
    """
    entries = []
    verse_idx_counter = {}

    # First pass: bind paragraphs with explicit inline refs
    bound = set()
    for i, para in enumerate(paragraphs):
        for ref_ch, ref_v in para.get("refs", []):
            if ref_ch == acts_ch:
                k = ref_v
                verse_idx_counter[k] = verse_idx_counter.get(k, 0)
                entries.append(build_entry(para["text"], acts_ch, ref_v, verse_idx_counter[k]))
                verse_idx_counter[k] += 1
                bound.add(i)
                break  # bind to first matching ref

    # Second pass: distribute unbound paragraphs to ensure coverage
    unbound = [p for i, p in enumerate(paragraphs) if i not in bound]
    # Take up to first N unbound paragraphs and assign to start_verse, start_verse+1, ...
    target_count = max(0, min_per_chapter - len(bound))
    for j, para in enumerate(unbound[:target_count]):
        v = start_verse + j
        verse_idx_counter[v] = verse_idx_counter.get(v, 0)
        entries.append(build_entry(para["text"], acts_ch, v, verse_idx_counter[v]))
        verse_idx_counter[v] += 1

    return entries


def main():
    all_entries = []
    covered_chapters = set()
    chapter_para_map = {}  # acts_ch → paragraphs

    print(f"Fetching {len(TOC_NODES)} AA chapters from egwwritings.org...\n")

    for node_id, title in TOC_NODES:
        print(f"  Fetching: {title} (node {node_id})...")
        try:
            html = fetch_page(node_id)
        except Exception as e:
            print(f"    ERROR fetching node {node_id}: {e}")
            time.sleep(2)
            continue

        # Find the "based on" Acts reference — returns (chapter, verse) or None
        based_on = parse_based_on(html)
        acts_refs = []
        if based_on:
            acts_refs = [based_on]
            print(f"    Based on: Acts {based_on[0]}:{based_on[1]}")
        else:
            print(f"    No 'based on Acts' annotation found.")

        # Parse paragraphs
        extractor = ParagraphExtractor()
        extractor.feed(html)
        paragraphs = extractor.paragraphs
        # Filter very short paragraphs (section headings etc.)
        paragraphs = [p for p in paragraphs if len(p["text"].split()) > 20]
        print(f"    Paragraphs extracted: {len(paragraphs)}")

        if not acts_refs:
            print(f"    Skipping — could not map to Acts chapter.")
            time.sleep(1)
            continue

        # For each Acts chapter mentioned in the "based on", accumulate paragraphs
        primary_ch, primary_v = acts_refs[0]
        covered_chapters.add(primary_ch)
        if primary_ch not in chapter_para_map:
            chapter_para_map[primary_ch] = {"start_verse": primary_v, "paragraphs": []}
        chapter_para_map[primary_ch]["paragraphs"].extend(paragraphs)
        # Also note any additional chapters (e.g. "Acts 6:1-7" mentions ch 6)
        for ch, v in acts_refs[1:]:
            if ch != primary_ch:
                covered_chapters.add(ch)
                if ch not in chapter_para_map:
                    chapter_para_map[ch] = {"start_verse": v, "paragraphs": []}

        time.sleep(0.5)  # be polite to the server

    print(f"\nActs chapters covered: {sorted(covered_chapters)}")
    missing = set(range(1, ACTS_CHAPTERS + 1)) - covered_chapters
    if missing:
        print(f"WARNING: Acts chapters with no EGW AA coverage: {missing}")
        print("  (Normal — AA does not directly address every Acts chapter.)")

    # Generate entries
    idx_global = 0
    for acts_ch in range(1, ACTS_CHAPTERS + 1):
        if acts_ch not in chapter_para_map:
            continue
        info = chapter_para_map[acts_ch]
        entries = distribute_paragraphs(
            info["paragraphs"],
            acts_ch,
            info["start_verse"],
            min_per_chapter=3
        )
        all_entries.extend(entries)
        print(f"  Acts {acts_ch}: {len(entries)} commentary entries")
        idx_global += len(entries)

    print(f"\nTotal entries generated: {idx_global}")

    out_path = "scripts/egw_aa_commentary_new.json"
    with open(out_path, "w") as f:
        json.dump(all_entries, f, indent=2, ensure_ascii=False)
    print(f"Saved to {out_path}")
    print("\nReview the file, then run the merge script to add to commentary.json.")


if __name__ == "__main__":
    main()
