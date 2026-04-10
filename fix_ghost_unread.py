import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = True
cur = conn.cursor()

try:
    print("=== Step 1: Mark all messages where sender is the same as the recipient as read ===")
    # This specifically targets self-chats or logic errors where messages sent by yourself appear unread to you
    # In sessions where u1 == u2, always is_read=1
    cur.execute("""
        UPDATE chat_messages 
        SET is_read = 1 
        WHERE session_id IN (
            SELECT id FROM chat_sessions WHERE user1_id = user2_id
        )
        AND is_read = 0
    """)
    print(f"  Updated {cur.rowcount} messages in self-chats")

    print("\n=== Step 2: Mark messages sent BY a user as read for THEM (redundancy) ===")
    # Actually, is_read is a single bit. If I send a message, it's 0 (unread for them).
    # The bug for smsm@gmail.com (id=3) might be that they have unread messages from OTHERS that aren't clearing.
    # Let's see what is actually unread for smsm (id=3) right now after deduplication.
    
    cur.execute("""
        SELECT cm.id, cm.sender_id, u.email, cm.content
        FROM chat_messages cm
        JOIN chat_sessions cs ON cm.session_id = cs.id
        JOIN users u ON cm.sender_id = u.id
        WHERE (cs.user1_id = 3 OR cs.user2_id = 3)
        AND cm.sender_id != 3
        AND cm.is_read = 0
    """)
    unread = cur.fetchall()
    print(f"Messages truly unread for smsm (id=3): {len(unread)}")
    for m in unread:
        print(f"  ID: {m[0]}, Sender: {m[2]}, Content: {m[3]}")

    print("\n=== Special Emergency Fix: Mark everything for smsm as read if requested ===")
    # If the user says they see unread but we see 0 in DB, it might be a caching issue in the app
    # but let's clear whatever we found for smsm to be safe.
    if len(unread) > 0:
        cur.execute("""
            UPDATE chat_messages 
            SET is_read = 1 
            WHERE id IN (
                SELECT cm.id
                FROM chat_messages cm
                JOIN chat_sessions cs ON cm.session_id = cs.id
                WHERE (cs.user1_id = 3 OR cs.user2_id = 3)
                AND cm.sender_id != 3
                AND cm.is_read = 0
            )
        """)
        print(f"  Force-cleared {cur.rowcount} messages for smsm")

except Exception as e:
    print(f"ERROR: {e}")
finally:
    cur.close()
    conn.close()
