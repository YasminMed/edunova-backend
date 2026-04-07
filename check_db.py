import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    tables = ['users', 'posts', 'comments', 'courses', 'activities']
    for t in tables:
        cur.execute(f'SELECT count(*) FROM "{t}"')
        print(f'{t}: {cur.fetchone()[0]}')
    cur.close()
    conn.close()
except Exception as e:
    print(f'Error: {e}')
