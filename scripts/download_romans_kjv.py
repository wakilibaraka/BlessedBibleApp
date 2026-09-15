import urllib.request
import json
import time

verses = {}
for ch in range(1, 17):
    url = f"https://bible-api.com/Romans+{ch}?translation=kjv"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    for attempt in range(5):
        try:
            resp = urllib.request.urlopen(req, timeout=10).read().decode('utf-8')
            break
        except:
            time.sleep(2)
    else:
        print(f"Failed to fetch Romans {ch}")
        continue
        
    data = json.loads(resp)
    verses[ch] = {}
    for v in data['verses']:
        vn = v['verse']
        text = v['text'].strip()
        verses[ch][vn] = text
    time.sleep(0.5)

with open('scripts/romans_kjv.json', 'w') as f:
    json.dump(verses, f, indent=2)
print("Saved Romans KJV text.")
