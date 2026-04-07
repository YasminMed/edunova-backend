from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

# Database Configuration
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

if SQLALCHEMY_DATABASE_URL:
    # Standardize postgres prefix for SQLAlchemy compatibility
    if SQLALCHEMY_DATABASE_URL.startswith("postgres://"):
        SQLALCHEMY_DATABASE_URL = SQLALCHEMY_DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    # Check for internal vs external Railway URL for debugging
    is_internal = "railway.internal" in SQLALCHEMY_DATABASE_URL
    conn_type = "Internal (Preferred)" if is_internal else "External (Link)"
    display_url = SQLALCHEMY_DATABASE_URL.split("@")[-1]  # Hide credentials
    print(f"DATABASE_STATUS: Connected to PostgreSQL ({conn_type}) -> {display_url}")
else:
    print("DATABASE_STATUS: WARNING - DATABASE_URL NOT FOUND. Falling back to ephemeral SQLite (test.db).")
    SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
