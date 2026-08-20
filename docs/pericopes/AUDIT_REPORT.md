# Pericope Dataset — Whole-System Audit Report

**Audit Date:** 2026-08-20  
**Auditor:** Automated mechanical verification against `assets/data/kjvbible.json`  
**Source Files:** `docs/pericopes/` — 6 draft files  
**Verdict Source:** `kjvbible.json` (31,102 verses). Note: `bible.db` is 0 bytes (placeholder); the app renders from `kjvbible.json` via [`bible_database_service.dart`](file:///Users/baraka/the_blessed_bible/lib/services/bible_database_service.dart). There is therefore no `bible.db` vs `kjvbible.json` discrepancy possible — they are the same source.

---

## Overall Result: PASS

All 66 books present. All 31,102 verses covered. Zero gaps, zero overlaps. Zero book-name mismatches.

---

## 1. All 66 Books Present

Every book in the KJV canon appears in exactly one draft file. No book is missing. No book is duplicated across files.

| Draft File | Books | Count |
|---|---|---|
| `pentateuch_draft.md` | Genesis, Exodus, Leviticus, Numbers, Deuteronomy | 5 |
| `historical_draft.md` | Joshua, Judges, Ruth, 1 Samuel, 2 Samuel, 1 Kings, 2 Kings, 1 Chronicles, 2 Chronicles, Ezra, Nehemiah, Esther | 12 |
| `poetry_draft.md` | Job, Psalms, Proverbs, Ecclesiastes, Song of Solomon | 5 |
| `prophets_draft.md` | Isaiah, Jeremiah, Lamentations, Ezekiel, Daniel, Hosea, Joel, Amos, Obadiah, Jonah, Micah, Nahum, Habakkuk, Zephaniah, Haggai, Zechariah, Malachi | 17 |
| `gospels_acts_draft.md` | Matthew, Mark, Luke, John, Acts | 5 |
| `epistles_revelation_draft.md` | Romans, 1 Corinthians, 2 Corinthians, Galatians, Ephesians, Philippians, Colossians, 1 Thessalonians, 2 Thessalonians, 1 Timothy, 2 Timothy, Titus, Philemon, Hebrews, James, 1 Peter, 2 Peter, 1 John, 2 John, 3 John, Jude, Revelation | 22 |
| **Total** | | **66** |

**Result: PASS** — 66 / 66 books present, none missing, none duplicated.

---

## 2. Global Coverage Against Source Data

Mechanical verification was performed: for each of the 66 books, all pericope ranges were sorted by start position, and the algorithm checked that:
1. The first pericope starts at chapter 1, verse 1.
2. Each subsequent pericope starts exactly at the verse following the previous pericope's end (accounting for chapter boundaries using the actual max verse per chapter from `kjvbible.json`).
3. The last pericope ends at the final verse of the final chapter.

| Book | Source Verses | Pericopes | Result |
|---|---|---|---|
| Genesis | 1,533 | 52 | PASS |
| Exodus | 1,213 | 34 | PASS |
| Leviticus | 859 | 24 | PASS |
| Numbers | 1,288 | 33 | PASS |
| Deuteronomy | 959 | 30 | PASS |
| Joshua | 658 | 22 | PASS |
| Judges | 618 | 17 | PASS |
| Ruth | 85 | 3 | PASS |
| 1 Samuel | 810 | 26 | PASS |
| 2 Samuel | 695 | 21 | PASS |
| 1 Kings | 816 | 21 | PASS |
| 2 Kings | 719 | 25 | PASS |
| 1 Chronicles | 942 | 16 | PASS |
| 2 Chronicles | 822 | 19 | PASS |
| Ezra | 280 | 7 | PASS |
| Nehemiah | 406 | 6 | PASS |
| Esther | 167 | 4 | PASS |
| Job | 1,070 | 8 | PASS |
| Psalms | 2,461 | 150 | PASS |
| Proverbs | 915 | 7 | PASS |
| Ecclesiastes | 222 | 5 | PASS |
| Song of Solomon | 117 | 4 | PASS |
| Isaiah | 1,292 | 61 | PASS |
| Jeremiah | 1,364 | 52 | PASS |
| Lamentations | 154 | 5 | PASS |
| Ezekiel | 1,273 | 49 | PASS |
| Daniel | 357 | 10 | PASS |
| Hosea | 197 | 8 | PASS |
| Joel | 73 | 3 | PASS |
| Amos | 146 | 4 | PASS |
| Obadiah | 21 | 1 | PASS |
| Jonah | 48 | 4 | PASS |
| Micah | 105 | 3 | PASS |
| Nahum | 47 | 2 | PASS |
| Habakkuk | 56 | 2 | PASS |
| Zephaniah | 53 | 2 | PASS |
| Haggai | 38 | 1 | PASS |
| Zechariah | 211 | 4 | PASS |
| Malachi | 55 | 2 | PASS |
| Matthew | 1,071 | 91 | PASS |
| Mark | 678 | 67 | PASS |
| Luke | 1,151 | 92 | PASS |
| John | 879 | 47 | PASS |
| Acts | 1,007 | 52 | PASS |
| Romans | 433 | 16 | PASS |
| 1 Corinthians | 437 | 16 | PASS |
| 2 Corinthians | 257 | 13 | PASS |
| Galatians | 149 | 7 | PASS |
| Ephesians | 155 | 7 | PASS |
| Philippians | 104 | 4 | PASS |
| Colossians | 95 | 4 | PASS |
| 1 Thessalonians | 89 | 5 | PASS |
| 2 Thessalonians | 47 | 3 | PASS |
| 1 Timothy | 113 | 6 | PASS |
| 2 Timothy | 83 | 4 | PASS |
| Titus | 46 | 3 | PASS |
| Philemon | 25 | 1 | PASS |
| Hebrews | 303 | 13 | PASS |
| James | 108 | 6 | PASS |
| 1 Peter | 105 | 5 | PASS |
| 2 Peter | 61 | 3 | PASS |
| 1 John | 105 | 5 | PASS |
| 2 John | 13 | 1 | PASS |
| 3 John | 14 | 1 | PASS |
| Jude | 25 | 1 | PASS |
| Revelation | 404 | 11 | PASS |

**Result: PASS** — All 66 books pass. Zero gaps, zero overlaps, zero out-of-range references.

### `bible.db` vs `kjvbible.json` Discrepancy Check

`bible.db` is a 0-byte placeholder file. The app loads all verse data exclusively from `kjvbible.json` (parsed in `bible_database_service.dart`). There is no discrepancy because there is only one active source. The pericope boundaries were verified against that source.

**Result: PASS** — No discrepancy (single source).

---

## 3. Book-Name Spelling Consistency

The 66 unique book names extracted from all draft files were compared character-for-character against the 66 unique `book_name` values in `kjvbible.json` (which is the same identifier the app uses for lookups, and the same namespace used by `chapter_titles.json`).

`diff` of sorted book name lists: **zero differences**.

**Result: PASS** — All 66 book names match exactly. No spelling mismatches.

---

## 4. Global Totals

| Metric | Claimed (Headers) | Actual (Verified) | Match? |
|---|---|---|---|
| Total pericopes | 1,175 | **1,231** | NO |
| Total verses | 31,102 | **31,102** | YES |

**WARNING: Pericope count discrepancy.** The claimed total of 1,175 was based on the in-file header summaries, which were inaccurate for several files. The actual row count from the dataset tables is **1,231 pericopes**. The verse coverage is correct — this is a metadata/header error, not a data error.

### Per-File Breakdown (Claimed Header vs Actual Rows)

| File | Header Claim | Actual Rows | Difference |
|---|---|---|---|
| `pentateuch_draft.md` | 172 | 173 | +1 |
| `historical_draft.md` | 189 | 187 | -2 |
| `poetry_draft.md` | 174 | 174 | 0 |
| `prophets_draft.md` | 212 | 213 | +1 |
| `gospels_acts_draft.md` | 293 | 349 | **+56** |
| `epistles_revelation_draft.md` | 135 | 135 | 0 |
| **Totals** | **1,175** | **1,231** | **+56** |

The biggest discrepancy is in the Gospels & Acts file. The in-file header claims Matthew=69, Mark=53, Luke=77, John=42, Acts=52 (total=293), but the actual table contains Matthew=91, Mark=67, Luke=92, John=47, Acts=52 (total=349). The summary paragraph was miscounted; the actual table data is correct and passes coverage verification.

**Result: PARTIAL** — Verse total matches perfectly. Pericope count headers need correction (data is sound, metadata is wrong).

---

## 5. No Cross-File / Book-Boundary Overlaps

Each of the 66 books appears in exactly one draft file. No book is split across files. No verse is claimed by pericopes in two different files.

**Result: PASS**

---

## 6. Chapter-Title vs. Pericope Conflict Analysis

### Source of Chapter Titles
The app uses `assets/data/chapter_titles.json`, loaded by `ChapterTitlesNotifier` in `lib/state/chapter_titles_provider.dart`. It provides a human-readable title for each chapter (e.g., Genesis 1 -> "Creation"). The file contains **1,165 entries** for the Bible's **1,189 chapters**.

### Missing Chapter Titles
25 chapters have no entry in `chapter_titles.json` and will display no chapter title:

| Book | Missing Chapters |
|---|---|
| Luke | 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 (19 chapters) |
| Psalms | 86 (1 chapter) |
| Zechariah | 1, 2, 3, 4, 5 (5 chapters) |

### Conflict Surface Summary

| Category | Count | % of 1,189 chapters |
|---|---|---|
| **Verse-1 collisions** (chapter title AND pericope heading both at top) | 969 | 81.5% |
| **Spanning pericopes** (chapter has NO pericope heading at top; pericope from previous chapter continues through) | 220 | 18.5% |
| **Multiple internal pericopes** (chapter contains >1 pericope start) | 115 | 9.7% |

### Interpretation

- **81.5% of chapters** will have both a chapter title and a pericope heading rendering at verse 1. The unified-heading UI must handle this dual-heading gracefully (e.g., showing the chapter title as a primary heading and the pericope title as a subheading, or merging them into a single compound heading).

- **18.5% of chapters** will have NO pericope heading at their top because a pericope starting in a previous chapter spans across the chapter boundary. These chapters will show only the chapter title. Examples: Genesis 2 (Creation pericope spans 1:1-2:3), Exodus 4 (Burning Bush pericope spans 3:1-4:17), Revelation 3 (Seven Churches pericope spans 2:1-3:22).

- **9.7% of chapters** contain multiple pericope headings within them (mid-chapter breaks). These are mostly in the Gospels (fine-grained scene-level breakdown) and in books where pericopes were split mid-chapter (e.g., Galatians 5 split at v16 for the Fruit of the Spirit, James 2 split at v14 for Faith Without Works).

- Note: the verse-1 collision and spanning categories are **mutually exclusive and exhaustive** — every chapter either has a pericope starting at verse 1 (969) or has a spanning pericope continuing through it from a previous chapter (220). 969 + 220 = 1,189.

**Result: ANALYSIS COMPLETE** — Conflict surface fully mapped. No fix proposed (as directed).

---

## Audit Summary

| Check | Result |
|---|---|
| 1. All 66 books present | PASS |
| 2. Global coverage (no gaps, no overlaps) | PASS (all 66 books) |
| 2a. `bible.db` vs `kjvbible.json` discrepancy | PASS (single source; `bible.db` is 0 bytes) |
| 3. Book-name spelling consistency | PASS (zero mismatches) |
| 4. Global totals — verses | PASS (31,102 = 31,102) |
| 4. Global totals — pericope count | WARNING: Header says 1,175; actual table rows = 1,231 |
| 5. No cross-file overlaps | PASS |
| 6. Chapter-title conflict analysis | ANALYSIS COMPLETE |

**The pericope dataset is structurally sound.** The only issue is that the in-file header summaries (particularly in `gospels_acts_draft.md`) undercount the actual pericope rows. The data itself — the table rows that define the boundaries — is correct and fully verified.
