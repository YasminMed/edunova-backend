import sqlite3
import os

db_path = 'test.db'
if not os.path.exists(db_path):
    # Try current directory or parent
    if os.path.exists('../test.db'):
        db_path = '../test.db'

print(f"Using DB: {os.path.abspath(db_path)}")
db = sqlite3.connect(db_path)
cursor = db.cursor()

lecturer_email = 'smsm@gmail.com'
cursor.execute('SELECT id FROM users WHERE email=?', (lecturer_email,))
row = cursor.fetchone()
if not row:
    print('Lecturer not found.')
else:
    lecturer_id = row[0]
    cursor.execute('SELECT id, name FROM courses WHERE lecturer_id=?', (lecturer_id,))
    courses = cursor.fetchall()
    c_ids = [c[0] for c in courses]

    print(f'Lecturer: {lecturer_email} (ID: {lecturer_id})')
    print(f'Courses: {courses}')

    if c_ids:
        placeholders = ','.join(['?'] * len(c_ids))
        cursor.execute(f'SELECT COUNT(*) FROM course_resources WHERE course_id IN ({placeholders})', c_ids)
        res_count = cursor.fetchone()[0]
        
        cursor.execute(f'SELECT COUNT(*) FROM assignments WHERE course_id IN ({placeholders})', c_ids)
        ass_count = cursor.fetchone()[0]
        
        cursor.execute(f'SELECT COUNT(*) FROM quizzes WHERE course_id IN ({placeholders})', c_ids)
        qz_count = cursor.fetchone()[0]
        
        print(f'CourseResource: {res_count}')
        print(f'Assignments: {ass_count}')
        print(f'Quizzes: {qz_count}')
        print(f'Total: {res_count + ass_count + qz_count}')
    else:
        print('No courses found.')
db.close()
