#!/bin/sh
# Fails if any bundled database is a Git LFS pointer or not SQLite.
# Use in CI before `flutter build`, and as an Xcode "Run Script" build phase
# (placed before the Flutter "Run Script" phase):
#   "$SRCROOT/../scripts/verify_content_assets.sh"
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
status=0
for f in "$ROOT/assets/bible/bible.db" "$ROOT"/assets/packs/*.db; do
  if [ "$(head -c 15 "$f" 2>/dev/null)" != "SQLite format 3" ]; then
    echo "error: $f is not a SQLite database (Git LFS pointer?). Run: git lfs install && git lfs pull" >&2
    status=1
  fi
done
exit $status
