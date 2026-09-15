import json
import re

with open('scripts/galatians_kjv.json') as f:
    kjv = json.load(f)

def normalize(text):
    return re.sub(r'[^a-z0-9]', '', text.lower())

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

test_para = "“PAUL, an apostle (not from men, neither through man, but through Jesus Christ, and God the Father, who raised Him from the dead)"
print("Match:", match_verse(test_para, 1))
