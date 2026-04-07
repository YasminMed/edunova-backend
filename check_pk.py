import psycopg2
import json

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("""
        SELECT
            tc.table_name, 
            kcu.column_name 
        FROM 
            information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
        WHERE tc.constraint_type = 'PRIMARY KEY' AND tc.table_name = 'users';
    """)
    pk = cur.fetchall()
    
    print("Primary keys on users table:", pk)
    
except Exception as e:
    print(e)
