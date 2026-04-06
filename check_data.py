import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv("DATABASE_URL")
if db_url and db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

if not db_url:
    print("No DATABASE_URL found")
    exit(1)

engine = create_engine(db_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

tables = [
    "users", "assignments", "assignment_submissions", 
    "quizzes", "quiz_submissions", "attendance", 
    "weekly_challenges", "user_weekly_challenges"
]

print("Database Row Counts:")
for table in tables:
    try:
        count = db.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
        print(f"  {table}: {count}")
    except Exception as e:
        print(f"  {table}: ERROR ({e})")

db.close()
