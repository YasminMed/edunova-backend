import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

def run():
    conn = psycopg2.connect(DATABASE_URL)
    conn.autocommit = True
    cur = conn.cursor()
    
    # 1. Fetch all users
    cur.execute("SELECT id, email FROM users ORDER BY id, email")
    users = cur.fetchall()
    
    # Find duplicates
    seen_ids = set()
    duplicates = []
    for u in users:
        uid, email = u[0], u[1]
        if uid in seen_ids:
            duplicates.append(u)
        else:
            seen_ids.add(uid)
            
    # Relocate duplicates to new IDs
    cur.execute("SELECT MAX(id) FROM users")
    max_id = cur.fetchone()[0] or 100
    next_id = max_id + 1
    
    print(f"Assigning new IDs starting from {next_id} for {len(duplicates)} duplicates...")
    for d in duplicates:
        old_id, email = d[0], d[1]
        cur.execute("UPDATE users SET id = %s WHERE email = %s", (next_id, email))
        print(f"Moved {email} from {old_id} to {next_id}")
        next_id += 1
        
    # 2. Add PRIMARY KEY constraint to ALL tables safely
    tables = [
        "users", "posts", "post_likes", "comments",
        "courses", "course_resources", "course_enrollments",
        "assignments", "assignment_submissions",
        "quizzes", "quiz_submissions",
        "exam_marks", "fee_installments",
        "chat_sessions", "chat_messages",
        "group_chats", "group_members", "group_messages",
        "activities", "challenges"
    ]
    
    for t in tables:
        try:
            cur.execute(f"ALTER TABLE {t} ADD PRIMARY KEY (id)")
            print(f"Added primary key to {t}")
        except Exception as e:
            print(f"Could not add PK to {t}: {e}")
            
    # Reset sequence again
    cur.execute("SELECT MAX(id) FROM users")
    final_max = cur.fetchone()[0] or 100
    cur.execute(f"SELECT setval('users_id_seq', {final_max + 1})")
    print("User sequence reset.")
    
try:
    run()
except Exception as e:
    print("Error:", e)
