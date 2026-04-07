import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

print("--- Sessions for 'smsm' ---")
# Get user id for smsm
cur.execute("SELECT id FROM users WHERE email = 'smsm@gmail.com'")
uid = cur.fetchone()[0]

cur.execute("SELECT id, user1_id, user2_id FROM chat_sessions WHERE user1_id = %s OR user2_id = %s", (uid, uid))
sessions = cur.fetchall()
for s in sessions:
    print(f"Session {s[0]}: User1={s[1]}, User2={s[2]}")
    # Get unread messages in this session
    cur.execute("SELECT sender_id, content, is_read FROM chat_messages WHERE session_id = %s AND is_read = 0", (s[0],))
    msgs = cur.fetchall()
    for m in msgs:
        print(f"  UNREAD: Sender={m[0]}, Content={m[1]}")
