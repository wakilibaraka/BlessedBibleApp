import urllib.request
import json
import time

verses = {}
for ch in range(1, 7):
    url = f"https://bible-api.com/Galatians+{ch}?translation=kjv"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    resp = urllib.request.urlopen(req).read().decode('utf-8')
    data = json.loads(resp)
    
    verses[ch] = {}
    for v in data['verses']:
        vn = v['verse']
        text = v['text'].strip()
        verses[ch][vn] = text
    time.sleep(0.2)

with open('scripts/galatians_kjv.json', 'w') as f:
    json.dump(verses, f, indent=2)
print("Saved Galatians KJV text.")
