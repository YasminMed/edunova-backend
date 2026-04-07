import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("SELECT column_name, is_nullable, data_type FROM information_schema.columns WHERE table_name = 'posts'")
    columns = cur.fetchall()
    for col in columns:
        print(f"Column: {col[0]}, Nullable: {col[1]}, Type: {col[2]}")
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
