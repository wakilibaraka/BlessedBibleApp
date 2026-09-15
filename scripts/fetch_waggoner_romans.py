import urllib.request
import re
import time
import sys

def fetch_node(node_id):
    url = f"https://m.egwwritings.org/en/book/1613.{node_id}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    for attempt in range(5):
        try:
            html = urllib.request.urlopen(req, timeout=10).read().decode('utf-8')
            break
        except Exception as e:
            print(f"Error fetching {node_id} (attempt {attempt+1}): {e}", file=sys.stderr)
            time.sleep(2)
    else:
        print(f"Failed to fetch {node_id} after 5 attempts", file=sys.stderr)
        return None, None
    
    paras = re.findall(r'<span class=\"egw_content\"[^>]*>(.*?)</span>', html, re.DOTALL)
    texts = []
    for p in paras:
        text = re.sub(r'<[^>]+>', '', p).strip()
        text = re.sub(r'\s+', ' ', text)
        if len(text) > 20:
            texts.append(text)
            
    next_match = re.search(r'<li class=\"next\"><a[^>]*href=\"/en/book/1613\.(\d+)\"', html)
    if not next_match:
        next_match = re.search(r'href=\"/en/book/1613\.(\d+)\"[^>]*>\s*Next\s*</a>', html, re.IGNORECASE)
        
    next_node = next_match.group(1) if next_match else None
    
    return texts, next_node

start_nodes = [11, 276, 512, 710, 897, 1081, 1208, 1357, 1702, 1791, 1869, 1901, 1957, 2057, 2160, 2208]
end_nodes = start_nodes[1:] + [999999]

for ch in range(1, 17):
    print(f"Fetching Chapter {ch}...", file=sys.stderr)
    current = str(start_nodes[ch-1])
    end_node = str(end_nodes[ch-1])
    
    ch_text = []
    while current and int(current) < int(end_node):
        print(f"  Node {current}", file=sys.stderr)
        texts, nxt = fetch_node(current)
        if texts:
            ch_text.extend(texts)
            
        if not nxt:
            print(f"Could not find next node after {current}!", file=sys.stderr)
            break
            
        current = nxt
        time.sleep(0.5)
        
    with open(f"scripts/waggoner_romans_ch{ch}.txt", "w") as f:
        f.write("\n\n".join(ch_text))
    print(f"Saved Chapter {ch} with {len(ch_text)} paragraphs.\n", file=sys.stderr)

print("All done!", file=sys.stderr)
