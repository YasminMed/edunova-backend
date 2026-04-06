import os
from sqlalchemy import create_engine, inspect
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv("DATABASE_URL")
if db_url and db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

if not db_url:
    print("No DATABASE_URL found")
    exit(1)

engine = create_engine(db_url)
inspector = inspect(engine)

for table_name in inspector.get_table_names():
    print(f"\nTable: {table_name}")
    for column in inspector.get_columns(table_name):
        print(f"  - {column['name']}: {column['type']}")
