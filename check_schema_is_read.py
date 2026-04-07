import psycopg2
DATABASE_URL = 'postgresql://postgres:OCpJfWUiXcOOOKCFeGXYqWUwepFDTuIa@hopper.proxy.rlwy.net:51247/railway'
conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()
cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'chat_messages' AND column_name = 'is_read'")
print(cur.fetchone())
