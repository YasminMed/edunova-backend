import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = False
cur = conn.cursor()

try:
    print("=== Step 1: Deduplicate chat_sessions ===")
    cur.execute("SELECT id, user1_id, user2_id, COUNT(*) FROM chat_sessions GROUP BY id, user1_id, user2_id HAVING COUNT(*) > 1")
    dupes = cur.fetchall()
    print(f"Duplicate session rows: {dupes}")

    cur.execute("""
        DELETE FROM chat_sessions
        WHERE ctid NOT IN (
            SELECT MIN(ctid) FROM chat_sessions GROUP BY id
        )
    """)
    print(f"  Deleted {cur.rowcount} duplicate chat_session rows")

    try:
        cur.execute("ALTER TABLE chat_sessions ADD PRIMARY KEY (id)")
        print("  PRIMARY KEY added to chat_sessions")
    except Exception as e:
        print(f"  chat_sessions PK: {e}")

    print("\n=== Step 2: Deduplicate chat_messages ===")
    cur.execute("SELECT id, COUNT(*) FROM chat_messages GROUP BY id HAVING COUNT(*) > 1")
    msg_dupes = cur.fetchall()
    print(f"Duplicate message rows: {len(msg_dupes)}")
    if msg_dupes:
        cur.execute("""
            DELETE FROM chat_messages WHERE ctid NOT IN (
                SELECT MIN(ctid) FROM chat_messages GROUP BY id
            )
        """)
        print(f"  Deleted {cur.rowcount} duplicate message rows")

    try:
        cur.execute("ALTER TABLE chat_messages ADD PRIMARY KEY (id)")
        print("  PRIMARY KEY added to chat_messages")
    except Exception as e:
        print(f"  chat_messages PK: {e}")

    print("\n=== Step 3: Fix sender's own messages — mark as read if sender=smsm (id=3) ===")
    # Messages sent BY smsm should not appear as unread for smsm.
    # When smsm sends a message, is_read should start as 1 (already "seen" by sender)
    # Let's mark all messages sent BY smsm as is_read=1 IF the other person in the session already opened the chat
    # Actually the issue is: messages SENT BY smsm to others should not count as unread from smsm's view
    # The backend already does: sender_id == other_user.id — so this is correct.
    # The problem is duplicate sessions causing double-count.
    # After deduplication, recheck.
    
    print("\n=== Step 4: Fix sequences ===")
    cur.execute("SELECT MAX(id) FROM chat_sessions")
    max_id = cur.fetchone()[0] or 1
    cur.execute(f"SELECT setval('chat_sessions_id_seq', {max_id + 1})")
    print(f"  chat_sessions sequence set to {max_id + 1}")

    cur.execute("SELECT MAX(id) FROM chat_messages")
    max_id = cur.fetchone()[0] or 1
    cur.execute(f"SELECT setval('chat_messages_id_seq', {max_id + 1})")
    print(f"  chat_messages sequence set to {max_id + 1}")

    conn.commit()
    print("\n=== DONE ===")
    
    # Verify
    cur.execute("SELECT id, user1_id, user2_id FROM chat_sessions ORDER BY id")
    print("\nchat_sessions after fix:")
    for r in cur.fetchall():
        print(r)

except Exception as e:
    conn.rollback()
    print(f"\nERROR: {e}")
finally:
    cur.close()
    conn.close()
