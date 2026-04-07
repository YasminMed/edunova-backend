
import sqlite3

def check_users():
    try:
        conn = sqlite3.connect('test.db')
        cursor = conn.cursor()
        cursor.execute("SELECT id, email, full_name, role FROM users")
        users = cursor.fetchall()
        print("--- LOCAL USERS ---")
        for u in users:
            print(u)
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_users()
