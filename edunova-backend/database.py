from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

# Railway provides DATABASE_URL. We need to handle the 'postgres://' vs 'postgresql://' issue if it arises
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
if SQLALCHEMY_DATABASE_URL:
    print("DEBUG: DATABASE_URL found in environment")
    if SQLALCHEMY_DATABASE_URL.startswith("postgres://"):
        SQLALCHEMY_DATABASE_URL = SQLALCHEMY_DATABASE_URL.replace("postgres://", "postgresql://", 1)
else:
    print("DEBUG: DATABASE_URL NOT FOUND. Falling back to SQLite.")

# Default to sqlite for local testing if no DATABASE_URL is provided
if not SQLALCHEMY_DATABASE_URL:
    SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

print(f"DEBUG: Initializing engine with URL: {SQLALCHEMY_DATABASE_URL.split('@')[-1]}") # Masking credentials

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
