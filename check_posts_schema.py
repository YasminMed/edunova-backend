import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'posts'")
    for row in cur.fetchall():
        print(f"Column: {row[0]}, Nullable: {row[1]}")
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
