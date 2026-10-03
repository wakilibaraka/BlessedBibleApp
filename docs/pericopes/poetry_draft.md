# Poetry & Wisdom Pericope Draft (Chunk 3/6)

**Versification Confirmation:**
I explicitly confirm that the verse boundaries in `assets/data/kjvbible.json` (which this draft is counted from) mathematically match `bible.db` (what the reader renders) verse-for-verse. Both rely on the exact same bundled source and parsing logic. 

## Mandatory Self-Checks

### 1. Coverage
- **Job:** 1,070 verses across 8 pericopes. No gaps, no overlaps.
- **Psalms:** 2,461 verses across 150 pericopes. No gaps, no overlaps.
- **Proverbs:** 915 verses across 7 pericopes. No gaps, no overlaps.
- **Ecclesiastes:** 222 verses across 5 pericopes. No gaps, no overlaps.
- **Song of Solomon:** 117 verses across 4 pericopes. No gaps, no overlaps.
- **Total Poetry & Wisdom:** 4,785 verses completely covered across 174 discrete pericopes.

### 2. Anchor Check
Confirmed — every requested anchor is present as a standalone pericope matching the exact requested event:
- The Prologue: Job Loses Everything: Job 1:1 - 2:13
- The LORD Answers Job out of the Whirlwind: Job 38:1 - 41:34
- Psalm 23 (The LORD is my Shepherd): Psalms 23:1 - 23:6
- Psalm 51 (David's repentance): Psalms 51:1 - 51:19
- Psalm 119: Psalms 119:1 - 119:176
- The Virtuous Woman: Proverbs 31:10 - 31:31
- "To every thing there is a season": Ecclesiastes 3:1 - 3:22

### 3. Confidence Summary
Total `low` confidence pericopes: **11**. These cluster intentionally around poetic structures and dialogue cycles where rigid "narrative scenes" do not exist, ensuring continuous arcs aren't artificially fragmented.
- Job: 3 pericopes (The massive dialogue cycles).
- Ecclesiastes: 4 pericopes (Thematic movements).
- Song of Solomon: 4 pericopes (Poetic exchanges).

---

## Dataset

| Book | Start Chapter | Start Verse | End Chapter | End Verse | Title | Confidence | Note |
|---|---|---|---|---|---|---|---|
| Job | 1 | 1 | 2 | 13 | The Prologue: Job Loses Everything | high | |
| Job | 3 | 1 | 3 | 26 | Job's First Lament | high | |
| Job | 4 | 1 | 14 | 22 | The First Cycle of Speeches | low | Groups Eliphaz, Bildad, Zophar, and Job's responses. |
| Job | 15 | 1 | 21 | 34 | The Second Cycle of Speeches | low | Groups the second round of dialogue. |
| Job | 22 | 1 | 31 | 40 | The Third Cycle and Job's Final Defense | low | Groups the final round of debate. |
| Job | 32 | 1 | 37 | 24 | The Speeches of Elihu | high | |
| Job | 38 | 1 | 41 | 34 | The LORD Answers Job out of the Whirlwind | high | |
| Job | 42 | 1 | 42 | 17 | Job's Repentance and the Epilogue | high | |
| Psalms | 1 | 1 | 1 | 6 | Psalm 1 | high | |
| Psalms | 2 | 1 | 2 | 12 | Psalm 2 | high | |
| Psalms | 3 | 1 | 3 | 8 | Psalm 3 | high | |
| Psalms | 4 | 1 | 4 | 8 | Psalm 4 | high | |
| Psalms | 5 | 1 | 5 | 12 | Psalm 5 | high | |
| Psalms | 6 | 1 | 6 | 10 | Psalm 6 | high | |
| Psalms | 7 | 1 | 7 | 17 | Psalm 7 | high | |
| Psalms | 8 | 1 | 8 | 9 | Psalm 8 | high | |
| Psalms | 9 | 1 | 9 | 20 | Psalm 9 | high | |
| Psalms | 10 | 1 | 10 | 18 | Psalm 10 | high | |
| Psalms | 11 | 1 | 11 | 7 | Psalm 11 | high | |
| Psalms | 12 | 1 | 12 | 8 | Psalm 12 | high | |
| Psalms | 13 | 1 | 13 | 6 | Psalm 13 | high | |
| Psalms | 14 | 1 | 14 | 7 | Psalm 14 | high | |
| Psalms | 15 | 1 | 15 | 5 | Psalm 15 | high | |
| Psalms | 16 | 1 | 16 | 11 | Psalm 16 | high | |
| Psalms | 17 | 1 | 17 | 15 | Psalm 17 | high | |
| Psalms | 18 | 1 | 18 | 50 | Psalm 18 | high | |
| Psalms | 19 | 1 | 19 | 14 | Psalm 19 | high | |
| Psalms | 20 | 1 | 20 | 9 | Psalm 20 | high | |
| Psalms | 21 | 1 | 21 | 13 | Psalm 21 | high | |
| Psalms | 22 | 1 | 22 | 31 | Psalm 22 | high | |
| Psalms | 23 | 1 | 23 | 6 | Psalm 23 (The LORD is my Shepherd) | high | |
| Psalms | 24 | 1 | 24 | 10 | Psalm 24 | high | |
| Psalms | 25 | 1 | 25 | 22 | Psalm 25 | high | |
| Psalms | 26 | 1 | 26 | 12 | Psalm 26 | high | |
| Psalms | 27 | 1 | 27 | 14 | Psalm 27 | high | |
| Psalms | 28 | 1 | 28 | 9 | Psalm 28 | high | |
| Psalms | 29 | 1 | 29 | 11 | Psalm 29 | high | |
| Psalms | 30 | 1 | 30 | 12 | Psalm 30 | high | |
| Psalms | 31 | 1 | 31 | 24 | Psalm 31 | high | |
| Psalms | 32 | 1 | 32 | 11 | Psalm 32 | high | |
| Psalms | 33 | 1 | 33 | 22 | Psalm 33 | high | |
| Psalms | 34 | 1 | 34 | 22 | Psalm 34 | high | |
| Psalms | 35 | 1 | 35 | 28 | Psalm 35 | high | |
| Psalms | 36 | 1 | 36 | 12 | Psalm 36 | high | |
| Psalms | 37 | 1 | 37 | 40 | Psalm 37 | high | |
| Psalms | 38 | 1 | 38 | 22 | Psalm 38 | high | |
| Psalms | 39 | 1 | 39 | 13 | Psalm 39 | high | |
| Psalms | 40 | 1 | 40 | 17 | Psalm 40 | high | |
| Psalms | 41 | 1 | 41 | 13 | Psalm 41 | high | |
| Psalms | 42 | 1 | 42 | 11 | Psalm 42 | high | |
| Psalms | 43 | 1 | 43 | 5 | Psalm 43 | high | |
| Psalms | 44 | 1 | 44 | 26 | Psalm 44 | high | |
| Psalms | 45 | 1 | 45 | 17 | Psalm 45 | high | |
| Psalms | 46 | 1 | 46 | 11 | Psalm 46 | high | |
| Psalms | 47 | 1 | 47 | 9 | Psalm 47 | high | |
| Psalms | 48 | 1 | 48 | 14 | Psalm 48 | high | |
| Psalms | 49 | 1 | 49 | 20 | Psalm 49 | high | |
| Psalms | 50 | 1 | 50 | 23 | Psalm 50 | high | |
| Psalms | 51 | 1 | 51 | 19 | Psalm 51 (David's repentance) | high | |
| Psalms | 52 | 1 | 52 | 9 | Psalm 52 | high | |
| Psalms | 53 | 1 | 53 | 6 | Psalm 53 | high | |
| Psalms | 54 | 1 | 54 | 7 | Psalm 54 | high | |
| Psalms | 55 | 1 | 55 | 23 | Psalm 55 | high | |
| Psalms | 56 | 1 | 56 | 13 | Psalm 56 | high | |
| Psalms | 57 | 1 | 57 | 11 | Psalm 57 | high | |
| Psalms | 58 | 1 | 58 | 11 | Psalm 58 | high | |
| Psalms | 59 | 1 | 59 | 17 | Psalm 59 | high | |
| Psalms | 60 | 1 | 60 | 12 | Psalm 60 | high | |
| Psalms | 61 | 1 | 61 | 8 | Psalm 61 | high | |
| Psalms | 62 | 1 | 62 | 12 | Psalm 62 | high | |
| Psalms | 63 | 1 | 63 | 11 | Psalm 63 | high | |
| Psalms | 64 | 1 | 64 | 10 | Psalm 64 | high | |
| Psalms | 65 | 1 | 65 | 13 | Psalm 65 | high | |
| Psalms | 66 | 1 | 66 | 20 | Psalm 66 | high | |
| Psalms | 67 | 1 | 67 | 7 | Psalm 67 | high | |
| Psalms | 68 | 1 | 68 | 35 | Psalm 68 | high | |
| Psalms | 69 | 1 | 69 | 36 | Psalm 69 | high | |
| Psalms | 70 | 1 | 70 | 5 | Psalm 70 | high | |
| Psalms | 71 | 1 | 71 | 24 | Psalm 71 | high | |
| Psalms | 72 | 1 | 72 | 20 | Psalm 72 | high | |
| Psalms | 73 | 1 | 73 | 28 | Psalm 73 | high | |
| Psalms | 74 | 1 | 74 | 23 | Psalm 74 | high | |
| Psalms | 75 | 1 | 75 | 10 | Psalm 75 | high | |
| Psalms | 76 | 1 | 76 | 12 | Psalm 76 | high | |
| Psalms | 77 | 1 | 77 | 20 | Psalm 77 | high | |
| Psalms | 78 | 1 | 78 | 72 | Psalm 78 | high | |
| Psalms | 79 | 1 | 79 | 13 | Psalm 79 | high | |
| Psalms | 80 | 1 | 80 | 19 | Psalm 80 | high | |
| Psalms | 81 | 1 | 81 | 16 | Psalm 81 | high | |
| Psalms | 82 | 1 | 82 | 8 | Psalm 82 | high | |
| Psalms | 83 | 1 | 83 | 18 | Psalm 83 | high | |
| Psalms | 84 | 1 | 84 | 12 | Psalm 84 | high | |
| Psalms | 85 | 1 | 85 | 13 | Psalm 85 | high | |
| Psalms | 86 | 1 | 86 | 17 | Psalm 86 | high | |
| Psalms | 87 | 1 | 87 | 7 | Psalm 87 | high | |
| Psalms | 88 | 1 | 88 | 18 | Psalm 88 | high | |
| Psalms | 89 | 1 | 89 | 52 | Psalm 89 | high | |
| Psalms | 90 | 1 | 90 | 17 | Psalm 90 | high | |
| Psalms | 91 | 1 | 91 | 16 | Psalm 91 | high | |
| Psalms | 92 | 1 | 92 | 15 | Psalm 92 | high | |
| Psalms | 93 | 1 | 93 | 5 | Psalm 93 | high | |
| Psalms | 94 | 1 | 94 | 23 | Psalm 94 | high | |
| Psalms | 95 | 1 | 95 | 11 | Psalm 95 | high | |
| Psalms | 96 | 1 | 96 | 13 | Psalm 96 | high | |
| Psalms | 97 | 1 | 97 | 12 | Psalm 97 | high | |
| Psalms | 98 | 1 | 98 | 9 | Psalm 98 | high | |
| Psalms | 99 | 1 | 99 | 9 | Psalm 99 | high | |
| Psalms | 100 | 1 | 100 | 5 | Psalm 100 | high | |
| Psalms | 101 | 1 | 101 | 8 | Psalm 101 | high | |
| Psalms | 102 | 1 | 102 | 28 | Psalm 102 | high | |
| Psalms | 103 | 1 | 103 | 22 | Psalm 103 | high | |
| Psalms | 104 | 1 | 104 | 35 | Psalm 104 | high | |
| Psalms | 105 | 1 | 105 | 45 | Psalm 105 | high | |
| Psalms | 106 | 1 | 106 | 48 | Psalm 106 | high | |
| Psalms | 107 | 1 | 107 | 43 | Psalm 107 | high | |
| Psalms | 108 | 1 | 108 | 13 | Psalm 108 | high | |
| Psalms | 109 | 1 | 109 | 31 | Psalm 109 | high | |
| Psalms | 110 | 1 | 110 | 7 | Psalm 110 | high | |
| Psalms | 111 | 1 | 111 | 10 | Psalm 111 | high | |
| Psalms | 112 | 1 | 112 | 10 | Psalm 112 | high | |
| Psalms | 113 | 1 | 113 | 9 | Psalm 113 | high | |
| Psalms | 114 | 1 | 114 | 8 | Psalm 114 | high | |
| Psalms | 115 | 1 | 115 | 18 | Psalm 115 | high | |
| Psalms | 116 | 1 | 116 | 19 | Psalm 116 | high | |
| Psalms | 117 | 1 | 117 | 2 | Psalm 117 | high | |
| Psalms | 118 | 1 | 118 | 29 | Psalm 118 | high | |
| Psalms | 119 | 1 | 119 | 176 | Psalm 119 | high | |
| Psalms | 120 | 1 | 120 | 7 | Psalm 120 | high | |
| Psalms | 121 | 1 | 121 | 8 | Psalm 121 | high | |
| Psalms | 122 | 1 | 122 | 9 | Psalm 122 | high | |
| Psalms | 123 | 1 | 123 | 4 | Psalm 123 | high | |
| Psalms | 124 | 1 | 124 | 8 | Psalm 124 | high | |
| Psalms | 125 | 1 | 125 | 5 | Psalm 125 | high | |
| Psalms | 126 | 1 | 126 | 6 | Psalm 126 | high | |
| Psalms | 127 | 1 | 127 | 5 | Psalm 127 | high | |
| Psalms | 128 | 1 | 128 | 6 | Psalm 128 | high | |
| Psalms | 129 | 1 | 129 | 8 | Psalm 129 | high | |
| Psalms | 130 | 1 | 130 | 8 | Psalm 130 | high | |
| Psalms | 131 | 1 | 131 | 3 | Psalm 131 | high | |
| Psalms | 132 | 1 | 132 | 18 | Psalm 132 | high | |
| Psalms | 133 | 1 | 133 | 3 | Psalm 133 | high | |
| Psalms | 134 | 1 | 134 | 3 | Psalm 134 | high | |
| Psalms | 135 | 1 | 135 | 21 | Psalm 135 | high | |
| Psalms | 136 | 1 | 136 | 26 | Psalm 136 | high | |
| Psalms | 137 | 1 | 137 | 9 | Psalm 137 | high | |
| Psalms | 138 | 1 | 138 | 8 | Psalm 138 | high | |
| Psalms | 139 | 1 | 139 | 24 | Psalm 139 | high | |
| Psalms | 140 | 1 | 140 | 13 | Psalm 140 | high | |
| Psalms | 141 | 1 | 141 | 10 | Psalm 141 | high | |
| Psalms | 142 | 1 | 142 | 7 | Psalm 142 | high | |
| Psalms | 143 | 1 | 143 | 12 | Psalm 143 | high | |
| Psalms | 144 | 1 | 144 | 15 | Psalm 144 | high | |
| Psalms | 145 | 1 | 145 | 21 | Psalm 145 | high | |
| Psalms | 146 | 1 | 146 | 10 | Psalm 146 | high | |
| Psalms | 147 | 1 | 147 | 20 | Psalm 147 | high | |
| Psalms | 148 | 1 | 148 | 14 | Psalm 148 | high | |
| Psalms | 149 | 1 | 149 | 9 | Psalm 149 | high | |
| Psalms | 150 | 1 | 150 | 6 | Psalm 150 | high | |
| Proverbs | 1 | 1 | 9 | 18 | The Value of Wisdom | high | |
| Proverbs | 10 | 1 | 22 | 16 | The Proverbs of Solomon | high | |
| Proverbs | 22 | 17 | 24 | 34 | The Sayings of the Wise | high | |
| Proverbs | 25 | 1 | 29 | 27 | More Proverbs of Solomon | high | |
| Proverbs | 30 | 1 | 30 | 33 | The Sayings of Agur | high | |
| Proverbs | 31 | 1 | 31 | 9 | The Sayings of King Lemuel | high | |
| Proverbs | 31 | 10 | 31 | 31 | The Virtuous Woman | high | |
| Ecclesiastes | 1 | 1 | 2 | 26 | The Meaninglessness of Wisdom and Wealth | low | Thematic division. |
| Ecclesiastes | 3 | 1 | 3 | 22 | "To every thing there is a season" | high | |
| Ecclesiastes | 4 | 1 | 5 | 20 | Oppression, Toil, and Riches | low | Thematic division. |
| Ecclesiastes | 6 | 1 | 8 | 17 | Wisdom, Folly, and the Mysteries of Life | low | Thematic division. |
| Ecclesiastes | 9 | 1 | 12 | 14 | The Common Destiny and Conclusion | low | Thematic division. |
| Song of Solomon | 1 | 1 | 2 | 17 | The Lovers Speak | low | Poetic movement boundary. |
| Song of Solomon | 3 | 1 | 5 | 1 | The Wedding and Celebration | low | Poetic movement boundary. |
| Song of Solomon | 5 | 2 | 6 | 13 | The Bride's Dream and the Friends | low | Poetic movement boundary. |
| Song of Solomon | 7 | 1 | 8 | 14 | The Beauty of the Bride | low | Poetic movement boundary. |
