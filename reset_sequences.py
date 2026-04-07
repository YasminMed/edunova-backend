import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

def reset_sequences():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()
        
        tables = [
            'users', 'posts', 'comments', 'chat_sessions', 'group_chats',
            'chat_messages', 'group_messages', 'activities', 'courses',
            'course_resources', 'attendance_records', 'assignments',
            'quizzes', 'exam_marks', 'assignment_submissions', 'quiz_submissions'
        ]
        
        for table in tables:
            try:
                # Reset sequence for 'id' column on each table
                query = f"SELECT setval(pg_get_serial_sequence('\"{table}\"', 'id'), COALESCE(MAX(id), 1)) FROM \"{table}\";"
                print(f"Resetting: {table}")
                cur.execute(query)
                res = cur.fetchone()
                print(f"New Sequence Value for {table}: {res[0]}")
            except Exception as table_err:
                print(f"Skipping {table}: {table_err}")
                conn.rollback() # Rollback to continue with next table
                continue
            
        conn.commit()
        print("Final sequence synchronization complete.")
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Critical Error: {e}")

if __name__ == "__main__":
    reset_sequences()
