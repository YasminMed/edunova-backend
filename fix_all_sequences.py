"""
Fix all broken PostgreSQL sequences across all tables.
The "null value in column id" error means the sequence is not attached to the column.
"""
import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

tables = [
    "users", "posts", "post_likes", "comments",
    "courses", "course_resources", "course_enrollments",
    "assignments", "assignment_submissions",
    "quizzes", "quiz_submissions",
    "exam_marks", "fee_installments",
    "chat_sessions", "chat_messages",
    "group_chats", "group_members", "group_messages",
    "activities", "challenges",
]

try:
    conn = psycopg2.connect(DATABASE_URL)
    conn.autocommit = True
    cur = conn.cursor()

    for table in tables:
        try:
            # Check if table exists
            cur.execute(f"SELECT to_regclass('public.{table}')")
            if cur.fetchone()[0] is None:
                print(f"SKIP: {table} does not exist")
                continue

            # Get the max id
            cur.execute(f"SELECT MAX(id) FROM {table}")
            max_id = cur.fetchone()[0] or 0
            next_val = max_id + 1

            seq_name = f"{table}_id_seq"

            # Create sequence if not exists
            cur.execute(f"CREATE SEQUENCE IF NOT EXISTS {seq_name} START {next_val}")

            # Set the sequence value to max+1
            cur.execute(f"SELECT setval('{seq_name}', {next_val})")

            # Attach sequence to the id column
            cur.execute(f"ALTER TABLE {table} ALTER COLUMN id SET DEFAULT nextval('{seq_name}')")

            print(f"FIXED: {table}.id -> next={next_val}")

        except Exception as e:
            print(f"ERROR on {table}: {e}")

    cur.close()
    conn.close()
    print("\nAll sequences fixed!")

except Exception as e:
    print(f"Connection error: {e}")
