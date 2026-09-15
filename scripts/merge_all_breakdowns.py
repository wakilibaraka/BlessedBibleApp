import json
import os
import glob
import datetime

# Target structure
# {
#   "BookName": {
#      "1": { title, themes, outline, summary },
#      ...
#   }
# }

breakdowns_dir = 'scripts/breakdowns'
all_files = glob.glob(os.path.join(breakdowns_dir, '*.json'))

entries = []

for fpath in all_files:
    try:
        with open(fpath, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading {fpath}: {e}")
        continue
        
    # Check if this is a single book or multiple books
    # Single book JSON has keys like "1", "2", etc.
    # Multiple book JSON has keys like "Ephesians", "Philippians", etc.
    
    first_key = list(data.keys())[0]
    
    if first_key.isdigit():
        # Single book format. We need to derive the book name from the filename.
        basename = os.path.basename(fpath).replace('.json', '')
        # Special cases mapping
        name_map = {
            'matthew': 'Matthew',
            'mark': 'Mark',
            'luke': 'Luke',
            'john': 'John',
            '1_corinthians': '1 Corinthians',
            '2_corinthians': '2 Corinthians',
            'hebrews': 'Hebrews',
            'revelation': 'Revelation'
        }
        book_name = name_map.get(basename, basename.title())
        
        # Wrap it
        processed_data = {book_name: data}
    else:
        # Multiple books format
        processed_data = data
        
    for book, chapters in processed_data.items():
        for ch, ch_data in chapters.items():
            text = f"**{ch_data.get('title', '')}**\n\n**Themes:** {ch_data.get('themes', '')}\n\n**Outline:**\n{ch_data.get('outline', '')}\n\n**Summary:**\n{ch_data.get('summary', '')}"
            entry = {
                "author": "The Blessed Bible Study Guide",
                "source": "Chapter Breakdown",
                "scope": {
                    "type": "chapter",
                    "book": book,
                    "chapter": int(ch),
                    "verse": None,
                    "topic": None,
                    "custom": None
                },
                "text": text,
                "id": f"c_breakdown_{book.lower().replace(' ', '_')}_{ch}"
            }
            entries.append(entry)

print(f"Loaded {len(entries)} chapter breakdowns.")

commentary_path = 'assets/commentary/commentary.json'
with open(commentary_path, 'r') as f:
    db = json.load(f)

# Filter out old breakdowns for ANY book that we are about to inject
books_to_inject = set(e['scope']['book'] for e in entries)

db['entries'] = [
    e for e in db['entries'] 
    if not (e['source'] == 'Chapter Breakdown' and e['scope'].get('book') in books_to_inject)
]

db['entries'].extend(entries)
db['count'] = len(db['entries'])
db['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open(commentary_path, 'w') as f:
    json.dump(db, f, indent=2, ensure_ascii=False)

print(f"Successfully injected {len(entries)} breakdowns for {len(books_to_inject)} books!")
