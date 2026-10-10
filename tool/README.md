# tool/

Developer scripts for building and checking bundled content. Not shipped in the
app and excluded from `flutter analyze` (see `analysis_options.yaml`). Run
everything from the repo root.

## Bible text and translation packs
| Script | Purpose |
| --- | --- |
| `build_bible_db.dart` | One-off builder for `assets/bible/bible.db` (`dart run tool/build_bible_db.dart`). |
| `split_db.py` | Splits non-core translations out of `bible.db` into per-translation pack DBs. |
| `build_content.py` | Builds and checks content packs and refreshes `content_packs/manifest.json` (`--check-only`, `--refresh-manifest`). |
| `content_sizes.py` | Reports the size of bundled content. |
| `check_complete.dart` | Inspects the bible.helloao.org `complete.json` format for a translation. |
| `check_license.dart`, `check_hinirv.dart` | Look up a translation's license on bible.helloao.org. |

## Study data
| Script | Purpose |
| --- | --- |
| `build_dictionary_tiers.py` | Builds the dictionary tiers used by `lib/state/dictionary_provider.dart`. |
| `build_topical.py` | Builds starter topical reading plans from Nave's and Torrey's (public domain). |
| `build_word_counts.py` | Regenerates `assets/data/word_counts.json` from the KJV in `bible.db`. |
| `generate_reading_plan.dart` | Generates reading plans from `assets/reading_plans/source/`. |
| `evaluate_headings.jq` | Compares chapter titles with pericope headings and flags mismatches for review. Input: a JSON array `[chapterTitles, pericopes]`. Example: `jq -s -f tool/evaluate_headings.jq chapter_titles.json pericopes.json`. |

## Commentary
| File | Purpose |
| --- | --- |
| `commentary-studio.html` | Local browser tool for authoring commentary JSON. |
| `hebrews_*.json` | Hebrews commentary source drafts. |

## Devotional (Bible Stories)
| Script | Purpose |
| --- | --- |
| `export_bible_stories.py` | Exports the Bible Stories spreads into `assets/devotional/stories/`. |
| `fetch_devotional_fonts.py` | Downloads the OFL devotional fonts into `assets/fonts/devotional/`. |
| `fetch_dore_art.py`, `fetch_remaining_plates.py` | Download Gustave Doré plates (public domain) from Wikimedia Commons. |
| `devotional_common.py` | Shared helpers for the scripts above. |
| `data/` | Caches and credits for the fetchers (`dore_credits.json` holds source URLs and attribution). |

## Legal and CI
| File | Purpose |
| --- | --- |
| `build_privacy_policy.py` | Generates `docs/privacy_policy.md` and `.html` from `assets/legal/privacy_policy.json` (the source the app renders). `--check` fails if they are stale; CI runs it. |
| `ci/` | Stub `firebase_options.dart` and `google-services.json` so CI can analyze, test and build without credentials. |
