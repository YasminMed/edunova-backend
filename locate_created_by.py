import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("SELECT table_name, column_name FROM information_schema.columns WHERE column_name = 'created_by'")
    for row in cur.fetchall():
        print(f"Table: {row[0]}, Column: {row[1]}")
    
    cur.execute("SELECT tgname, relname FROM pg_trigger JOIN pg_class ON pg_trigger.tgrelid = pg_class.oid WHERE relname = 'posts'")
    for row in cur.fetchall():
        print(f"Trigger: {row[0]} on {row[1]}")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
