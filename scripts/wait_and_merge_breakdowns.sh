#!/bin/bash
echo "Waiting for 11 breakdown JSON files..."

while true; do
    count=$(ls -1 scripts/breakdowns/*.json 2>/dev/null | wc -l)
    if [ "$count" -ge 11 ]; then
        echo "All 11 files generated!"
        break
    fi
    echo "Currently have $count/11 files. Waiting..."
    sleep 5
done

echo "Merging..."
python3 scripts/merge_all_breakdowns.py

echo "Committing..."
git add assets/commentary/commentary.json
git commit -m "feat: add comprehensive chapter breakdowns for the entire New Testament"
echo "Done!"
