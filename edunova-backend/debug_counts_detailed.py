import sqlite3
import os

db_path = 'test.db'
if not os.path.exists(db_path):
    if os.path.exists('../test.db'):
        db_path = '../test.db'

print(f"Using DB: {os.path.abspath(db_path)}")
db = sqlite3.connect(db_path)
cursor = db.cursor()

lecturer_email = 'smsm@gmail.com'
cursor.execute('SELECT id, full_name FROM users WHERE email=?', (lecturer_email,))
row = cursor.fetchone()
if not row:
    print('Lecturer not found.')
else:
    lect_id, name = row
    print(f'Lecturer: {name} ({lecturer_email}, ID: {lect_id})')
    
    cursor.execute('SELECT id, name FROM courses WHERE lecturer_id=?', (lect_id,))
    courses = cursor.fetchall()
    print(f'Courses ({len(courses)}): {courses}')
    
    if courses:
        c_ids = [c[0] for c in courses]
        placeholders = ','.join(['?'] * len(c_ids))
        
        # CourseResource details
        cursor.execute(f'SELECT category, COUNT(*) FROM course_resources WHERE course_id IN ({placeholders}) GROUP BY category', c_ids)
        resources = cursor.fetchall()
        print(f'CourseResources by Category: {resources}')
        
        # Assignment details
        cursor.execute(f'SELECT category, COUNT(*) FROM assignments WHERE course_id IN ({placeholders}) GROUP BY category', c_ids)
        assignments = cursor.fetchall()
        print(f'Assignments by Category: {assignments}')
        
        # Quiz details
        cursor.execute(f'SELECT COUNT(*) FROM quizzes WHERE course_id IN ({placeholders})', c_ids)
        qz_count = cursor.fetchone()[0]
        print(f'Quizzes (Quiz table): {qz_count}')
        
        total = sum([r[1] for r in resources]) + sum([a[1] for a in assignments]) + qz_count
        print(f'Total Materials Calculated: {total}')
    else:
        print('No courses found.')

db.close()
