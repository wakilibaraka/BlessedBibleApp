import urllib.request
import re
import json
import time
from html.parser import HTMLParser
from collections import defaultdict

# 58 chapters of AA + DOA ch 87 for Acts 1
TOC_NODES = [
    # Book 130 (Desire of Ages)
    (130, 4080, "Chapter 87—To My Father, and Your Father (DOA)"),
    # Book 127 (The Acts of the Apostles)
    (127, 22, "Chapter 1—God's Purpose for His Church"),
    (127, 53, "Chapter 2—The Training of the Twelve"),
    (127, 86, "Chapter 3—The Great Commission"),
    (127, 128, "Chapter 4—Pentecost"),
    (127, 180, "Chapter 5—The Gift of the Spirit"),
    (127, 222, "Chapter 6—At the Temple Gate"),
    (127, 281, "Chapter 7—A Warning Against Hypocrisy"),
    (127, 312, "Chapter 8—Before the Sanhedrin"),
    (127, 355, "Chapter 9—The Seven Deacons"),
    (127, 396, "Chapter 10—The First Christian Martyr"),
    (127, 422, "Chapter 11—The Gospel in Samaria"),
    (127, 463, "Chapter 12—From Persecutor to Disciple"),
    (127, 516, "Chapter 13—Days of Preparation"),
    (127, 551, "Chapter 14—A Seeker for Truth"),
    (127, 614, "Chapter 15—Delivered From Prison"),
    (127, 672, "Chapter 16—The Gospel Message in Antioch"),
    (127, 719, "Chapter 17—Heralds of the Gospel"),
    (127, 772, "Chapter 18—Preaching Among the Heathen"),
    (127, 824, "Chapter 19—Jew and Gentile"),
    (127, 882, "Chapter 20—Exalting the Cross"),
    (127, 926, "Chapter 21—In the Regions Beyond"),
    (127, 972, "Chapter 22—Thessalonica"),
    (127, 1020, "Chapter 23—Berea and Athens"),
    (127, 1076, "Chapter 24—Corinth"),
    (127, 1124, "Chapter 25—The Thessalonian Letters"),
    (127, 1187, "Chapter 26—Apollos at Corinth"),
    (127, 1240, "Chapter 27—Ephesus"),
    (127, 1286, "Chapter 28—Days of Toil and Trial"),
    (127, 1318, "Chapter 29—A Message of Warning and Entreaty"),
    (127, 1365, "Chapter 30—Called to Reach a Higher Standard"),
    (127, 1427, "Chapter 31—The Message Heeded"),
    (127, 1476, "Chapter 32—A Liberal Church"),
    (127, 1525, "Chapter 33—Laboring Under Difficulties"),
    (127, 1582, "Chapter 34—A Consecrated Ministry"),
    (127, 1638, "Chapter 35—Salvation to the Jews"),
    (127, 1682, "Chapter 36—Apostasy in Galatia"),
    (127, 1709, "Chapter 37—Paul's Last Journey to Jerusalem"),
    (127, 1757, "Chapter 38—Paul a Prisoner"),
    (127, 1849, "Chapter 39—The Trial at Caesarea"),
    (127, 1890, "Chapter 40—Paul Appeals to Caesar"),
    (127, 1909, "Chapter 41—\"Almost Thou Persuadest Me\""),
    (127, 1939, "Chapter 42—The Voyage and Shipwreck"),
    (127, 1976, "Chapter 43—In Rome"),
    (127, 2039, "Chapter 44—Caesar's Household"),
    (127, 2074, "Chapter 45—Written From Rome"),
    (127, 2144, "Chapter 46—At Liberty"),
    (127, 2162, "Chapter 47—The Final Arrest"),
    (127, 2174, "Chapter 48—Paul Before Nero"),
    (127, 2201, "Chapter 49—Paul's Last Letter"),
    (127, 2250, "Chapter 50—Condemned to Die"),
    (127, 2269, "Chapter 51—A Faithful Under-Shepherd"),
    (127, 2335, "Chapter 52—Steadfast Unto the End"),
    (127, 2377, "Chapter 53—John the Beloved"),
    (127, 2409, "Chapter 54—A Faithful Witness"),
    (127, 2454, "Chapter 55—Transformed by Grace"),
    (127, 2496, "Chapter 56—Patmos"),
    (127, 2541, "Chapter 57—The Revelation"),
    (127, 2611, "Chapter 58—The Church Triumphant"),
]

class ParagraphExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paragraphs = []
        self._in_para = False
        self._in_link = False
        self._buf = []
        self._links = []
        
    def handle_starttag(self, tag, attrs):
        attrs_d = dict(attrs)
        if tag == 'p' and 'egw_content_wrapper' in attrs_d.get('class', ''):
            self._in_para = True
            self._buf = []
            self._links = []
        elif tag == 'a' and self._in_para and 'egwlink_bible' in attrs_d.get('class', ''):
            self._in_link = True
            
    def handle_endtag(self, tag):
        if tag == 'p' and self._in_para:
            text = re.sub(r'\s+', ' ', ''.join(self._buf)).strip()
            # Remove footnote references like 'AA 45.2' or 'DA 834.1'
            text = re.sub(r'\s+(AA|DA)\s+\d+\.\d+$', '', text)
            if len(text.split()) > 15:
                self.paragraphs.append({'text': text, 'links': self._links})
            self._in_para = False
        elif tag == 'a' and self._in_link:
            self._in_link = False
            
    def handle_data(self, data):
        if self._in_para:
            self._buf.append(data)
            if self._in_link:
                self._links.append(data.strip())

