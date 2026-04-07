import os
import psycopg2
import re
from collections import deque

DATABASE_URL = "postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway"
BACKUP_FILE = "edunova_backup.sql"

# Table insertion order for foreign key compliance
TABLE_ORDER = [
    "users",
    "weekly_challenges",
    "courses",
    "posts",
    "chat_sessions",
    "group_chats",
    "activities",
    "fee_installments",
    "course_resources",
    "attendance_records",
    "assignments",
    "quizzes",
    "exam_marks",
    "post_likes",
    "chat_messages",
    "group_members",
    "group_messages",
    "challenge_completions",
    "comments",
    "assignment_submissions",
    "quiz_submissions"
]

def migrate():
    if not os.path.exists(BACKUP_FILE):
        print(f"Error: {BACKUP_FILE} not found.")
        return

    print(f"Connecting to Railway PostgreSQL...")
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    print(f"Reading {BACKUP_FILE}...")
    with open(BACKUP_FILE, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract INSERT INTO statements
    # Pattern: INSERT INTO "table_name" (...) VALUES (...);
    insert_pattern = re.compile(r'INSERT INTO "([^"]+)" .*?;', re.DOTALL)
    inserts = insert_pattern.findall(content)
    full_inserts = insert_pattern.finditer(content)

    # Group inserts by table
    grouped_inserts = {table: [] for table in TABLE_ORDER}
    for match in full_inserts:
        table_name = match.group(1)
        if table_name in grouped_inserts:
            grouped_inserts[table_name].append(match.group(0))
        else:
            print(f"Warning: Unexpected table '{table_name}' found in backup.")

    print(f"Starting migration...")
    try:
        # Disable constraints temporarily for faster/easier import if possible, 
        # but manual ordering is safer for standard users.
        # cur.execute("SET session_replication_role = 'replica';")

        total_inserted = 0
        for table in TABLE_ORDER:
            table_statements = grouped_inserts.get(table, [])
            if not table_statements:
                continue
            
            print(f"Inserting into {table} ({len(table_statements)} records)...")
            for stmt in table_statements:
                # Fix any potential syntax issues (e.g., PostgreSQL might need double quotes handled differently if any)
                cur.execute(stmt)
                total_inserted += 1
            
            # Reset the sequence for the primary key 'id' to avoid duplicate key errors on future inserts
            # PostgreSQL command: SELECT setval(pg_get_serial_sequence('table', 'id'), coalesce(max(id),0) + 1, false) FROM table;
            try:
                cur.execute(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), coalesce(max(id),0) + 1, false) FROM \"{table}\";")
            except Exception as seq_err:
                # Some tables might not have serial ids or different naming, ignore sequence reset errors for now
                pass

        conn.commit()
        print(f"Migration successful! Total records inserted: {total_inserted}")

    except Exception as e:
        conn.rollback()
        print(f"Migration failed at table '{table}': {e}")
        print("Rollback performed.")
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    migrate()
