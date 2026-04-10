import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

try:
    print("=== Users check ===")
    cur.execute("SELECT id, email, full_name, role FROM users WHERE email ILIKE 'smsm%' OR full_name ILIKE 'smsm%'")
    users = cur.fetchall()
    for u in users:
        print(f"User: ID={u[0]}, Email={u[1]}, Name={u[2]}, Role={u[3]}")

    print("\n=== Attendance distribution ===")
    cur.execute("SELECT student_id, COUNT(*) FROM attendance_records GROUP BY student_id")
    dist = cur.fetchall()
    for d in dist:
        cur.execute("SELECT email FROM users WHERE id=%s", (d[0],))
        email = cur.fetchone()[0] if cur.rowcount > 0 else "Unknown"
        print(f"Student ID {d[0]} ({email}) has {d[1]} records")

    print("\n=== All distinct statuses ===")
    cur.execute("SELECT DISTINCT status FROM attendance_records")
    print(cur.fetchall())

except Exception as e:
    print(f"Error: {e}")
finally:
    cur.close()
    conn.close()