def parse_bible_link(link_text, current_book="Acts"):
    """
    Parses a string like 'Acts 27' or '28:1-10' into (chapter, start_verse).
    Defaults to verse 1 if not specified.
    """
    link_text = link_text.strip()
    # E.g. 'Acts 2:1-39' or 'Acts 27'
    m_full = re.match(r'^Acts\s+(\d+)(?::(\d+))?', link_text, re.I)
    if m_full:
        return int(m_full.group(1)), int(m_full.group(2) or 1)
    
    # E.g. '25:13-27' or '26' (if we are in Acts context)
    if current_book == "Acts":
        # Ensure it starts with digits and does not contain letters (like 'Corinthians')
        if not re.search(r'[a-zA-Z]', link_text):
            m_partial = re.match(r'^(\d+)(?::(\d+))?', link_text)
            if m_partial:
                return int(m_partial.group(1)), int(m_partial.group(2) or 1)
            
    return None

def fetch_page(book_id, node_id):
    url = f"https://m.egwwritings.org/en/book/{book_id}.{node_id}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        return resp.read().decode("utf-8", errors="replace")

def make_id(acts_ch, acts_v, idx):
    return f"c_egw_acts_{acts_ch}_{acts_v}_{idx}"

def main():
    print(f"Fetching {len(TOC_NODES)} chapters from egwwritings.org...\n")
    
    all_entries = []
    
    # We will accumulate all paragraphs mapped to (chapter, verse)
    verse_map = defaultdict(list)
    
    for book_id, node_id, title in TOC_NODES:
        print(f"Fetching: {title}...")
        try:
            html = fetch_page(book_id, node_id)
        except Exception as e:
            print(f"  ERROR fetching: {e}")
            time.sleep(2)
            continue
            
        # 1. Parse 'based on' to get initial context
        based_on = re.search(r'based on.{0,200}?Acts\s+(\d+):(\d+)', html, re.I | re.DOTALL)
        current_ch, current_v = None, None
        
        if based_on:
            current_ch = int(based_on.group(1))
            current_v = int(based_on.group(2))
            print(f"  Based on: Acts {current_ch}:{current_v}")
        else:
            # Check for generic Acts reference in the chapter
            first_acts = re.search(r'>Acts\s+(\d+)<', html)
            if first_acts:
                current_ch = int(first_acts.group(1))
                current_v = 1
                print(f"  Implicit context: Acts {current_ch}")
            elif 'Chapter 1—God\'s Purpose' in title:
                current_ch = 1
                current_v = 1
                print(f"  Implicit context: Acts 1 (thematic)")
                
        # 2. Extract paragraphs
        extractor = ParagraphExtractor()
        extractor.feed(html)
        paras = extractor.paragraphs
        print(f"  Extracted {len(paras)} paragraphs")
        
        # 3. Carry-forward attribution
        source_name = "The Desire of Ages" if book_id == 130 else "The Acts of the Apostles"
        
        for p in paras:
            # Check links in the paragraph
            for link in p['links']:
                # Update current chapter/verse if it's an Acts link
                # If current_ch is set, parse_bible_link assumes we are in Acts
                parsed = parse_bible_link(link, current_book="Acts" if current_ch else None)
                if parsed:
                    current_ch, current_v = parsed
                    break # just take the first Acts link in the para to anchor it
                    
            if current_ch:
                # We have an Acts mapping for this paragraph!
                verse_map[(current_ch, current_v)].append({
                    "text": p['text'],
                    "source": source_name
                })
        
        time.sleep(0.5)

    print("\nMerging and generating entries...")
    
    # 4. Merge paragraphs for the same verse into single entries
    # The user asked for a "user friendly approach" - concatenating paragraphs 
    # for the same verse into a single readable block is usually best.
    
    # But wait, what if a verse has 30 paragraphs? That's too long.
    # We will limit each entry to max 3 paragraphs, creating multiple entries if needed.
    
    idx_global = 0
    covered_chapters = set()
    
    for (ch, v), paras in sorted(verse_map.items()):
        covered_chapters.add(ch)
        
        # Chunk into groups of 3 paragraphs
        chunk_size = 3
        for i in range(0, len(paras), chunk_size):
            chunk = paras[i:i+chunk_size]
            combined_text = "\n\n".join(p['text'] for p in chunk)
            
            entry = {
                "author": "Ellen G. White",
                "source": chunk[0]['source'], # all from same source in a chunk
                "scope": {
                    "type": "verse",
                    "book": "Acts",
                    "chapter": ch,
                    "verse": v,
                    "topic": None,
                    "custom": None
                },
                "text": combined_text,
                "id": make_id(ch, v, i // chunk_size)
            }
            all_entries.append(entry)
            idx_global += 1

    print(f"\nActs chapters covered: {sorted(covered_chapters)}")
    missing = set(range(1, 29)) - covered_chapters
    if missing:
        print(f"WARNING: Acts chapters with no EGW coverage: {missing}")
        
    print(f"Total verse entries generated: {len(all_entries)}")
    
    out_path = "scripts/egw_rich_commentary.json"
    with open(out_path, "w") as f:
        json.dump(all_entries, f, indent=2, ensure_ascii=False)
    print(f"Saved to {out_path}")

if __name__ == "__main__":
    main()
