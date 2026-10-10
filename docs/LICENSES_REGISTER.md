# Content Licenses Register

Every third-party text, dataset, font and image shipped in or downloaded by the app, with its license and what still needs checking. Checklist sections 1 (P0) and 14.

Last audited: 2026-10-10. Sources: `bible.db` tables, `content_packs/manifest.json`, `lib/services/translation_downloader.dart`, asset metadata, font name tables, and web research. Some primary sites (ebible.org, openbible.info, grahambible.com) could not be reached from the audit environment; rows citing them say so.

Status: ✅ OK to ship · ⚠️ verify before release · ⛔ do not ship as-is

## Action items (resolve before any store release)

| # | Item | Why | Action |
| --- | --- | --- | --- |
| 1 | ⛔ **Romanian BTF** (`ron_btf`) — *kept in the app by owner decision, 2026-10-10* | Copyrighted (© 2015 Dr. Brian J. Nibbe, Sr., all rights reserved); the pack's own metadata says "Public Domain", which is wrong. | Get written permission from the copyright holder before a store release, or remove it again (the `TranslationPackStore.retiredPackIds` mechanism purges it from devices). Credited in app meanwhile. |
| 2 | ⚠️ **M. L. Andreasen, *The Book of Hebrews*** (Review and Herald, 1948), 319 commentary entries | US works from 1948 stayed protected only if renewed in 1975–76. Renewal status not confirmed. | Search the US Copyright Office renewal records (Andreasen / Review and Herald, 1975–76). If renewed, it's protected until 2043: remove it or license it. |
| 3 | ⚠️ **The Graham Bible narrative summaries** (Bible Stories devotional, 500 stories) | Fetched from the project's public Supabase endpoint. A public API key isn't a license, and no license terms were found. | Get written permission or confirm an open license from grahambible.com. Keep the in-app attribution either way. |
| 4 | ⚠️ **Reading plans from other publishers**: 5 `esv_*` plans (Crossway, incl. "Every Day in the Word"), `heartlight_ot_nt`, `chronological_1yr` (George Guthrie) | Published schedules reproduced without attribution. "ESV" is a Crossway trademark. | Get permission or replace with original/public-domain schedules. At minimum, add attribution and drop "ESV" from ids and titles. M'Cheyne (1842) is public domain. Horner's 10-list is a method and is already credited. |
| 5 | ⚠️ **Bíblia Livre** (`por_blj`) | App says CC BY 4.0. Versions of this text have been published under CC BY 3.0 Brasil. | Confirm the exact license and the required attribution line, then show it in Credits. |
| 6 | ⚠️ **Strong's lexicon** (14,197 entries) and **"KJV archaic" dictionary** (163 entries) in `bible.db` | Strong's (1890) text is public domain, but the digital edition used isn't recorded. The archaic-word list has no recorded source. | Record the source repo and its license (for example OpenScriptures `strongs`: check its README) and the archaic list's origin. |
| 7 | ⚠️ **Uriah Smith, *Daniel and the Revelation*** | The 1897 text is public domain. The posthumous 1944 Review and Herald revision may be protected. | Confirm which edition the text was taken from. |
| 8 | ⚠️ **E. J. Waggoner, *Waggoner on Romans*** | The 1890s articles are public domain. A modern compiled edition could claim compilation copyright. | Confirm the source edition. |
| 9 | ⚠️ **KJV in the UK** | The KJV is public domain in the US, but in the UK printing rights are held under Crown letters patent. | Record the decision: app distribution is commonly treated as acceptable. Note it if you list in the UK store. |

## Scripture texts

| Text | Where | License | Status |
| --- | --- | --- | --- |
| King James Version (1769 text) | `bible.db` core | Public domain (US); Crown patent in UK (item 9) | ✅ |
| KJV with Strong's numbers | `content_packs/kjv_strongs.db` | Public domain | ✅ |
| Bible in Basic English (1965) | `bible.db` core | Public domain in the US | ✅ |
| World English Bible | `content_packs/web.db` | Public domain | ✅ |
| Reina-Valera 1909 | `content_packs/spa_r09.db` | Public domain | ✅ |
| Luther Bible 1912 | `content_packs/deu_l12.db` | Public domain | ✅ |
| Dutch Bible 1917 | `content_packs/nld_.db` | Public domain | ✅ |
| Louis Segond 1910 | `assets/packs/fra_lsg.db` | Public domain | ✅ |
| Diodati 1885 | `assets/packs/ita_dio.db` | Public domain | ✅ |
| Russian Synodal, Chinese Union Version, Arabic Van Dyck, Korean 1910, Ukrainian Kulish | downloaded | Public domain | ✅ |

