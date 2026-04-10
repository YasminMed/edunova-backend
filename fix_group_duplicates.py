import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = False
cur = conn.cursor()

try:
    print("=== Step 1: Check current group_chats structure ===")
    cur.execute("SELECT id, name, admin_id, photo_url FROM group_chats ORDER BY id")
    rows = cur.fetchall()
    for r in rows:
        print(r)

    print("\n=== Step 2: Remove duplicates (keep only first occurrence via ctid) ===")
    # Delete all but the first physical row per (id) group
    cur.execute("""
        DELETE FROM group_chats
        WHERE ctid NOT IN (
            SELECT MIN(ctid)
            FROM group_chats
            GROUP BY id
        )
    """)
    print(f"  Deleted {cur.rowcount} duplicate rows")

    print("\n=== Step 3: Add PRIMARY KEY constraint ===")
    try:
        cur.execute("ALTER TABLE group_chats ADD PRIMARY KEY (id)")
        print("  PRIMARY KEY added to group_chats")
    except Exception as e:
        print(f"  PK already exists or error: {e}")

    print("\n=== Step 4: Also fix group_members if duplicates exist ===")
    cur.execute("SELECT id, group_id, user_id, COUNT(*) FROM group_members GROUP BY id, group_id, user_id HAVING COUNT(*) > 1")
    dupes = cur.fetchall()
    print(f"  group_members duplicates: {dupes}")
    if dupes:
        cur.execute("""
            DELETE FROM group_members
            WHERE ctid NOT IN (
                SELECT MIN(ctid) FROM group_members GROUP BY id
            )
        """)
        print(f"  Deleted {cur.rowcount} duplicate group_member rows")

    try:
        cur.execute("ALTER TABLE group_members ADD PRIMARY KEY (id)")
        print("  PRIMARY KEY added to group_members")
    except Exception as e:
        print(f"  group_members PK: {e}")

    print("\n=== Step 5: Fix sequence for group_chats ===")
    cur.execute("SELECT MAX(id) FROM group_chats")
    max_id = cur.fetchone()[0] or 1
    cur.execute(f"SELECT setval('group_chats_id_seq', {max_id + 1})")
    print(f"  group_chats sequence set to {max_id + 1}")

    conn.commit()
    print("\n=== DONE — all changes committed ===")

    # Verify
    cur.execute("SELECT id, name, admin_id FROM group_chats ORDER BY id")
    print("\nGroup chats after fix:")
    for r in cur.fetchall():
        print(r)

except Exception as e:
    conn.rollback()
    print(f"\nERROR: {e}")
finally:
    cur.close()
    conn.close()
