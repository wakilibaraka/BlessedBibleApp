#!/bin/bash
echo "Waiting for fetch to finish..."
# Wait for the specific python process to finish
while pgrep -f fetch_glad_tidings > /dev/null; do
    sleep 10
done
echo "Fetch finished. Building commentary..."
python3 scripts/build_glad_tidings_commentary.py

echo "Merging into commentary.json..."
cat << 'PY_EOF' > scripts/merge_gt_commentary.py
import json
import datetime

with open('assets/commentary/commentary.json', 'r') as f:
    data = json.load(f)

# Filter out old EGW Glad Tidings commentary to avoid duplicates if re-run
filtered_entries = [
    e for e in data['entries'] 
    if not (e['scope'].get('book') == 'Galatians' and e['author'] == 'E.J. Waggoner')
]

with open('scripts/egw_glad_tidings_commentary.json', 'r') as f:
    new_entries = json.load(f)

filtered_entries.extend(new_entries)
data['entries'] = filtered_entries
data['count'] = len(filtered_entries)
data['exportedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')

with open('assets/commentary/commentary.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Merged successful.")
PY_EOF

python3 scripts/merge_gt_commentary.py

echo "Committing..."
git add assets/commentary/commentary.json scripts/build_galatians_breakdowns.py
git commit -m "feat: add E.J. Waggoner Glad Tidings commentary for Galatians"

echo "Done."
