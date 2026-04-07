import sqlite3
import os

db_path = r'c:\src\flutter-apps\edunova-latest\edunova-backend\edunova.db'
if not os.path.exists(db_path):
    print(f"Database not found at {db_path}")
    # Try current directory
    db_path = 'edunova.db'

conn = sqlite3.connect(db_path)
cursor = conn.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()
print("Tables in database:")
for t in tables:
    print(f"- {t[0]}")

# Check content of weekly_challenges
try:
    cursor.execute("SELECT COUNT(*) FROM weekly_challenges")
    count = cursor.fetchone()[0]
    print(f"\nNumber of entries in weekly_challenges: {count}")
    if count > 0:
        cursor.execute("SELECT * FROM weekly_challenges LIMIT 5")
        rows = cursor.fetchall()
        for r in rows:
            print(r)
except Exception as e:
    print(f"\nError accessing weekly_challenges: {e}")

conn.close()