**Download source:** every downloadable translation except KJV with Strong's and Hungarian Károli (from [open-bibles](https://github.com/seven1m/open-bibles), pinned commit + sha256) comes from the [Free Use Bible API](https://bible.helloao.org) (`/api/{id}/complete.json`; MIT tooling, texts from eBible.org). KJV with Strong's is served from this repository's own Git LFS copy (`content_packs/kjv_strongs.db`, sha256-verified). CI (`tool/check_translation_sources.py`) checks that every catalog entry resolves to a complete 66-book text.

| Polish Updated Gdańsk Bible (UBG) | downloaded (`pol_ubg`) | © 2018 Fundacja Wrota Nadziei, CC BY-ND 4.0: redistribution incl. commercial, attribution, no changes to the words; credited in app | ✅ |
| Czech Kralice Bible 1613 | downloaded (`ces_bkr`) | Public domain | ✅ |
| Hungarian Károli Bible | downloaded (`hun_kar`) from open-bibles (Unbound Bible / Biola), pinned commit + sha256 | Public domain. Older encoding's õ/û are mapped to ő/ű (no wording changes) | ✅ |
| Swahili ULB, Tagalog ULB | `assets/packs/swh_ulb.db`, `tgl_ulb.db` | CC BY-SA 4.0: attribution + share-alike; credited in app | ✅ |
| Hindi Indian Revised Version | downloaded | CC BY-SA 4.0; credited in app | ✅ |
| Bíblia Livre | `content_packs/por_blj.db` | CC BY (version: item 5) | ⚠️ |
| Romanian BTF 2015 | `assets/packs/ron_btf.db` | © 2015 Dr. Brian J. Nibbe, Sr., all rights reserved; permission needed (item 1) | ⛔ |

## Commentary (`assets/commentary/commentary.json`, 4,724 entries)

| Work | Author | Entries | License | Status |
| --- | --- | --- | --- | --- |
| The Desire of Ages (1898), Patriarchs and Prophets (1890), The Acts of the Apostles (1911), Prophets and Kings (1917) | Ellen G. White | 3,103 | Public domain (original editions; no modern compilations used) | ✅ |
| Waggoner on Romans; The Glad Tidings (1900) | E. J. Waggoner | 898 | Public domain (edition: item 8) | ✅/⚠️ |
| Daniel and the Revelation | Uriah Smith | 403 | Public domain (edition: item 7) | ⚠️ |
| The Book of Hebrews (1948) | M. L. Andreasen | 319 | Unconfirmed (item 2) | ⚠️ |
| (single entry) | Samuel T. Spear | 1 | Public domain (19th c.) | ✅ |

## Study data (`assets/bible/bible.db`, `assets/data/`)

| Dataset | License | Status |
| --- | --- | --- |
| Cross-references (857,710 rows, `votes` column) | OpenBible.info, CC BY (attribution required; credited in app). Derived from the Treasury of Scripture Knowledge (public domain). | ✅ |
| Easton's Bible Dictionary (1897), 3,963 entries | Public domain | ✅ |
| Smith's Bible Dictionary (1863), 4,560 entries | Public domain | ✅ |
| KJV archaic word list, 163 entries | Source not recorded (item 6) | ⚠️ |
| Strong's Hebrew & Greek lexicon, 14,197 entries | Public domain text; edition not recorded (item 6) | ⚠️ |
| Topical plans: Nave's Topical Bible (1896), Torrey's New Topical Textbook (1897) | Public domain; normalized via j86schroeder/topical-bible-search (MIT). Already attributed per plan. | ✅ |
| Pericope headings (`assets/data/pericopes.json`) | Original work (drafts in `docs/pericopes/`) | ✅ |
| Word counts, BBE/WEB substitution list, dictionary tiers | Derived in-house from the texts above | ✅ |

## Devotional (Bible Stories)

| Item | License | Status |
| --- | --- | --- |
| Narrative summaries (The Graham Bible) | Unconfirmed (item 3) | ⚠️ |
| Gustave Doré plates (51 images, `assets/devotional/art/`) | Public domain; per-image sources in `tool/data/dore_credits.json` (Wikimedia Commons) | ✅ |

## Fonts (`assets/fonts/`)

All are licensed under the SIL Open Font License 1.1. The full text ships in `assets/licenses/OFL.txt`, and each family is registered with Flutter's `LicenseRegistry` (`lib/data/credits.dart`), so it appears under Settings → Credits & sources → Open-source licenses.

Alegreya, Bitter, Cardo, Cormorant Garamond, EB Garamond, Gentium Book Plus, IM FELL English, Inter, Lexend, Literata, Lora, Noto Serif, OpenDyslexic, Playfair Display, Source Sans 3. ✅

## Software packages

Every pub package's license is collected automatically by Flutter and shown on the open-source licenses page (`showLicensePage`). ✅ Run `flutter pub deps` when adding packages and avoid GPL/AGPL dependencies, which conflict with a proprietary app.

## App icon and other images

`assets/icon/app_icon.png`: original artwork, owned by the developer (confirm). ⚠️
