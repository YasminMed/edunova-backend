import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = True
cur = conn.cursor()

# 1. Check group_chats for duplicates
cur.execute("SELECT id, name, admin_id, COUNT(*) FROM group_chats GROUP BY id, name, admin_id HAVING COUNT(*) > 1")
dupes = cur.fetchall()
print("Duplicate group rows:", dupes)

cur.execute("SELECT id, name, admin_id, photo_url FROM group_chats ORDER BY id")
all_groups = cur.fetchall()
print("All group_chats rows:")
for g in all_groups:
    print(g)

# 2. Check if group_chats has a proper PRIMARY KEY constraint
cur.execute("""
    SELECT constraint_name, constraint_type 
    FROM information_schema.table_constraints 
    WHERE table_name = 'group_chats' AND constraint_type IN ('PRIMARY KEY', 'UNIQUE')
""")
constraints = cur.fetchall()
print("Constraints on group_chats:", constraints)

cur.close()
conn.close()
