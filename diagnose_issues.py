import psycopg2, datetime

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

smsm_id = 3  # confirmed

print("=== Attendance records (attendance_records table) ===")
cur.execute("""
    SELECT ar.id, ar.course_id, ar.student_id, ar.status, ar.date,
           c.name as course_name
    FROM attendance_records ar
    JOIN courses c ON c.id = ar.course_id
    WHERE ar.student_id = %s
    ORDER BY ar.date DESC
""", (smsm_id,))
att = cur.fetchall()
print(f"Total attendance records for smsm: {len(att)}")
for r in att:
    print(f"  id={r[0]} course={r[5]}(id={r[1]}) status={r[3]} date={r[4]}")

# What's this week?
today = datetime.datetime.utcnow()
week_start = today - datetime.timedelta(days=today.weekday())
week_start = week_start.replace(hour=0, minute=0, second=0, microsecond=0)
print(f"\nThis week starts: {week_start}")

cur.execute("""
    SELECT ar.id, ar.course_id, ar.status, ar.date, c.name
    FROM attendance_records ar
    JOIN courses c ON c.id = ar.course_id
    WHERE ar.student_id = %s AND ar.date >= %s
""", (smsm_id, week_start))
this_week = cur.fetchall()
print(f"Attendance THIS WEEK: {len(this_week)}")
for r in this_week:
    print(f"  date={r[3]} course={r[4]} status={r[2]}")

print("\n=== Courses for smsm dept/stage ===")
cur.execute("SELECT department, stage FROM users WHERE id=%s", (smsm_id,))
dept, stage = cur.fetchone()
print(f"dept={dept}, stage={stage}")
# stage might be comma-separated like "Third Stage, Fourth Stage"
stages = [s.strip() for s in stage.split(',')]
cur.execute("SELECT id, name, department, stage FROM courses WHERE department=%s AND stage = ANY(%s)", (dept, stages))
courses = cur.fetchall()
print(f"Enrolled courses: {len(courses)}")
for c in courses:
    print(f"  id={c[0]} name={c[1]} dept={c[2]} stage={c[3]}")

print("\n=== Chat sessions duplicate check (sessions 1, 6 appear twice) ===")
cur.execute("SELECT id, user1_id, user2_id FROM chat_sessions WHERE user1_id=%s OR user2_id=%s ORDER BY id", (smsm_id, smsm_id))
sessions = cur.fetchall()
print("Sessions (should have no duplicates):", sessions)

cur.close()
conn.close()
