import psycopg2

DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'

conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

try:
    print("=== Searching for ID 3 (smsm) in ALL tables ===")
    cur.execute("SELECT tablename FROM pg_tables WHERE schemaname='public'")
    tables = [t[0] for t in cur.fetchall()]
    
    for table in tables:
        cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name='{table}'")
        cols = [c[0] for c in cur.fetchall()]
        
        id_cols = [c for c in cols if c in ('student_id', 'user_id', 'id')]
        if not id_cols: continue
        
        for col in id_cols:
            try:
                cur.execute(f"SELECT COUNT(*) FROM {table} WHERE {col} = 3")
                count = cur.fetchone()[0]
                if count > 0:
                    print(f"Table {table}.{col} has {count} records for ID 3")
            except:
                pass

except Exception as e:
    print(f"Error: {e}")
finally:
    cur.close()
    conn.close()
