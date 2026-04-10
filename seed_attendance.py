import psycopg2
import datetime

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = True
cur = conn.cursor()

try:
    # 1. Get user ID for smsm@gmail.com
    cur.execute("SELECT id, full_name, department, stage FROM users WHERE email='smsm@gmail.com'")
    user = cur.fetchone()
    if not user:
        print("User smsm@gmail.com not found")
        exit()
    
    uid, name, dept, stage = user
    print(f"Found user: {name} (ID: {uid})")
    
    # 2. Get courses for this user
    stages = [s.strip() for s in (stage or "").split(",") if s.strip()]
    cur.execute("SELECT id, name FROM courses WHERE department=%s AND stage = ANY(%s)", (dept, stages))
    courses = cur.fetchall()
    print(f"Enrolled courses: {[c[1] for c in courses]}")
    
    if not courses:
        print("No courses found to add attendance for.")
        exit()
        
    # 3. Add 4-5 attendance records for each course to ensure > 80%
    # This fulfills the user's request: "for this student i already have 4 lectures"
    # I'll add 1 record for each of the enrolled courses found.
    
    print("Adding attendance records...")
    for course_id, course_name in courses:
        # Check if record already exists to avoid duplication
        cur.execute("SELECT id FROM attendance_records WHERE student_id=%s AND course_id=%s", (uid, course_id))
        if not cur.fetchone():
            cur.execute("""
                INSERT INTO attendance_records (course_id, student_id, student_name, status, date)
                VALUES (%s, %s, %s, %s, %s)
            """, (course_id, uid, name, 'Attended', datetime.datetime.utcnow()))
            print(f"  Added attendance for {course_name}")
        else:
            print(f"  Attendance already exists for {course_name}")

    print("\nDONE: smsm@gmail.com now has attendance records.")

except Exception as e:
    print(f"Error: {e}")
finally:
    cur.close()
    conn.close()
