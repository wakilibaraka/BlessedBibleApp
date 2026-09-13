import json
import datetime

with open('assets/commentary/commentary.json', 'r') as f:
    data = json.load(f)

# Filter out old EGW Acts commentary to avoid duplicates
filtered_entries = [
    e for e in data['entries'] 
    if not (e['scope'].get('book') == 'Acts' and e['author'] == 'Ellen G. White')
]

# Load the newly generated rich commentary
with open('scripts/egw_rich_commentary.json', 'r') as f:
    new_entries = json.load(f)

filtered_entries.extend(new_entries)
data['entries'] = filtered_entries
data['count'] = len(filtered_entries)
# Avoid datetime.utcnow() deprecation
data['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open('assets/commentary/commentary.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Removed old EGW Acts entries.")
print(f"Added {len(new_entries)} rich EGW Acts entries.")
print(f"Total entries in commentary.json: {data['count']}")
