import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'posts'")
    columns = [row[0] for row in cur.fetchall()]
    print(f"Posts Columns: {columns}")
    
    cur.execute("SELECT * FROM \"posts\" LIMIT 1")
    colnames = [desc[0] for desc in cur.description]
    print(f"Cursor Description: {colnames}")
    
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
