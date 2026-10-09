# Tooling & Content Scripts

This directory consolidates data generation, verification, and asset preparation scripts for The Blessed Bible app.

## Contents

- `evaluate_headings.jq`: JQ filter used during content audits to compare and evaluate chapter titles vs. pericope headings across book texts.
- `build_bible_db.dart`: Builds and compiles SQLite database from raw verse sources.
- `build_content.py` & `content_sizes.py`: Utility scripts for assembling and profiling content packages.
- `generate_reading_plan.dart`: Generates structured reading plans.
- `commentary-studio.html`: Local visual studio for reviewing verse-by-verse commentary data.
- `devotional_common.py`, `export_bible_stories.py`, `fetch_dore_art.py`: Utilities for devotional artwork and story packaging.
