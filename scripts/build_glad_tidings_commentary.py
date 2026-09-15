import json
import re
import datetime
import os

with open('scripts/galatians_kjv.json') as f:
    kjv = json.load(f)

def match_verse(paragraph, chapter):
    p_norm = re.sub(r'[^a-z0-9\s]', '', paragraph.lower())
    p_words = p_norm.split()
    if len(p_words) < 5: return None
    
    # Check all verses in the chapter
    for v_str, v_text in kjv[str(chapter)].items():
        v_norm = re.sub(r'[^a-z0-9\s]', '', v_text.lower())
        v_words = v_norm.split()
        
        # Check sequences of 6 words
        match_len = min(6, len(v_words))
        for i in range(len(v_words) - match_len + 1):
            seq = " ".join(v_words[i:i+match_len])
            if seq in p_norm:
                return int(v_str)
    return None

def make_id(ch, v, idx):
    return f"c_gt_gal_{ch}_{v}_{idx}"

all_entries = []

for ch in range(1, 7):
    filename = f"scripts/glad_tidings_ch{ch}.txt"
    if not os.path.exists(filename):
        print(f"Skipping {filename}")
        continue
        
    with open(filename, 'r') as f:
        content = f.read()
        
    paras = [p.strip() for p in content.split('\n\n') if p.strip()]
    current_v = 1
    
    verse_map = {}
    for p in paras:
        # Avoid pure ALL CAPS strings which are just the bible text headers
        if p.isupper():
            # but maybe it contains the verse?
            pass
            
        matched = match_verse(p, ch)
        if matched:
            current_v = matched
            
        # Ignore paragraphs that are just bible verses (heuristic: if it's identical to the verse, or >80% uppercase)
        upper_count = sum(1 for c in p if c.isupper())
        if len(p) > 20 and (upper_count / len(p)) > 0.5:
            continue
            
        if current_v not in verse_map:
            verse_map[current_v] = []
        verse_map[current_v].append(p)
        
    # Group paragraphs by 3
    for v, v_paras in verse_map.items():
        chunk_size = 3
        for i in range(0, len(v_paras), chunk_size):
            chunk = v_paras[i:i+chunk_size]
            combined_text = "\n\n".join(chunk)
            
            entry = {
                "author": "E.J. Waggoner",
                "source": "The Glad Tidings",
                "scope": {
                    "type": "verse",
                    "book": "Galatians",
                    "chapter": ch,
                    "verse": v,
                    "topic": None,
                    "custom": None
                },
                "text": combined_text,
                "id": make_id(ch, v, i // chunk_size)
            }
            all_entries.append(entry)

print(f"Generated {len(all_entries)} entries.")
with open('scripts/egw_glad_tidings_commentary.json', 'w') as f:
    json.dump(all_entries, f, indent=2, ensure_ascii=False)
