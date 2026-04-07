import psycopg2
import json

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("SELECT id, email, full_name, role FROM users")
    
    with open('users_all.txt', 'w') as f:
        for row in cur.fetchall():
            f.write(f"ID: {row[0]}, Email: {row[1]}, Name: {row[2]}, Role: {row[3]}\n")
            
except Exception as e:
    with open('users_all.txt', 'w') as f:
        f.write(str(e))
