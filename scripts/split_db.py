import sqlite3
import os
import shutil

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'assets', 'bible', 'bible.db')

KEEP_TRANSLATIONS = [
    'kjv', 'web', 'bbe', 'kjv_strongs', 
    'swh_ulb', 'ita_dio', 'ron_btf', 'fra_lsg', 'tgl_ulb'
]

def main():
    if not os.path.exists(DB_PATH):
        print(f"DB not found at {DB_PATH}")
        return

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Get all translation IDs
    cursor.execute("SELECT translation_id FROM translations")
    all_translations = [row[0] for row in cursor.fetchall()]

    extract_translations = [t for t in all_translations if t not in KEEP_TRANSLATIONS]
    print(f"Extracting: {extract_translations}")

    for trans in extract_translations:
        new_db_path = os.path.join(BASE_DIR, 'assets', 'bible', f'bible_{trans}.db')
        print(f"Processing {trans} -> {new_db_path}")

        # Connect to new DB
        if os.path.exists(new_db_path):
            os.remove(new_db_path)
        new_conn = sqlite3.connect(new_db_path)
        new_cursor = new_conn.cursor()

        # Copy schema
        cursor.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name IN ('translations', 'verses')")
        for row in cursor.fetchall():
            if row[0]:
                new_cursor.execute(row[0])
        
        # Insert translation data
        cursor.execute("SELECT * FROM translations WHERE translation_id = ?", (trans,))
        trans_row = cursor.fetchone()
        placeholders = ','.join(['?'] * len(trans_row))
        new_cursor.execute(f"INSERT INTO translations VALUES ({placeholders})", trans_row)

        # Insert verses
        cursor.execute("SELECT * FROM verses WHERE translation_id = ?", (trans,))
        verses_rows = cursor.fetchall()
        placeholders = ','.join(['?'] * len(verses_rows[0]))
        new_cursor.executemany(f"INSERT INTO verses VALUES ({placeholders})", verses_rows)

        # Create index if any
        cursor.execute("SELECT sql FROM sqlite_master WHERE type='index' AND tbl_name='verses'")
        for row in cursor.fetchall():
            if row[0]:
                new_cursor.execute(row[0])

        new_conn.commit()
        new_conn.close()

        # Delete from main db
        print(f"Deleting {trans} from main DB...")
        cursor.execute("DELETE FROM verses WHERE translation_id = ?", (trans,))
        cursor.execute("DELETE FROM translations WHERE translation_id = ?", (trans,))

    conn.commit()
    print("Vacuuming main DB...")
    cursor.execute("VACUUM")
    conn.commit()
    conn.close()
    print("Done!")

if __name__ == '__main__':
    main()
