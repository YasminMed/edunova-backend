import sqlite3
import os

db_path = 'c:/src/flutter-apps/edunova-latest/edunova-backend/edunova.db'
if not os.path.exists(db_path):
    # Try current directory too
    db_path = 'edunova.db'
    if not os.path.exists(db_path):
        print("DB not found at", db_path)
        exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("--- Chat Sessions ---")
cursor.execute("SELECT id, user1_id, user2_id FROM chat_sessions")
sessions = cursor.fetchall()
for s in sessions:
    print(f"ID: {s[0]}, Users: {s[1]} & {s[2]}")

print("\n--- Duplicate Check ---")
cursor.execute("""
    SELECT user1_id, user2_id, COUNT(*) 
    FROM chat_sessions 
    GROUP BY user1_id, user2_id 
    HAVING COUNT(*) > 1
""")
dupes = cursor.fetchall()
if dupes:
    for d in dupes:
        print(f"Users {d[0]} & {d[1]} have {d[2]} duplicate sessions (forward)")
else:
    print("No duplicates in user1->user2 direction.")

# Cross-directional check
# Check if two rows exist where (u1, u2) and (u2, u1) match
cursor.execute("""
    SELECT s1.id, s2.id, s1.user1_id, s1.user2_id 
    FROM chat_sessions s1
    JOIN chat_sessions s2 ON s1.user1_id = s2.user2_id AND s1.user2_id = s2.user1_id
    WHERE s1.id < s2.id
""")
cross_dupes = cursor.fetchall()
if cross_dupes:
    for cd in cross_dupes:
        print(f"Session {cd[0]} and {cd[1]} are cross-duplicates for users {cd[2]} & {cd[3]}")
else:
    print("No cross-duplicates found.")

print("\n--- Recent Messages ---")
cursor.execute("""
    SELECT m.id, m.session_id, m.sender_id, m.content, m.is_read 
    FROM chat_messages m
    ORDER BY m.id DESC LIMIT 10
""")
msgs = cursor.fetchall()
for m in msgs:
    print(f"MsgID: {m[0]}, Session: {m[1]}, SenderID: {m[2]}, Content: {m[3]}, IsRead: {m[4]}")

conn.close()
