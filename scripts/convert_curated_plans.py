import urllib.request
import json
import re
import os

BOOK_NORMALIZE = {
    '1samuel': '1 Samuel',
    '2samuel': '2 Samuel',
    '1kings': '1 Kings',
    '2kings': '2 Kings',
    '1chronicles': '1 Chronicles',
    '2chronicles': '2 Chronicles',
    '1thes': '1 Thessalonians',
    '2thes': '2 Thessalonians',
    '1thessalonians': '1 Thessalonians',
    '2thessalonians': '2 Thessalonians',
    '1timothy': '1 Timothy',
    '2timothy': '2 Timothy',
    '1corinthians': '1 Corinthians',
    '2corinthians': '2 Corinthians',
    '1peter': '1 Peter',
    '2peter': '2 Peter',
    '1john': '1 John',
    '2john': '2 John',
    '3john': '3 John',
    'songofsolomon': 'Song of Solomon',
    'songofsongs': 'Song of Solomon',
    'psalm': 'Psalms',
}

def clean_ref(ref_str):
    s = ref_str.strip()
    # If starts with digit followed directly by letters, add space: "1Samuel" -> "1 Samuel"
    m = re.match(r'^([1-3])([a-zA-Z].*)', s)
    if m:
        s = f"{m.group(1)} {m.group(2)}"
    # Normalize book name prefix
    parts = s.split(' ', 1)
    if len(parts) == 2:
        book_key = parts[0].lower().replace(' ', '')
        if book_key in BOOK_NORMALIZE:
            s = f"{BOOK_NORMALIZE[book_key]} {parts[1]}"
    else:
        # e.g. "Psalm 119:1-24"
        pass
    # Specifically check "Psalm " -> "Psalms "
    if s.startswith('Psalm '):
        s = 'Psalms ' + s[6:]
    return s

PLANS_TO_FETCH = [
    {
        'id': 'mccheyne_1yr',
        'title': "M'Cheyne 1-Year Plan",
        'description': "Robert Murray M'Cheyne's classic schedule: 4 daily passages spanning the Old Testament once and the New Testament & Psalms twice.",
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/mcheyne.json',
        'category': 'Classic / 1-Year',
        'badge': '4 Passages/day',
    },
    {
        'id': 'esv_through_the_bible',
        'title': 'Through The Bible in a Year',
        'description': 'A balanced daily reading program that journeys systematically through both the Old and New Testaments every day.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/esvthroughthebible.json',
        'category': 'Whole Bible',
        'badge': '2 Passages/day',
    },
    {
        'id': 'esv_everyday_in_word',
        'title': 'Every Day In The Word',
        'description': 'Four readings each day: from the Old Testament, the New Testament, Psalms, and Proverbs.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/esveverydayinword.json',
        'category': 'Whole Bible',
        'badge': '4 Passages/day',
    },
    {
        'id': 'esv_gospels_and_epistles',
        'title': 'Gospels & Epistles',
        'description': 'Dedicated focus on Jesus Christ’s life, teaching, and the foundational letters of the apostles.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/esvgospelsandepistles.json',
        'category': 'Gospels & NT',
        'badge': '1 Passage/day',
    },
    {
        'id': 'esv_psalms_and_wisdom',
        'title': 'Psalms & Wisdom Literature',
        'description': 'Devotional immersion in the poetry, prayers, and wisdom of Psalms, Proverbs, Job, and Ecclesiastes.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/esvpsalmsandwisdomliterature.json',
        'category': 'Wisdom',
        'badge': '1 Passage/day',
    },
    {
        'id': 'esv_pentateuch_and_history',
        'title': 'Pentateuch & History of Israel',
        'description': 'From the dawn of Creation through the Law and the rise and fall of the kingdom of Israel.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/esvpentateuchandhistoryofisrael.json',
        'category': 'OT & NT',
        'badge': '1 Passage/day',
    },
    {
        'id': 'esv_chronicles_and_prophets',
        'title': 'Chronicles & The Prophets',
        'description': 'Journey through 1 & 2 Chronicles harmonized alongside the major and minor Hebrew prophets.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/esvchroniclesandprophets.json',
        'category': 'OT & NT',
        'badge': '1 Passage/day',
    },
    {
        'id': 'heartlight_ot_nt',
        'title': 'Heartlight Old & New Testament',
        'description': 'Harmonious parallel daily reading pairing Old Testament narrative with New Testament revelation.',
        'source_url': 'https://raw.githubusercontent.com/khornberg/readingplans/master/heartlightotandnt.json',
        'category': 'Whole Bible',
        'badge': '2 Passages/day',
    },
]

out_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'reading_plans')
os.makedirs(out_dir, exist_ok=True)

manifest = []

for meta in PLANS_TO_FETCH:
    print(f"Fetching {meta['title']}...")
    try:
        req = urllib.request.urlopen(meta['source_url'])
        raw = json.loads(req.read().decode('utf-8'))
        
        data2 = raw.get('data2', [])
        if not data2:
            print(f"  Warning: no data2 in {meta['id']}")
            continue
            
        readings = []
        for idx, day_passages in enumerate(data2):
            day_num = idx + 1
            week_num = (idx // 7) + 1
            
            cleaned_passages = []
            for p in day_passages:
                c = clean_ref(p)
                cleaned_passages.append({
                    "label": c,
                    "refs": [c]
                })
            
            day_title = ", ".join([p["label"] for p in cleaned_passages[:2]])
            if len(cleaned_passages) > 2:
                day_title += f" (+{len(cleaned_passages)-2} more)"
                
            readings.append({
                "day": day_num,
                "week": week_num,
                "title": day_title,
                "passages": cleaned_passages
            })
            
        plan_doc = {
            "title": meta['title'],
            "id": meta['id'],
            "description": meta['description'],
            "category": meta['category'],
            "badge": meta['badge'],
            "totalDays": len(readings),
            "readings": readings
        }
        
        out_path = os.path.join(out_dir, f"{meta['id']}.json")
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(plan_doc, f, indent=2)
            
        print(f"  Saved {len(readings)} days to {out_path}")
        manifest.append({
            'id': meta['id'],
            'title': meta['title'],
            'description': meta['description'],
            'category': meta['category'],
            'badge': meta['badge'],
            'totalDays': len(readings),
            'isAvailable': True,
        })
    except Exception as e:
        print(f"  Failed: {e}")

print(f"\nSuccessfully generated {len(manifest)} plans!")
