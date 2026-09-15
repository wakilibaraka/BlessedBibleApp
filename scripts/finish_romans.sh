#!/bin/bash
echo "Waiting for fetch to finish..."
while pgrep -f fetch_waggoner_romans > /dev/null; do
    sleep 10
done
echo "Fetch finished. Building commentary..."

cat << 'PY_EOF' > scripts/build_romans_commentary.py
import json
import re
import datetime
import os

with open('scripts/romans_kjv.json') as f:
    kjv = json.load(f)

def match_verse(paragraph, chapter):
    p_norm = re.sub(r'[^a-z0-9\s]', '', paragraph.lower())
    p_words = p_norm.split()
    if len(p_words) < 5: return None
    
    # Check all verses in the chapter
    for v_str, v_text in kjv[str(chapter)].items():
        v_norm = re.sub(r'[^a-z0-9\s]', '', v_text.lower())
        v_words = v_norm.split()
        
        match_len = min(6, len(v_words))
        for i in range(len(v_words) - match_len + 1):
            seq = " ".join(v_words[i:i+match_len])
            if seq in p_norm:
                return int(v_str)
    return None

def make_id(ch, v, idx):
    return f"c_wg_rom_{ch}_{v}_{idx}"

all_entries = []

for ch in range(1, 17):
    filename = f"scripts/waggoner_romans_ch{ch}.txt"
    if not os.path.exists(filename):
        print(f"Skipping {filename}")
        continue
        
    with open(filename, 'r') as f:
        content = f.read()
        
    paras = [p.strip() for p in content.split('\n\n') if p.strip()]
    current_v = 1
    
    verse_map = {}
    for p in paras:
        matched = match_verse(p, ch)
        if matched:
            current_v = matched
            
        upper_count = sum(1 for c in p if c.isupper())
        if len(p) > 20 and (upper_count / len(p)) > 0.5:
            continue
            
        if current_v not in verse_map:
            verse_map[current_v] = []
        verse_map[current_v].append(p)
        
    for v, v_paras in verse_map.items():
        chunk_size = 3
        for i in range(0, len(v_paras), chunk_size):
            chunk = v_paras[i:i+chunk_size]
            combined_text = "\n\n".join(chunk)
            
            entry = {
                "author": "E.J. Waggoner",
                "source": "Waggoner on Romans",
                "scope": {
                    "type": "verse",
                    "book": "Romans",
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
with open('scripts/egw_waggoner_romans_commentary.json', 'w') as f:
    json.dump(all_entries, f, indent=2, ensure_ascii=False)
PY_EOF

python3 scripts/build_romans_commentary.py

echo "Merging into commentary.json..."
cat << 'PY_EOF2' > scripts/merge_romans_commentary.py
import json
import datetime

with open('assets/commentary/commentary.json', 'r') as f:
    data = json.load(f)

filtered_entries = [
    e for e in data['entries'] 
    if not (e['scope'].get('book') == 'Romans' and e['author'] == 'E.J. Waggoner')
]

with open('scripts/egw_waggoner_romans_commentary.json', 'r') as f:
    new_entries = json.load(f)

filtered_entries.extend(new_entries)
data['entries'] = filtered_entries
data['count'] = len(filtered_entries)
data['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open('assets/commentary/commentary.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Merged successful.")
PY_EOF2

python3 scripts/merge_romans_commentary.py

echo "Committing..."
git add assets/commentary/commentary.json
git commit -m "feat: add E.J. Waggoner on Romans commentary"

echo "Done."
