import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

print("--- Messages in Session 3 ---")
cur.execute("SELECT id, sender_id, content, is_read FROM chat_messages WHERE session_id = 3 ORDER BY created_at")
msgs = cur.fetchall()
for m in msgs:
    print(m)

print("\n--- Users 3 and 13 ---")
cur.execute("SELECT id, email, full_name FROM users WHERE id IN (3, 13)")
for u in cur.fetchall():
    print(u)
