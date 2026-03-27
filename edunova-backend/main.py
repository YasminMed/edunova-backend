from fastapi import FastAPI, HTTPException, Depends, status, File, UploadFile, Form, Body
from typing import Optional, List
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from fpdf import FPDF
import uvicorn
import secrets
import os
import shutil
import datetime
import tempfile
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, FileResponse

import sys
import os

# Add current directory to path to help with imports
# Trigger deployment for music page changes
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.append(current_dir)

try:
    import models
    import database
    from database import engine, get_db, SessionLocal
except ImportError:
    try:
        from . import models
        from . import database
        from .database import engine, get_db, SessionLocal
    except ImportError:
        # Final fallback for some environments
        sys.path.append(os.path.join(current_dir, ".."))
        import models
        import database
        from database import engine, get_db, SessionLocal

app = FastAPI(title="EduNova API")

# Add CORS middleware for Flutter web/mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure the static directory exists before mounting to avoid errors
if not os.path.exists("static"):
    os.makedirs("static")

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static_assets")

# Catch-all route to serve the SPA index.html for unknown routes
@app.get("/{full_path:path}")
async def serve_spa(full_path: str):
    # This serves the index.html for any route not matched by the API
    # to support the SPA routing in Flutter.
    index_file = os.path.join("static", "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file)
    return HTMLResponse(content="<h1>Flutter build not found</h1>", status_code=404)

# Create uploads directory if it doesn't exist
UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

# Serve static files from uploads directory
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# --- Global Helpers ---

def to_float(val):
    if val is None or val == "": return 0.0
    try:
        val_str = str(val)
        if "/" in val_str:
            parts = val_str.split("/")
            return (float(parts[0]) / float(parts[1])) * 100
        return float(val_str)
    except: return 0.0

def get_grade_letter(perc):
    if perc >= 95: return "A+"
    if perc >= 90: return "A"
    if perc >= 85: return "A-"
    if perc >= 80: return "B+"
    if perc >= 75: return "B"
    if perc >= 70: return "C+"
    if perc >= 60: return "C"
    if perc >= 50: return "D"
    return "F"

class UserAuth(BaseModel):
    email: EmailStr
    password: str
    fullName: Optional[str] = None
    gender: str = "Male"
    role: str = "student" # "student" or "lecturer"
    department: Optional[str] = None
    stage: Optional[str] = None
    years_of_experience: Optional[int] = 0
    image_url: Optional[str] = None

class OTPRequest(BaseModel):
    email: EmailStr

class VerifyOTPRequest(BaseModel):
    email: EmailStr
    otp: str

@app.on_event("startup")
async def startup_event():
    print("DEBUG: Running startup event...")
    try:
        models.Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"DEBUG: create_all hint: {e}")

    db = SessionLocal()
    try:
        from sqlalchemy import text
        
        # Safe column addition Helper
        def add_col_safe(table, column, type_str, default=None):
            try:
                # Basic check if column exists (Postgres/SQLite compatible-ish check)
                db.execute(text(f"SELECT {column} FROM {table} LIMIT 1"))
            except Exception:
                db.rollback()
                try:
                    default_str = f" DEFAULT {default}" if default else ""
                    db.execute(text(f"ALTER TABLE {table} ADD COLUMN {column} {type_str}{default_str}"))
                    db.commit()
                    print(f"DEBUG: Added {column} to {table}")
                except Exception as e2:
                    db.rollback()
                    print(f"DEBUG: Could not add {column}: {e2}")

        add_col_safe("users", "role", "VARCHAR", "'student'")
        add_col_safe("users", "department", "VARCHAR")
        add_col_safe("users", "stage", "VARCHAR")
        add_col_safe("users", "years_of_experience", "INTEGER", "0")
        add_col_safe("users", "image_url", "VARCHAR")
        add_col_safe("courses", "image_url", "VARCHAR")
        add_col_safe("courses", "department", "VARCHAR", "'Software Engineering'")
        add_col_safe("courses", "stage", "VARCHAR", "'First Stage'")
        add_col_safe("posts", "image_url", "VARCHAR")

        # Broad Auto-fix for existing users with NULL department/stage
        all_users = db.query(models.User).all()
        for u in all_users:
            updated = False
            if u.department is None:
                u.department = "Software Engineering"
                updated = True
            
            # Standardize stage names and fix specific user profiles
            if u.stage is None or u.email in ["smsm@gmail.com", "smsm2@gmail.com"]:
                role_lower = str(u.role or "student").lower()
                if role_lower == "student":
                    u.stage = "Fourth Stage"
                else:
                    u.stage = "Third Stage, Fourth Stage"
                updated = True
            elif u.stage == "1st":
                u.stage = "First Stage"
                updated = True
            
            # Ensure yaso has her stage too
            if u.email == "yaso@gmail.com" and (not u.stage or u.stage == "First Stage"):
                u.stage = "Fourth Stage"
                updated = True
                
            if updated:
                db.add(u)
        db.commit()
        print("DEBUG: User profiles updated")

        # For Course table

        # Create tables using standard SQL where possible or detect engine
        is_pg = "postgresql" in str(engine.url)
        
        def run_sql(sql_pg, sql_lite):
            try:
                db.execute(text(sql_pg if is_pg else sql_lite))
                db.commit()
            except Exception as e:
                db.rollback()
                print(f"DEBUG Migration Error: {e}")

        run_sql(
            "CREATE TABLE IF NOT EXISTS quizzes (id SERIAL PRIMARY KEY, course_id INTEGER REFERENCES courses(id), title VARCHAR NOT NULL, content TEXT NOT NULL, file_url TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS quizzes (id INTEGER PRIMARY KEY AUTOINCREMENT, course_id INTEGER REFERENCES courses(id), title VARCHAR NOT NULL, content VARCHAR NOT NULL, file_url VARCHAR, created_at DATETIME)"
        )
        
        run_sql(
            "CREATE TABLE IF NOT EXISTS quiz_submissions (id SERIAL PRIMARY KEY, quiz_id INTEGER REFERENCES quizzes(id), student_id INTEGER REFERENCES users(id), solution_text TEXT, file_url TEXT, grade VARCHAR, lecturer_note TEXT, submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, is_graded INTEGER DEFAULT 0)",
            "CREATE TABLE IF NOT EXISTS quiz_submissions (id INTEGER PRIMARY KEY AUTOINCREMENT, quiz_id INTEGER REFERENCES quizzes(id), student_id INTEGER REFERENCES users(id), solution_text VARCHAR, file_url VARCHAR, grade VARCHAR, lecturer_note VARCHAR, submitted_at DATETIME, is_graded INTEGER DEFAULT 0)"
        )
        
        run_sql(
            "CREATE TABLE IF NOT EXISTS exam_marks (id SERIAL PRIMARY KEY, course_id INTEGER REFERENCES courses(id), student_id INTEGER REFERENCES users(id), exam_type VARCHAR NOT NULL, mark VARCHAR NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS exam_marks (id INTEGER PRIMARY KEY AUTOINCREMENT, course_id INTEGER REFERENCES courses(id), student_id INTEGER REFERENCES users(id), exam_type VARCHAR NOT NULL, mark VARCHAR NOT NULL, created_at DATETIME)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS chat_sessions (id SERIAL PRIMARY KEY, user1_id INTEGER REFERENCES users(id), user2_id INTEGER REFERENCES users(id), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS chat_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, user1_id INTEGER REFERENCES users(id), user2_id INTEGER REFERENCES users(id), created_at DATETIME)"
        )
        
        run_sql(
            "CREATE TABLE IF NOT EXISTS chat_messages (id SERIAL PRIMARY KEY, session_id INTEGER REFERENCES chat_sessions(id), sender_id INTEGER REFERENCES users(id), content TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, is_read INTEGER DEFAULT 0)",
            "CREATE TABLE IF NOT EXISTS chat_messages (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER REFERENCES chat_sessions(id), sender_id INTEGER REFERENCES users(id), content VARCHAR NOT NULL, created_at DATETIME, is_read INTEGER DEFAULT 0)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS group_chats (id SERIAL PRIMARY KEY, name VARCHAR NOT NULL, photo_url VARCHAR, admin_id INTEGER REFERENCES users(id), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS group_chats (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR NOT NULL, photo_url VARCHAR, admin_id INTEGER REFERENCES users(id), created_at DATETIME)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS group_members (id SERIAL PRIMARY KEY, group_id INTEGER REFERENCES group_chats(id), user_id INTEGER REFERENCES users(id), joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS group_members (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER REFERENCES group_chats(id), user_id INTEGER REFERENCES users(id), joined_at DATETIME)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS group_messages (id SERIAL PRIMARY KEY, group_id INTEGER REFERENCES group_chats(id), sender_id INTEGER REFERENCES users(id), content TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS group_messages (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER REFERENCES group_chats(id), sender_id INTEGER REFERENCES users(id), content VARCHAR NOT NULL, created_at DATETIME)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS fee_installments (id SERIAL PRIMARY KEY, student_id INTEGER REFERENCES users(id), title VARCHAR NOT NULL, amount VARCHAR NOT NULL, status VARCHAR DEFAULT 'due', due_date VARCHAR, paid_at TIMESTAMP, proof_url TEXT)",
            "CREATE TABLE IF NOT EXISTS fee_installments (id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INTEGER REFERENCES users(id), title VARCHAR NOT NULL, amount VARCHAR NOT NULL, status VARCHAR DEFAULT 'due', due_date VARCHAR, paid_at DATETIME, proof_url VARCHAR)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS weekly_challenges (id SERIAL PRIMARY KEY, title VARCHAR NOT NULL, description TEXT, points INTEGER DEFAULT 10, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS weekly_challenges (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR NOT NULL, description VARCHAR, points INTEGER DEFAULT 10, created_at DATETIME)"
        )

        run_sql(
            "CREATE TABLE IF NOT EXISTS challenge_completions (id SERIAL PRIMARY KEY, challenge_id INTEGER REFERENCES weekly_challenges(id), student_id INTEGER REFERENCES users(id), completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
            "CREATE TABLE IF NOT EXISTS challenge_completions (id INTEGER PRIMARY KEY AUTOINCREMENT, challenge_id INTEGER REFERENCES weekly_challenges(id), student_id INTEGER REFERENCES users(id), completed_at DATETIME)"
        )

        # Create default user if none exists
        if db.query(models.User).count() == 0:
            default_user = models.User(
                email="lecturer@edunova.com",
                password="password123",
                full_name="Dr. Smith",
                gender="Male",
                role="lecturer"
            )
            db.add(default_user)
            
            student_user = models.User(
                email="student@edunova.com",
                password="password123",
                full_name="Yasmin Ahmed",
                gender="Female",
                role="student"
            )
            db.add(student_user)
            db.commit()
            print("DEBUG: Default users created")
        
        # Add seed courses if none exist
        if db.query(models.Course).count() == 0:
            lecturer = db.query(models.User).first()
            seed_courses = [
                models.Course(name="Advanced Mathematics", code="MATH401", lecturer_id=lecturer.id),
                models.Course(name="Quantum Physics", code="PHYS302", lecturer_id=lecturer.id),
                models.Course(name="Software Engineering", code="SE201", lecturer_id=lecturer.id),
            ]
            db.add_all(seed_courses)
            db.commit()
            print("DEBUG: Seed courses added")
            
            # Add seed resources for the first course
            first_course = db.query(models.Course).first()
            if first_course and db.query(models.CourseResource).count() == 0:
                seed_resources = [
                    models.CourseResource(
                        course_id=first_course.id,
                        category="pdfs",
                        title="Introduction to Calculus",
                        file_url="/uploads/sample.pdf"
                    ),
                    models.CourseResource(
                        course_id=first_course.id,
                        category="assignments",
                        title="Homework 1: Derivatives",
                        file_url="/uploads/hw1.pdf"
                    ),
                ]
                db.add_all(seed_resources)
                db.commit()
                print("DEBUG: Seed resources added")

            # Seed initial fee installments for student@edunova.com if they don't have any
            target_student = db.query(models.User).filter(models.User.email == "student@edunova.com").first()
            if target_student and db.query(models.FeeInstallment).filter(models.FeeInstallment.student_id == target_student.id).count() == 0:
                installments = [
                    models.FeeInstallment(student_id=target_student.id, title="1st Installment", amount="750,000", status="due", due_date="Sep 15, 2025"),
                    models.FeeInstallment(student_id=target_student.id, title="2nd Installment", amount="750,000", status="due", due_date="Nov 01, 2025"),
                    models.FeeInstallment(student_id=target_student.id, title="3rd Installment", amount="750,000", status="due", due_date="Jan 15, 2026"),
                    models.FeeInstallment(student_id=target_student.id, title="4th Installment", amount="750,000", status="due", due_date="Mar 15, 2026"),
                ]
                db.add_all(installments)
                db.commit()
                print("DEBUG: Seed fee installments added for student@edunova.com")
            
        print(f"DEBUG: Startup complete. Courses count: {db.query(models.Course).count()}")
    except Exception as e:
        print(f"DEBUG: Startup error: {e}")
    finally:
        db.close()

@app.get("/")
async def root():
    return {
        "message": "Welcome to EduNova API",
        "database": "Online" if os.getenv("DATABASE_URL") else "Offline (SQLite Fallback)"
    }

@app.post("/auth/signup")
async def signup(user: UserAuth, db: Session = Depends(get_db)):
    print(f"DEBUG: Signup request for email: {user.email}")
    # Check if user already exists
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        print(f"DEBUG: Signup failed - email {user.email} already exists")
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create new user
    print(f"DEBUG: Saving user with dept={user.department}, stage={user.stage}")
    new_user = models.User(
        email=user.email,
        password=user.password, # In production, hash this!
        full_name=user.fullName,
        gender=user.gender,
        role=user.role,
        department=user.department,
        stage=user.stage,
        years_of_experience=user.years_of_experience or 0,
        image_url=user.image_url
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"message": "User created successfully", "email": new_user.email}

@app.post("/auth/login")
async def login(user: UserAuth, db: Session = Depends(get_db)):
    print(f"DEBUG: Login request for email: {user.email}")
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    
    if not db_user:
        print(f"DEBUG: Login failed - email {user.email} not found in database")
        raise HTTPException(status_code=404, detail="Email not registered")
    
    if db_user.password != user.password:
        raise HTTPException(status_code=401, detail="Incorrect password")
    
    # Check if role matches
    if db_user.role != user.role:
        print(f"DEBUG: Login failed - role mismatch for {user.email}: expected {db_user.role}, got {user.role}")
        raise HTTPException(status_code=403, detail=f"Access denied - you are registered as a {db_user.role}")
        
    print(f"DEBUG: Login successful for {db_user.email}. Dept: {db_user.department}, Stage: {db_user.stage}")
    return {
        "message": "Login successful",
        "email": db_user.email,
        "fullName": db_user.full_name,
        "role": db_user.role,
        "department": db_user.department,
        "stage": db_user.stage,
        "years_of_experience": db_user.years_of_experience,
        "image_url": db_user.image_url
    }

class ProfileUpdate(BaseModel):
    fullName: Optional[str] = None
    email: EmailStr
    role: str
    department: Optional[str] = None
    stage: Optional[str] = None

@app.put("/auth/update-profile")
async def update_profile(profile: ProfileUpdate, db: Session = Depends(get_db)):
    print(f"DEBUG: Update profile request for {profile.email}")
    db_user = db.query(models.User).filter(models.User.email == profile.email).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if profile.fullName:
        db_user.full_name = profile.fullName
    if profile.department:
        db_user.department = profile.department
    if profile.stage:
        db_user.stage = profile.stage
    
    db.commit()
    db.refresh(db_user)
    
    return {
        "message": "Profile updated successfully",
        "fullName": db_user.full_name,
        "department": db_user.department,
        "stage": db_user.stage
    }

@app.get("/admin/clear-all")
@app.post("/admin/clear-all")
async def clear_all_data(db: Session = Depends(get_db)):
    # Order matters due to foreign keys
    try:
        # Clear database records
        db.query(models.Attendance).delete()
        db.query(models.CourseResource).delete()
        db.query(models.ExamMark).delete()
        db.query(models.AssignmentSubmission).delete()
        db.query(models.Assignment).delete()
        db.query(models.QuizSubmission).delete()
        db.query(models.Quiz).delete()
        db.query(models.Course).delete()
        
        # Note: We keep Users and Posts (News) unless specifically asked to clear them.
        
        # Clear uploads folder contents
        if os.path.exists(UPLOAD_DIR):
            for filename in os.listdir(UPLOAD_DIR):
                file_path = os.path.join(UPLOAD_DIR, filename)
                try:
                    if os.path.isfile(file_path) or os.path.islink(file_path):
                        os.unlink(file_path)
                    elif os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                except Exception as e:
                    print(f'Failed to delete {file_path}. Reason: {e}')
                    
        db.commit()
        return {"message": "All lecture data and uploads cleared"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Clear failed: {str(e)}")

@app.get("/admin/status")
async def get_status(db: Session = Depends(get_db)):
    try:
        users_count = db.query(models.User).count()
        courses_count = db.query(models.Course).count()
        # Check columns using inspector
        from sqlalchemy import inspect
        inspector = inspect(engine)
        user_cols = [c["name"] for c in inspector.get_columns("users")]
        return {
            "status": "online",
            "users": users_count,
            "courses": courses_count,
            "user_columns": user_cols,
            "has_department": "department" in user_cols,
            "has_stage": "stage" in user_cols,
            "auto_fix_version": "v2"
        }
    except Exception as e:
        return {"error": str(e)}

@app.post("/auth/send-otp")
async def send_otp(request: OTPRequest):
    otp = "".join([str(secrets.randbelow(10)) for _ in range(6)])
    # TODO: Implement email sending logic
    return {"message": f"OTP sent to {request.email} (mock)", "otp": otp}

@app.post("/auth/verify-otp")
async def verify_otp(request: VerifyOTPRequest):
    # TODO: Implement real verification logic
    if request.otp == "1234": # Mock code for testing
        return {"message": "OTP verified successfully"}
    raise HTTPException(status_code=400, detail="Invalid OTP code")

# --- Posts Endpoints ---

@app.post("/posts")
async def create_post(
    title: str = Form(...),
    description: str = Form(...),
    image: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    # For now, let's assume a default user_id since we don't have full auth context here
    user_id = 1 
    
    image_url = None

    if image:
        image_path = os.path.join(UPLOAD_DIR, f"{secrets.token_hex(8)}_{image.filename}")
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
        image_url = f"/uploads/{os.path.basename(image_path)}"

    new_post = models.Post(
        user_id=user_id,
        title=title,
        description=description,
        image_url=image_url
    )
    db.add(new_post)
    db.commit()
    db.refresh(new_post)

    return {"message": "Post created successfully", "post_id": new_post.id}

@app.delete("/posts/{post_id}")
async def delete_post(post_id: int, db: Session = Depends(get_db)):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    
    # Optional: Delete the image file from disk if it exists
    if post.image_url:
        file_path = os.path.join(UPLOAD_DIR, os.path.basename(post.image_url))
        if os.path.exists(file_path):
            os.remove(file_path)

    db.delete(post)
    db.commit()
    return {"message": "Post deleted successfully"}

@app.get("/posts")
async def get_posts(db: Session = Depends(get_db)):
    posts = db.query(models.Post).order_by(models.Post.created_at.desc()).all()
    result = []
    for post in posts:
        post_data = {
            "id": post.id,
            "title": post.title,
            "description": post.description,
            "image_url": post.image_url,
            "created_at": post.created_at.isoformat() if post.created_at else None,
            "author_name": post.author.full_name if post.author else "Lecturer"
        }
        result.append(post_data)
    return result

# --- Course Endpoints ---

@app.get("/courses")
async def get_courses(email: Optional[str] = None, role: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(models.Course)
    
    role_lower = role.lower() if role else None
    
    if role_lower == "student" and email:
        student = db.query(models.User).filter(models.User.email == email).first()
        if student and student.department and student.stage:
            # Simple filtering for student
            # We split student's dept/stage (CSV) and check if course matches ANY
            student_depts = [d.strip() for d in student.department.split(',')]
            student_stages = [s.strip() for s in student.stage.split(',')]
            
            query = query.filter(
                models.Course.department.in_(student_depts),
                models.Course.stage.in_(student_stages)
            )
    elif role_lower == "lecturer" and email:
        lecturer = db.query(models.User).filter(models.User.email == email).first()
        if lecturer:
            query = query.filter(models.Course.lecturer_id == lecturer.id)
        else:
            # If email provided but lecturer not found, return empty
            return []
    elif email or role:
        # If any other combo provided but not matched, return empty for safety
        return []
            
    courses = query.order_by(models.Course.id.desc()).all()
    result = []
    for c in courses:
        result.append({
            "id": c.id,
            "name": c.name,
            "code": c.code,
            "description": getattr(c, 'description', "No description available."), # Handled if missing
            "image_url": c.image_url,
            "lecturer_id": c.lecturer_id,
            "lecturer_name": c.lecturer.full_name if c.lecturer else "Lecturer",
            "department": c.department,
            "stage": c.stage
        })
    return result

@app.get("/users/lecturers")
async def get_lecturers(department: Optional[str] = None, stage: Optional[str] = None, db: Session = Depends(get_db)):
    print(f"DEBUG: get_lecturers called with dept='{department}', stage='{stage}'")
    query = db.query(models.User).filter(models.User.role == "lecturer")
    
    lecturers = query.all()
    result = []
    
    search_dept = department.lower().strip() if department else None
    search_stage = stage.lower().strip() if stage else None
    
    # Map synonyms/variations
    stage_map = {
        "1": "first", "1st": "first",
        "2": "second", "2nd": "second",
        "3": "third", "3rd": "third",
        "4": "fourth", "4th": "fourth",
        "5": "fifth", "5th": "fifth"
    }
    
    # If search_stage contains a digit, try mapping it
    if search_stage:
        for k, v in stage_map.items():
            if k in search_stage:
                search_stage = search_stage.replace(k, v)
                break

    for l in lecturers:
        l_dept = (l.department or "").lower()
        l_stage = (l.stage or "").lower()
        
        match_dept = True
        if search_dept:
            s_dept_parts = [p for p in search_dept.replace(",", " ").split() if p not in ["department", "dept", "of", "and"]]
            l_dept_parts = [p for p in l_dept.replace(",", " ").split() if p not in ["department", "dept", "of", "and"]]
            # Match if any significant word matches
            match_dept = any(sp in l_dept for sp in s_dept_parts) or any(lp in search_dept for lp in l_dept_parts)
            # Special check for "it" to avoid matching "it" inside "architectural"
            if "it" in s_dept_parts or "it" in l_dept_parts:
                if "it" in s_dept_parts and "it" not in l_dept.split():
                     # if search is 'it', but it's not a standalone word in lecturer dept
                     if "information technology" not in l_dept:
                         match_dept = False
                if "it" in l_dept_parts and "it" not in search_dept.split():
                     if "information technology" not in search_dept:
                         match_dept = False

        match_stage = True
        if search_stage:
            s_stage_parts = [p for p in search_stage.split() if p not in ["stage", "st", "nd", "rd", "th"]]
            # Match if any key word like 'fourth' is in lecturer stage
            match_stage = any(sp in l_stage for sp in s_stage_parts)
            
        if match_dept and match_stage:
            result.append({
                "id": l.id,
                "email": l.email,
                "fullName": l.full_name,
                "department": l.department,
                "stage": l.stage,
                "years_of_experience": l.years_of_experience,
                "image_url": l.image_url
            })
    return result

@app.post("/courses")
async def create_course(
    name: str = Form(...),
    code: str = Form(...),
    department: str = Form("Software Engineering"),
    stage: str = Form("First Stage"),
    image: UploadFile = File(None),
    lecturer_email: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    # Check if code already exists
    existing = db.query(models.Course).filter(models.Course.code == code).first()
    if existing:
        raise HTTPException(status_code=400, detail="Course code already exists")
    
    image_url = None
    if image:
        # Generate random filename
        file_ext = image.filename.split(".")[-1]
        file_name = f"{secrets.token_hex(8)}.{file_ext}"
        file_path = os.path.join(UPLOAD_DIR, file_name)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
        
        image_url = f"/uploads/{file_name}"
    
    # Identify lecturer
    lecturer_id = 1
    if lecturer_email:
        lecturer = db.query(models.User).filter(models.User.email == lecturer_email).first()
        if lecturer:
            lecturer_id = lecturer.id
    else:
        # Fallback to first lecturer
        lect_user = db.query(models.User).filter(models.User.role == "lecturer").first()
        if lect_user:
            lecturer_id = lect_user.id

    new_course = models.Course(
        name=name, 
        code=code, 
        image_url=image_url,
        lecturer_id=lecturer_id,
        department=department,
        stage=stage
    )
    db.add(new_course)
    db.commit()
    db.refresh(new_course)
    return new_course

@app.delete("/courses/{course_id}")
async def delete_course(course_id: int, db: Session = Depends(get_db)):
    course = db.query(models.Course).filter(models.Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    db.delete(course)
    db.commit()
    return {"message": "Course deleted"}

@app.get("/courses/{course_id}/resources")
async def get_resources(course_id: int, category: str = "", db: Session = Depends(get_db)):
    query = db.query(models.CourseResource).filter(models.CourseResource.course_id == course_id)
    if category:
        query = query.filter(models.CourseResource.category == category.lower())
    return query.all()

@app.post("/courses/{course_id}/resources")
async def upload_resource(
    course_id: int,
    category: str = Form(...),
    title: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    file_path = os.path.join(UPLOAD_DIR, f"{secrets.token_hex(8)}_{file.filename}")
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    new_resource = models.CourseResource(
        course_id=course_id,
        category=category.lower(),
        title=title,
        file_url=f"/uploads/{os.path.basename(file_path)}"
    )
    db.add(new_resource)
    db.commit()
    db.refresh(new_resource)
    return new_resource

@app.get("/courses/{course_id}/attendance")
async def get_attendance(course_id: int, db: Session = Depends(get_db)):
    return db.query(models.Attendance).filter(models.Attendance.course_id == course_id).all()

@app.post("/courses/{course_id}/attendance")
async def submit_attendance(
    course_id: int,
    records: list = Body(...),
    db: Session = Depends(get_db)
):
    # records should be a list of {"student_name": "...", "status": "..."}
    for record in records:
        att = models.Attendance(
            course_id=course_id,
            student_name=record["student_name"],
            status=record["status"]
        )
        db.add(att)
    db.commit()
    return {"message": "Attendance recorded"}

# --- Assignment Endpoints ---

@app.post("/courses/{course_id}/assignments")
async def create_assignment(
    course_id: int,
    title: str = Form(...),
    content: str = Form(...),
    category: str = Form("assignment"),
    file: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    file_url = None
    if file:
        file_path = os.path.join(UPLOAD_DIR, f"ref_{secrets.token_hex(8)}_{file.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        file_url = f"/uploads/{os.path.basename(file_path)}"
    
    new_assignment = models.Assignment(
        course_id=course_id,
        category=category,
        title=title,
        content=content,
        file_url=file_url
    )
    db.add(new_assignment)
    db.commit()
    db.refresh(new_assignment)
    return new_assignment

@app.get("/courses/{course_id}/assignments")
async def get_assignments(course_id: int, category: str = "assignment", db: Session = Depends(get_db)):
    return db.query(models.Assignment).filter(
        models.Assignment.course_id == course_id,
        models.Assignment.category == category
    ).all()

@app.post("/assignments/{assignment_id}/submissions")
async def submit_assignment(
    assignment_id: int,
    student_email: str = Form(...),
    solution_text: str = Form(None),
    file: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    # Check if existing submission
    submission = db.query(models.AssignmentSubmission).filter(
        models.AssignmentSubmission.assignment_id == assignment_id,
        models.AssignmentSubmission.student_id == student.id
    ).first()
    
    file_url = submission.file_url if submission else None
    if file:
        file_path = os.path.join(UPLOAD_DIR, f"sub_{secrets.token_hex(8)}_{file.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        file_url = f"/uploads/{os.path.basename(file_path)}"
        
    if submission:
        submission.solution_text = solution_text or submission.solution_text
        submission.file_url = file_url
        submission.submitted_at = datetime.datetime.utcnow()
    else:
        submission = models.AssignmentSubmission(
            assignment_id=assignment_id,
            student_id=student.id,
            solution_text=solution_text,
            file_url=file_url
        )
        db.add(submission)
    
    db.commit()
    db.refresh(submission)
    return submission

@app.get("/assignments/{assignment_id}/submissions")
async def get_all_submissions(assignment_id: int, db: Session = Depends(get_db)):
    submissions = db.query(models.AssignmentSubmission).filter(
        models.AssignmentSubmission.assignment_id == assignment_id
    ).all()
    
    result = []
    for sub in submissions:
        result.append({
            "id": sub.id,
            "student_name": sub.student.full_name if sub.student else "Unknown",
            "solution_text": sub.solution_text,
            "file_url": sub.file_url,
            "grade": sub.grade,
            "lecturer_note": sub.lecturer_note,
            "submitted_at": sub.submitted_at.isoformat(),
            "is_graded": sub.is_graded == 1
        })
    return result

@app.get("/assignments/{assignment_id}/my-submission")
async def get_my_submission(assignment_id: int, student_email: str, db: Session = Depends(get_db)):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        return None
    
    sub = db.query(models.AssignmentSubmission).filter(
        models.AssignmentSubmission.assignment_id == assignment_id,
        models.AssignmentSubmission.student_id == student.id
    ).first()
    
    if not sub:
        return None
        
    return {
        "id": sub.id,
        "solution_text": sub.solution_text,
        "file_url": sub.file_url,
        "grade": sub.grade,
        "lecturer_note": sub.lecturer_note,
        "is_graded": sub.is_graded == 1
    }

@app.post("/submissions/{submission_id}/grade")
async def grade_submission(
    submission_id: int,
    grade: str = Body(...),
    note: str = Body(None),
    db: Session = Depends(get_db)
):
    submission = db.query(models.AssignmentSubmission).filter(
        models.AssignmentSubmission.id == submission_id
    ).first()
    
    if not submission:
        raise HTTPException(status_code=404, detail="Submission not found")
        
    submission.grade = grade
    submission.lecturer_note = note
    submission.is_graded = 1
    
    db.commit()
    return {"message": "Graded successfully"}


# --- Quiz Endpoints ---

@app.post("/courses/{course_id}/quizzes")
async def create_quiz(
    course_id: int,
    title: str = Form(...),
    content: str = Form(...),
    file: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    file_url = None
    if file:
        file_path = os.path.join(UPLOAD_DIR, f"ref_{secrets.token_hex(8)}_{file.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        file_url = f"/uploads/{os.path.basename(file_path)}"
    
    new_quiz = models.Quiz(
        course_id=course_id,
        title=title,
        content=content,
        file_url=file_url
    )
    db.add(new_quiz)
    db.commit()
    db.refresh(new_quiz)
    return new_quiz

@app.get("/courses/{course_id}/quizzes")
async def get_quizzes(course_id: int, db: Session = Depends(get_db)):
    return db.query(models.Quiz).filter(models.Quiz.course_id == course_id).all()

@app.post("/quizzes/{quiz_id}/submissions")
async def submit_quiz(
    quiz_id: int,
    student_email: str = Form(...),
    solution_text: str = Form(None),
    file: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    submission = db.query(models.QuizSubmission).filter(
        models.QuizSubmission.quiz_id == quiz_id,
        models.QuizSubmission.student_id == student.id
    ).first()
    
    file_url = submission.file_url if submission else None
    if file:
        file_path = os.path.join(UPLOAD_DIR, f"sub_{secrets.token_hex(8)}_{file.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        file_url = f"/uploads/{os.path.basename(file_path)}"
        
    if submission:
        submission.solution_text = solution_text or submission.solution_text
        submission.file_url = file_url
        submission.submitted_at = datetime.datetime.utcnow()
    else:
        submission = models.QuizSubmission(
            quiz_id=quiz_id,
            student_id=student.id,
            solution_text=solution_text,
            file_url=file_url
        )
        db.add(submission)
    
    db.commit()
    db.refresh(submission)
    return submission

@app.get("/quizzes/{quiz_id}/submissions")
async def get_all_quiz_submissions(quiz_id: int, db: Session = Depends(get_db)):
    submissions = db.query(models.QuizSubmission).filter(
        models.QuizSubmission.quiz_id == quiz_id
    ).all()
    
    result = []
    for sub in submissions:
        result.append({
            "id": sub.id,
            "student_name": sub.student.full_name if sub.student else "Unknown",
            "solution_text": sub.solution_text,
            "file_url": sub.file_url,
            "grade": sub.grade,
            "lecturer_note": sub.lecturer_note,
            "submitted_at": sub.submitted_at.isoformat(),
            "is_graded": sub.is_graded == 1
        })
    return result

@app.get("/quizzes/{quiz_id}/my-submission")
async def get_my_quiz_submission(quiz_id: int, student_email: str, db: Session = Depends(get_db)):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        return None
    
    sub = db.query(models.QuizSubmission).filter(
        models.QuizSubmission.quiz_id == quiz_id,
        models.QuizSubmission.student_id == student.id
    ).first()
    
    if not sub:
        return None
        
    return {
        "id": sub.id,
        "solution_text": sub.solution_text,
        "file_url": sub.file_url,
        "grade": sub.grade,
        "lecturer_note": sub.lecturer_note,
        "is_graded": sub.is_graded == 1
    }

@app.post("/quiz-submissions/{submission_id}/grade")
async def grade_quiz_submission(
    submission_id: int,
    grade: str = Body(...),
    note: str = Body(None),
    db: Session = Depends(get_db)
):
    submission = db.query(models.QuizSubmission).filter(
        models.QuizSubmission.id == submission_id
    ).first()
    
    if not submission:
        raise HTTPException(status_code=404, detail="Submission not found")
        
    submission.grade = grade
    submission.lecturer_note = note
    submission.is_graded = 1
    
    db.commit()
    return {"message": "Graded successfully"}

# --- Student & Exam Endpoints ---


@app.get("/users/students")
async def get_all_students(department: Optional[str] = None, stage: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(models.User).filter(models.User.role == "student")
    if department:
        query = query.filter(models.User.department == department)
    if stage:
        query = query.filter(models.User.stage == stage)
    students = query.all()
    return [{"id": s.id, "email": s.email, "full_name": s.full_name, "department": s.department, "stage": s.stage} for s in students]

@app.get("/courses/{course_id}/exam_marks")
async def get_exam_marks(course_id: int, exam_type: str = "midterm", db: Session = Depends(get_db)):
    marks = db.query(models.ExamMark).filter(
        models.ExamMark.course_id == course_id,
        models.ExamMark.exam_type == exam_type
    ).all()
    return [{"student_id": m.student_id, "mark": m.mark} for m in marks]

@app.get("/courses/{course_id}/exam_marks_full")
async def get_exam_marks_full(course_id: int, db: Session = Depends(get_db)):
    marks = db.query(models.ExamMark).filter(models.ExamMark.course_id == course_id).all()
    result = []
    for m in marks:
        student_name = m.student.full_name if m.student else "Unknown"
        result.append({
            "id": m.id,
            "student_name": student_name,
            "exam_type": m.exam_type,
            "mark": m.mark
        })
    return result

@app.post("/courses/{course_id}/exam_marks")
async def save_exam_mark(
    course_id: int,
    student_id: int = Body(...),
    exam_type: str = Body(...),
    mark: str = Body(...),
    db: Session = Depends(get_db)
):
    existing_mark = db.query(models.ExamMark).filter(
        models.ExamMark.course_id == course_id,
        models.ExamMark.student_id == student_id,
        models.ExamMark.exam_type == exam_type
    ).first()
    
    if existing_mark:
        existing_mark.mark = str(mark)
        db.commit()
        return {"message": "Exam mark updated successfully"}
    else:
        new_mark = models.ExamMark(
            course_id=course_id,
            student_id=student_id,
            exam_type=exam_type,
            mark=str(mark)
        )
        db.add(new_mark)
        db.commit()
        return {"message": "Exam mark created successfully"}

@app.put("/exam_marks/{mark_id}")
async def update_exam_mark(
    mark_id: int,
    mark: str = Body(None),
    db: Session = Depends(get_db)
):
    existing_mark = db.query(models.ExamMark).filter(models.ExamMark.id == mark_id).first()
    if not existing_mark:
        raise HTTPException(status_code=404, detail="Exam mark not found")
        
    if mark is not None:
        existing_mark.mark = str(mark)
    db.commit()
    return {"message": "Exam mark updated successfully"}

@app.get("/courses/{course_id}/my_exam_marks")
async def get_my_exam_marks(course_id: int, student_email: str, db: Session = Depends(get_db)):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
        
    marks = db.query(models.ExamMark).filter(
        models.ExamMark.course_id == course_id,
        models.ExamMark.student_id == student.id
    ).all()
    
    return [{"exam_type": m.exam_type, "mark": m.mark} for m in marks]

# --- Fee Endpoints ---

@app.get("/fees/{student_email}")
async def get_student_fees(student_email: str, db: Session = Depends(get_db)):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    installments = db.query(models.FeeInstallment).filter(models.FeeInstallment.student_id == student.id).all()
    
    # Generate installments if none exist
    if not installments:
        dept = student.department or "IT"
        dept_norm = dept.strip().lower()
        # Determine total fee depending on department
        if dept_norm in ["software engineering", "civil engineering", "architectural engineering"]:
            total = 3000000
        elif dept_norm in ["dentist", "pharmacy"]:
            total = 4000000
        else:
            total = 2000000
            
        part = total // 4
        part_str = f"{part:,}"
        
        # Generic dates for installments
        dates = ["Oct 1, 2026", "Dec 1, 2026", "Feb 1, 2027", "Apr 1, 2027"]
        titles = ["1st Installment", "2nd Installment", "3rd Installment", "4th Installment"]
        
        for i in range(4):
            inst = models.FeeInstallment(
                student_id=student.id,
                title=titles[i],
                amount=part_str,
                status="due",
                due_date=dates[i]
            )
            db.add(inst)
            installments.append(inst)
        db.commit()
        
        # We don't necessarily need to refresh them as they're now objects ready to serialize 
        # But we do need to return the newly generated installments
    return installments

@app.post("/fees/pay")
async def pay_installment(
    student_email: str = Form(...),
    installment_id: int = Form(...),
    proof: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
        
    installment = db.query(models.FeeInstallment).filter(
        models.FeeInstallment.id == installment_id,
        models.FeeInstallment.student_id == student.id
    ).first()
    
    if not installment:
        raise HTTPException(status_code=404, detail="Installment not found")
        
    proof_url = None
    if proof:
        file_path = os.path.join(UPLOAD_DIR, f"fee_{secrets.token_hex(8)}_{proof.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(proof.file, buffer)
        proof_url = f"/uploads/{os.path.basename(file_path)}"
        
    installment.status = "paid"
    installment.paid_at = datetime.datetime.utcnow()
    installment.proof_url = proof_url
    
    db.commit()
    db.refresh(installment)
    return installment

# --- Helper for Student Stats ---

def get_all_student_averages_and_data(db: Session, department: Optional[str] = None, stage: Optional[str] = None):
    """
    Calculates overall averages and subject-specific data for students in a specific department/stage.
    Returns: {student_id: {"name": str, "email": str, "total_avg": float, "subjects": list}}
    """
    query = db.query(models.User).filter(models.User.role == "student")
    if department:
        query = query.filter(models.User.department == department)
    if stage:
        query = query.filter(models.User.stage == stage)
    all_students = query.all()
    courses = db.query(models.Course).all()
    
    results = {} # student_id -> {"name": "", "email": "", "total_avg": 0.0, "subjects": []}
    
    for s in all_students:
        s_total_avg = 0.0
        s_courses_count = 0
        s_subjects_data = []
        
        for c in courses:
            # Check if student has any activity in this course
            # Activity = Attendance, Assignment, Quiz, or Exam
            has_activity = db.query(models.Attendance).filter(models.Attendance.course_id == c.id, models.Attendance.student_id == s.id).first() or \
                           db.query(models.AssignmentSubmission).join(models.Assignment).filter(models.Assignment.course_id == c.id, models.AssignmentSubmission.student_id == s.id).first() or \
                           db.query(models.QuizSubmission).join(models.Quiz).filter(models.Quiz.course_id == c.id, models.QuizSubmission.student_id == s.id).first() or \
                           db.query(models.ExamMark).filter(models.ExamMark.course_id == c.id, models.ExamMark.student_id == s.id).first()
            
            if not has_activity:
                continue
                
            # 1. Quiz Average
            quizzes = db.query(models.QuizSubmission).join(models.Quiz).filter(
                models.Quiz.course_id == c.id,
                models.QuizSubmission.student_id == s.id,
                models.QuizSubmission.is_graded == 1
            ).all()
            q_avg = sum([to_float(q.grade) for q in quizzes]) / len(quizzes) if quizzes else None
            
            # 2. Assignment Average
            assigns = db.query(models.AssignmentSubmission).join(models.Assignment).filter(
                models.Assignment.course_id == c.id,
                models.AssignmentSubmission.student_id == s.id,
                models.AssignmentSubmission.is_graded == 1
            ).all()
            a_avg = sum([to_float(a.grade) for a in assigns]) / len(assigns) if assigns else None
            
            # 3. Exams
            m_mark_obj = db.query(models.ExamMark).filter(models.ExamMark.course_id == c.id, models.ExamMark.student_id == s.id, models.ExamMark.exam_type == "midterm").first()
            f_mark_obj = db.query(models.ExamMark).filter(models.ExamMark.course_id == c.id, models.ExamMark.student_id == s.id, models.ExamMark.exam_type == "final").first()
            
            m_mark = to_float(m_mark_obj.mark) if m_mark_obj else None
            f_mark = to_float(f_mark_obj.mark) if f_mark_obj else None
            
            # Base Average Calculation (average of available components)
            components = [v for v in [q_avg, a_avg, m_mark, f_mark] if v is not None]
            base_avg = sum(components) / len(components) if components else 0.0
            
            # 4. Attendance Bonus
            att_total = db.query(models.Attendance).filter(models.Attendance.course_id == c.id, models.Attendance.student_id == s.id).count()
            att_present = db.query(models.Attendance).filter(models.Attendance.course_id == c.id, models.Attendance.student_id == s.id, models.Attendance.status == "attended").count()
            
            att_perc = (att_present / att_total * 100) if att_total > 0 else 0.0
            bonus = 0.0
            if att_perc > 80: bonus = 5.0
            elif att_perc >= 70: bonus = 4.0
            elif att_perc >= 60: bonus = 3.0
            elif att_perc >= 50: bonus = 2.0
            
            final_subject_mark = min(100.0, base_avg + bonus)
            
            s_total_avg += final_subject_mark
            s_courses_count += 1

            s_subjects_data.append({
                "id": c.id,
                "name": c.name,
                "code": c.code,
                "mark": round(final_subject_mark, 1),
                "grade": get_grade_letter(final_subject_mark),
                "icon_type": "math" if "math" in c.name.lower() else "science" if "science" in c.name.lower() or "physic" in c.name.lower() or "chemis" in c.name.lower() else "other"
            })

        results[s.id] = {
            "name": s.full_name,
            "email": s.email,
            "total_avg": round(s_total_avg / s_courses_count, 1) if s_courses_count > 0 else 0.0,
            "subjects": s_subjects_data
        }
        
    return results

@app.get("/student/leaderboard")
async def get_leaderboard(department: Optional[str] = None, stage: Optional[str] = None, db: Session = Depends(get_db)):
    print(f"[DEBUG] Fetching leaderboard data for dept={department}, stage={stage}")
    all_stats = get_all_student_averages_and_data(db, department=department, stage=stage)
    
    # Convert to list and sort by total_avg
    leaderboard = []
    for s_id, data in all_stats.items():
        leaderboard.append({
            "name": data["name"],
            "score": data["total_avg"],
            "rank": 0 # Placeholder
        })
    
    leaderboard.sort(key=lambda x: x["score"], reverse=True)
    
    # Assign ranks
    for i, entry in enumerate(leaderboard):
        entry["rank"] = i + 1
        
    print(f"[DEBUG] Leaderboard prepared with {len(leaderboard)} students")
    return leaderboard

@app.get("/student/academic-marks")
async def get_student_academic_marks(student_email: str, db: Session = Depends(get_db)):
    print(f"[DEBUG] Fetching marks for: {student_email}")
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        print(f"[DEBUG] Student {student_email} not found")
        raise HTTPException(status_code=404, detail="Student not found")

    print(f"[DEBUG] Student {student_email} - Dept: {student.department}, Stage: {student.stage}")
    all_stats = get_all_student_averages_and_data(db, department=student.department, stage=student.stage)
    student_data = all_stats.get(student.id)
    
    if not student_data:
        # Student exists but no marks/active courses
        return {
            "final_mark": 0.0,
            "feedback": "Ready to learn something new today?",
            "rank": len(all_stats) if all_stats else 1,
            "total_students": len(all_stats),
            "subjects": []
        }
    
    # Calculate rank among filtered students
    all_avgs = sorted([s["total_avg"] for s in all_stats.values()], reverse=True)
    rank = all_avgs.index(student_data["total_avg"]) + 1 if student_data["total_avg"] in all_avgs else len(all_avgs)

    # Feedback sentence
    my_avg = student_data["total_avg"]
    if my_avg >= 90: 
        feedback = "Perfect! Outstanding performance!"
    elif my_avg >= 80: 
        feedback = "Great job! Excellent performance!"
    elif my_avg >= 70: 
        feedback = "Good effort! You can improve even more."
    else:
        feedback = "Keep pushing forward!"

    response_data = {
        "final_mark": round(my_avg, 1),
        "feedback": feedback,
        "rank": rank,
        "total_students": len(all_stats),
        "subjects": student_data["subjects"]
    }
    print(f"[DEBUG] Response data prepared for {student_email}: {my_avg}% (Rank {rank})")
    return response_data

# --- Lecturer Student Analysis Endpoint ---

@app.get("/lecturer/student-analysis")
async def get_lecturer_student_analysis(lecturer_email: str, db: Session = Depends(get_db)):
    lecturer = db.query(models.User).filter(models.User.email == lecturer_email).first()
    if not lecturer:
        raise HTTPException(status_code=404, detail="Lecturer not found")
    
    # Get depts and stages lecturer is responsible for
    dept_list = [d.strip() for d in (lecturer.department or "").split(',') if d.strip()]
    stage_list = [s.strip() for s in (lecturer.stage or "").split(',') if s.strip()]
    
    if not dept_list or not stage_list:
        return {
            "performance_trend": [0, 0, 0, 0, 0, 0, 0],
            "attendance_analytics": {"attended": 0, "late": 0, "absent": 0, "average_rate": 0},
            "detailed_stats": {"average_mark": 0, "engagement": 0, "attendance": 0, "materials_used": 0},
            "top_performers": []
        }

    # Get students belonging to these depts and stages
    students = db.query(models.User).filter(
        models.User.role == "student",
        models.User.department.in_(dept_list),
        models.User.stage.in_(stage_list)
    ).all()
    student_ids = [s.id for s in students]
    
    if not student_ids:
        return {
            "performance_trend": [0, 0, 0, 0, 0, 0, 0],
            "attendance_analytics": {"attended": 0, "late": 0, "absent": 0, "average_rate": 0},
            "detailed_stats": {"average_mark": 0, "engagement": 0, "attendance": 0, "materials_used": 0},
            "top_performers": []
        }

    # 1. Performance Trend (Last 7 days)
    trend = []
    today = datetime.datetime.utcnow().date()
    for i in range(6, -1, -1):
        day = today - datetime.timedelta(days=i)
        # Avg marks from submissions and exams for students on this day
        # In this simplified model, we'll check created_at/submitted_at
        scores = []
        
        # Submissions
        subs = db.query(models.AssignmentSubmission).filter(
            models.AssignmentSubmission.student_id.in_(student_ids),
            models.AssignmentSubmission.is_graded == 1
        ).all()
        for s in subs:
            if s.submitted_at and s.submitted_at.date() == day:
                scores.append(to_float(s.grade))
                
        # Exams
        exams = db.query(models.ExamMark).filter(
            models.ExamMark.student_id.in_(student_ids)
        ).all()
        for e in exams:
            if e.created_at and e.created_at.date() == day:
                scores.append(to_float(e.mark))
        
        if scores:
            trend.append(sum(scores) / len(scores))
        else:
            # If no data for a day, use 0 or previous day value (for visual continuity)
            trend.append(trend[-1] if trend else 0)
            
    # 2. Attendance Analytics
    att_records = db.query(models.Attendance).filter(models.Attendance.student_id.in_(student_ids)).all()
    total_att = len(att_records)
    attended = len([r for r in att_records if r.status == "attended"])
    late = len([r for r in att_records if r.status == "late"])
    absent = len([r for r in att_records if r.status == "absent"])
    
    att_analytics = {
        "attended": round(attended / total_att * 100, 1) if total_att > 0 else 0.0,
        "late": round(late / total_att * 100, 1) if total_att > 0 else 0.0,
        "absent": round(absent / total_att * 100, 1) if total_att > 0 else 0.0,
        "average_rate": round((attended + late * 0.5) / total_att * 100, 1) if total_att > 0 else 0.0
    }
    
    # 3. Detailed Statistics
    # Average Mark
    all_scores = []
    for s_id in student_ids:
        # Re-use logic or manual collect
        s_subs = db.query(models.AssignmentSubmission).filter(models.AssignmentSubmission.student_id == s_id, models.AssignmentSubmission.is_graded == 1).all()
        s_exams = db.query(models.ExamMark).filter(models.ExamMark.student_id == s_id).all()
        s_scores = [to_float(sub.grade) for sub in s_subs] + [to_float(ex.mark) for ex in s_exams]
        if s_scores:
            all_scores.append(sum(s_scores) / len(s_scores))
            
    avg_mark = sum(all_scores) / len(all_scores) if all_scores else 0.0
    
    # Engagement: submissions vs expected
    courses = db.query(models.Course).filter(models.Course.lecturer_id == lecturer.id).all()
    course_ids = [c.id for c in courses]
    assign_count = db.query(models.Assignment).filter(models.Assignment.course_id.in_(course_ids)).count()
    expected_subs = assign_count * len(student_ids)
    actual_subs = db.query(models.AssignmentSubmission).join(models.Assignment).filter(
        models.Assignment.course_id.in_(course_ids),
        models.AssignmentSubmission.student_id.in_(student_ids)
    ).count()
    
    engagement = (actual_subs / expected_subs * 100) if expected_subs > 0 else 0.0
    
    # Materials Used: count of resources by lecturer
    materials_count = db.query(models.CourseResource).join(models.Course).filter(models.Course.lecturer_id == lecturer.id).count()
    
    detailed_stats = {
        "average_mark": round(avg_mark, 1),
        "engagement": round(engagement, 1),
        "attendance": att_analytics["average_rate"],
        "materials_used": materials_count
    }
    
    # 4. Top Performers
    top_p_data = []
    # Reuse get_all_student_averages_and_data by passing depts/stages 
    # (assuming it works for CSV student dept? No, student dept is one string)
    for s in students:
        s_subs = db.query(models.AssignmentSubmission).filter(models.AssignmentSubmission.student_id == s.id, models.AssignmentSubmission.is_graded == 1).all()
        s_exams = db.query(models.ExamMark).filter(models.ExamMark.student_id == s.id).all()
        s_scores = [to_float(sub.grade) for sub in s_subs] + [to_float(ex.mark) for ex in s_exams]
        s_avg = sum(s_scores) / len(s_scores) if s_scores else 0.0
        
        top_p_data.append({
            "name": s.full_name,
            "grade": get_grade_letter(s_avg),
            "score": s_avg
        })
    
    top_performers = sorted(top_p_data, key=lambda x: x["score"], reverse=True)[:5]
    
    return {
        "performance_trend": trend,
        "attendance_analytics": att_analytics,
        "detailed_stats": detailed_stats,
        "top_performers": top_performers
    }

@app.get("/lecturer/dashboard-stats")
async def get_lecturer_dashboard_stats(email: str, db: Session = Depends(get_db)):
    lecturer = db.query(models.User).filter(models.User.role == "lecturer", models.User.email == email).first()
    if not lecturer:
        raise HTTPException(status_code=404, detail="Lecturer not found")
        
    materials_count = db.query(models.CourseResource).join(models.Course).filter(models.Course.lecturer_id == lecturer.id).count()
    return {
        "materials": materials_count,
        "years_exp": lecturer.years_of_experience
    }

@app.post("/lecturer/update-experience")
async def update_lecturer_experience(email: str, years: int, db: Session = Depends(get_db)):
    lecturer = db.query(models.User).filter(models.User.role == "lecturer", models.User.email == email).first()
    if not lecturer:
        raise HTTPException(status_code=404, detail="Lecturer not found")
    
    lecturer.years_of_experience = years
    db.commit()
    return {"message": "Experience updated successfully", "years": years}

@app.get("/lecturer/faculty-reports")
async def get_faculty_reports(email: str, db: Session = Depends(get_db)):
    lecturer = db.query(models.User).filter(models.User.email == email).first()
    if not lecturer:
        raise HTTPException(status_code=404, detail="Lecturer not found")
        
    dept_list = [d.strip() for d in (lecturer.department or "").split(',') if d.strip()]
    stage_list = [s.strip() for s in (lecturer.stage or "").split(',') if s.strip()]
    
    students = db.query(models.User).filter(
        models.User.role == "student",
        models.User.department.in_(dept_list),
        models.User.stage.in_(stage_list)
    ).all()
    
    student_ids = [s.id for s in students]
    if not student_ids:
        return {
            "success_rate": 0,
            "grades": {"A": 0, "B": 0, "C": 0},
            "insights": {
                "progress": "0% change",
                "engagement": "0% submission rate",
                "feedback": "No recent feedback"
            }
        }
    
    # Calculate Grades
    a_count = 0
    b_count = 0
    c_count = 0
    all_scores = []
    
    for s_id in student_ids:
        s_subs = db.query(models.AssignmentSubmission).filter(models.AssignmentSubmission.student_id == s_id, models.AssignmentSubmission.is_graded == 1).all()
        s_exams = db.query(models.ExamMark).filter(models.ExamMark.student_id == s_id).all()
        s_scores = [to_float(sub.grade) for sub in s_subs] + [to_float(ex.mark) for ex in s_exams]
        if s_scores:
            avg = sum(s_scores) / len(s_scores)
            all_scores.append(avg)
            grade = get_grade_letter(avg)
            if grade.startswith("A"): a_count += 1
            elif grade.startswith("B"): b_count += 1
            elif grade.startswith("C"): c_count += 1
            
    success_rate = sum(all_scores) / len(all_scores) if all_scores else 0.0
    
    # Engagement
    courses = db.query(models.Course).filter(models.Course.lecturer_id == lecturer.id).all()
    c_ids = [c.id for c in courses]
    assign_count = db.query(models.Assignment).filter(models.Assignment.course_id.in_(c_ids)).count()
    expected = assign_count * len(student_ids)
    actual = db.query(models.AssignmentSubmission).join(models.Assignment).filter(
        models.Assignment.course_id.in_(c_ids),
        models.AssignmentSubmission.student_id.in_(student_ids)
    ).count()
    eng_rate = (actual / expected * 100) if expected > 0 else 0.0
    
    return {
        "success_rate": round(success_rate, 1),
        "grades": {"A": a_count, "B": b_count, "C": c_count},
        "insights": {
            "progress": "8% increase in average marks compared to last month", # Mocked trend logic
            "engagement": f"Assignments have {round(eng_rate, 0)}% submission rate",
            "feedback": "Students requested more video content in Quizzes" # Mocked feedback
        }
    }

@app.get("/lecturer/download-report")
async def download_faculty_report(email: str, db: Session = Depends(get_db)):
    data = await get_faculty_reports(email, db)
    lecturer = db.query(models.User).filter(models.User.email == email).first()
    
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("helvetica", 'B', 16)
    pdf.cell(200, 10, txt="EduNova Faculty Report", ln=True, align='C')
    pdf.set_font("helvetica", size=12)
    pdf.cell(200, 10, txt=f"Lecturer: {lecturer.full_name}", ln=True, align='L')
    pdf.cell(200, 10, txt=f"Date: {datetime.datetime.now().strftime('%Y-%m-%d')}", ln=True, align='L')
    pdf.ln(10)
    
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(200, 10, txt="Academic Summary", ln=True)
    pdf.set_font("helvetica", size=12)
    pdf.cell(200, 10, txt=f"Overall Success Rate: {data['success_rate']}%", ln=True)
    pdf.cell(200, 10, txt=f"A Grades: {data['grades']['A']}", ln=True)
    pdf.cell(200, 10, txt=f"B Grades: {data['grades']['B']}", ln=True)
    pdf.cell(200, 10, txt=f"C Grades: {data['grades']['C']}", ln=True)
    pdf.ln(10)
    
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(200, 10, txt="Monthly Insights", ln=True)
    pdf.set_font("helvetica", size=12)
    pdf.multi_cell(0, 10, txt=f"Student Progress: {data['insights']['progress']}")
    pdf.multi_cell(0, 10, txt=f"Material Engagement: {data['insights']['engagement']}")
    pdf.multi_cell(0, 10, txt=f"Course Feedback: {data['insights']['feedback']}")
    
    # Save to temp file
    temp = tempfile.NamedTemporaryFile(delete=False, suffix=".pdf")
    pdf.output(temp.name)
    temp.close()
    
    return FileResponse(temp.name, filename=f"Faculty_Report_{lecturer.full_name}.pdf", media_type="application/pdf")

# --- Batch Attendance Endpoint ---

@app.post("/courses/{course_id}/attendance/batch")
async def save_batch_attendance(
    course_id: int,
    attendance_data: list = Body(...), # [{"student_id": 1, "student_name": "Bob", "status": "attended"}]
    db: Session = Depends(get_db)
):
    today = datetime.datetime.utcnow().date()
    
    for item in attendance_data:
        student_id = item.get("student_id")
        student_name = item.get("student_name")
        status = item.get("status")
        
        if not student_id or not status:
            continue
            
        # Check if already recorded today
        existing_att = db.query(models.Attendance).filter(
            models.Attendance.course_id == course_id,
            models.Attendance.student_id == student_id
        ).all()
        
        # Simple date filtering since sqlite datetime handling can be tricky
        recorded_today = False
        for att in existing_att:
            if att.date.date() == today:
                att.status = status
                recorded_today = True
                break
                
        if not recorded_today:
            new_att = models.Attendance(
                course_id=course_id,
                student_id=student_id,
                student_name=student_name or "Unknown",
                status=status,
                date=datetime.datetime.utcnow()
            )
            db.add(new_att)
            
    db.commit()
    return {"message": "Batch attendance saved successfully"}

# --- Chat Endpoints ---

@app.get("/users/search")
async def search_users(query: str = "", db: Session = Depends(get_db)):
    if not query:
        return []
    users = db.query(models.User).filter(
        (models.User.email == query.lower()) | 
        (models.User.full_name.ilike(f"%{query}%"))
    ).all()
    return [{"id": u.id, "email": u.email, "full_name": u.full_name, "role": u.role} for u in users]

@app.post("/chat/sessions")
async def start_chat_session(
    current_user_email: str = Form(...),
    target_user_email: str = Form(None),
    target_user_id: int = Form(None),
    db: Session = Depends(get_db)
):
    current_user = db.query(models.User).filter(models.User.email == current_user_email).first()
    if not current_user:
        raise HTTPException(status_code=404, detail="Current user not found")
    
    target_user = None
    if target_user_email:
        target_user = db.query(models.User).filter(models.User.email == target_user_email).first()
    elif target_user_id:
        target_user = db.query(models.User).filter(models.User.id == target_user_id).first()
        
    if not target_user:
        raise HTTPException(status_code=404, detail="Target user not found")
        
    session = db.query(models.ChatSession).filter(
        ((models.ChatSession.user1_id == current_user.id) & (models.ChatSession.user2_id == target_user.id)) |
        ((models.ChatSession.user1_id == target_user.id) & (models.ChatSession.user2_id == current_user.id))
    ).first()
    
    if not session:
        session = models.ChatSession(user1_id=current_user.id, user2_id=target_user.id)
        db.add(session)
        db.commit()
        db.refresh(session)
        
    return {
        "id": session.id,
        "other_user": {
            "id": target_user.id,
            "full_name": target_user.full_name,
            "email": target_user.email,
            "role": target_user.role
        }
    }

@app.get("/chat/sessions/{user_email}")
async def get_user_chat_sessions(user_email: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    sessions = db.query(models.ChatSession).filter(
        (models.ChatSession.user1_id == user.id) | (models.ChatSession.user2_id == user.id)
    ).all()
    
    result = []
    for s in sessions:
        other_user = s.user2 if s.user1_id == user.id else s.user1
        if not other_user: 
            continue
            
        latest_msg = db.query(models.ChatMessage).filter(
            models.ChatMessage.session_id == s.id
        ).order_by(models.ChatMessage.created_at.desc()).first()
        
        unread_count = db.query(models.ChatMessage).filter(
            models.ChatMessage.session_id == s.id,
            models.ChatMessage.sender_id == other_user.id,
            models.ChatMessage.is_read == 0
        ).count()
        
        result.append({
            "session_id": s.id,
            "other_user": {
                "id": other_user.id,
                "full_name": other_user.full_name,
                "email": other_user.email,
                "role": other_user.role
            },
            "latest_message": latest_msg.content if latest_msg else "",
            "latest_message_time": latest_msg.created_at.isoformat() if latest_msg and latest_msg.created_at else "",
            "unread_count": unread_count
        })
    result.sort(key=lambda x: x["latest_message_time"] or "1970-01-01T00:00:00", reverse=True)
    return result

@app.get("/chat/sessions/{session_id}/messages")
async def get_chat_messages(session_id: int, current_user_email: str = None, db: Session = Depends(get_db)):
    session = db.query(models.ChatSession).filter(models.ChatSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
        
    messages = db.query(models.ChatMessage).filter(models.ChatMessage.session_id == session_id).order_by(models.ChatMessage.created_at.asc()).all()
    
    if current_user_email:
        user = db.query(models.User).filter(models.User.email == current_user_email).first()
        if user:
            unread_msgs = db.query(models.ChatMessage).filter(
                models.ChatMessage.session_id == session_id,
                models.ChatMessage.sender_id != user.id,
                models.ChatMessage.is_read == 0
            ).all()
            for msg in unread_msgs:
                msg.is_read = 1
            if unread_msgs:
                db.commit()
    
    return [
        {
            "id": m.id,
            "sender_id": m.sender_id,
            "sender_name": m.sender.full_name if m.sender else "Unknown",
            "content": m.content,
            "created_at": m.created_at.isoformat() if m.created_at else "",
            "is_read": m.is_read == 1
        }
        for m in messages
    ]

@app.post("/chat/sessions/{session_id}/messages")
async def send_chat_message(
    session_id: int,
    sender_email: str = Form(...),
    content: str = Form(...),
    db: Session = Depends(get_db)
):
    session = db.query(models.ChatSession).filter(models.ChatSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
        
    sender = db.query(models.User).filter(models.User.email == sender_email).first()
    if not sender:
        raise HTTPException(status_code=404, detail="Sender not found")
        
    new_message = models.ChatMessage(
        session_id=session_id,
        sender_id=sender.id,
        content=content
    )
    db.add(new_message)
    db.commit()
    db.refresh(new_message)
    
    return {
        "id": new_message.id,
        "sender_id": new_message.sender_id,
        "sender_name": sender.full_name,
        "content": new_message.content,
        "created_at": new_message.created_at.isoformat() if new_message.created_at else "",
        "is_read": new_message.is_read == 1
    }

# --- Group Chat Endpoints ---

@app.get("/users/all")
async def get_all_users(db: Session = Depends(get_db)):
    users = db.query(models.User).all()
    return [{"id": u.id, "email": u.email, "full_name": u.full_name, "role": u.role} for u in users]

@app.post("/groups")
async def create_group_chat(
    name: str = Form(...),
    admin_email: str = Form(...),
    member_emails: list[str] = Form(...),
    photo: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    admin = db.query(models.User).filter(models.User.email == admin_email).first()
    if not admin:
        raise HTTPException(status_code=404, detail="Admin not found")

    photo_url = None
    if photo:
        file_path = os.path.join(UPLOAD_DIR, f"grp_{secrets.token_hex(8)}_{photo.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(photo.file, buffer)
        photo_url = f"/uploads/{os.path.basename(file_path)}"

    # Create GroupChat
    group = models.GroupChat(name=name, photo_url=photo_url, admin_id=admin.id)
    db.add(group)
    db.commit()
    db.refresh(group)

    # Add Admin as a member
    admin_member = models.GroupMember(group_id=group.id, user_id=admin.id)
    db.add(admin_member)

    # Add other members
    import json
    if len(member_emails) == 1 and member_emails[0].startswith('['):
        try:
            member_emails = json.loads(member_emails[0])
        except:
            pass

    for m_email in member_emails:
        m_email = m_email.strip()
        if m_email == admin_email:
            continue
        user = db.query(models.User).filter(models.User.email == m_email).first()
        if user:
            new_member = models.GroupMember(group_id=group.id, user_id=user.id)
            db.add(new_member)

    db.commit()
    return {"message": "Group created successfully", "group_id": group.id}

@app.get("/groups/user/{user_email}")
async def get_user_groups(user_email: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    memberships = db.query(models.GroupMember).filter(models.GroupMember.user_id == user.id).all()
    group_ids = [m.group_id for m in memberships]

    groups = db.query(models.GroupChat).filter(models.GroupChat.id.in_(group_ids)).all()

    result = []
    for g in groups:
        latest_msg = db.query(models.GroupMessage).filter(
            models.GroupMessage.group_id == g.id
        ).order_by(models.GroupMessage.created_at.desc()).first()

        result.append({
            "id": g.id,
            "name": g.name,
            "photo_url": g.photo_url,
            "admin_id": g.admin_id,
            "latest_message": latest_msg.content if latest_msg else "",
            "latest_message_time": latest_msg.created_at.isoformat() if latest_msg and latest_msg.created_at else "",
        })
    result.sort(key=lambda x: x["latest_message_time"] or "1970-01-01T00:00:00", reverse=True)
    return result

@app.get("/groups/{group_id}/messages")
async def get_group_messages(group_id: int, db: Session = Depends(get_db)):
    messages = db.query(models.GroupMessage).filter(models.GroupMessage.group_id == group_id).order_by(models.GroupMessage.created_at.asc()).all()
    
    return [
        {
            "id": m.id,
            "sender_id": m.sender_id,
            "sender_name": m.sender.full_name if m.sender else "Unknown",
            "sender_email": m.sender.email if m.sender else "unknown@domain.com",
            "content": m.content,
            "created_at": m.created_at.isoformat() if m.created_at else "",
        }
        for m in messages
    ]

@app.post("/groups/{group_id}/messages")
async def send_group_message(
    group_id: int,
    sender_email: str = Form(...),
    content: str = Form(...),
    db: Session = Depends(get_db)
):
    group = db.query(models.GroupChat).filter(models.GroupChat.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    sender = db.query(models.User).filter(models.User.email == sender_email).first()
    if not sender:
        raise HTTPException(status_code=404, detail="Sender not found")
        
    membership = db.query(models.GroupMember).filter(models.GroupMember.group_id == group_id, models.GroupMember.user_id == sender.id).first()
    if not membership:
        raise HTTPException(status_code=403, detail="Not a member of this group")

    new_message = models.GroupMessage(
        group_id=group_id,
        sender_id=sender.id,
        content=content
    )
    db.add(new_message)
    db.commit()
    db.refresh(new_message)

    return {
        "id": new_message.id,
        "sender_id": new_message.sender_id,
        "sender_name": sender.full_name,
        "sender_email": sender.email,
        "content": new_message.content,
        "created_at": new_message.created_at.isoformat() if new_message.created_at else "",
    }

# --- Group Settings UI Endpoints ---

@app.get("/groups/{group_id}")
async def get_group_details(group_id: int, db: Session = Depends(get_db)):
    group = db.query(models.GroupChat).filter(models.GroupChat.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")
        
    memberships = db.query(models.GroupMember).filter(models.GroupMember.group_id == group_id).all()
    member_details = []
    for m in memberships:
        user = db.query(models.User).filter(models.User.id == m.user_id).first()
        if user:
            member_details.append({
                "id": user.id,
                "email": user.email,
                "full_name": user.full_name,
                "role": user.role
            })
            
    return {
        "id": group.id,
        "name": group.name,
        "photo_url": group.photo_url,
        "admin_id": group.admin_id,
        "members": member_details
    }

@app.put("/groups/{group_id}")
async def update_group_chat(
    group_id: int,
    name: str = Form(None),
    admin_email: str = Form(...),
    photo: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    group = db.query(models.GroupChat).filter(models.GroupChat.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    admin = db.query(models.User).filter(models.User.email == admin_email).first()
    if not admin or group.admin_id != admin.id:
        raise HTTPException(status_code=403, detail="Only the owner can update the group")

    if name:
        group.name = name

    if photo:
        file_path = os.path.join(UPLOAD_DIR, f"grp_{secrets.token_hex(8)}_{photo.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(photo.file, buffer)
        group.photo_url = f"/uploads/{os.path.basename(file_path)}"

    db.commit()
    db.refresh(group)
    return {"message": "Group updated", "photo_url": group.photo_url}

@app.post("/groups/{group_id}/members")
async def add_group_members(
    group_id: int,
    admin_email: str = Form(...),
    member_emails: list[str] = Form(...),
    db: Session = Depends(get_db)
):
    group = db.query(models.GroupChat).filter(models.GroupChat.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    admin = db.query(models.User).filter(models.User.email == admin_email).first()
    if not admin or group.admin_id != admin.id:
        raise HTTPException(status_code=403, detail="Only owner can add members")

    import json
    if len(member_emails) == 1 and member_emails[0].startswith('['):
        try:
            member_emails = json.loads(member_emails[0])
        except:
            pass
            
    added_count = 0
    for m_email in member_emails:
        m_email = m_email.strip()
        user = db.query(models.User).filter(models.User.email == m_email).first()
        if user:
            existing = db.query(models.GroupMember).filter(
                models.GroupMember.group_id == group_id, 
                models.GroupMember.user_id == user.id
            ).first()
            if not existing:
                new_member = models.GroupMember(group_id=group_id, user_id=user.id)
                db.add(new_member)
                added_count += 1

    db.commit()
    return {"message": f"Added {added_count} members"}

@app.delete("/groups/{group_id}/members/{user_email}")
async def remove_group_member(
    group_id: int,
    user_email: str,
    admin_email: str,
    db: Session = Depends(get_db)
):
    group = db.query(models.GroupChat).filter(models.GroupChat.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    admin = db.query(models.User).filter(models.User.email == admin_email).first()
    if not admin or group.admin_id != admin.id:
        raise HTTPException(status_code=403, detail="Only owner can remove members")

    user_to_remove = db.query(models.User).filter(models.User.email == user_email).first()
    if not user_to_remove:
        raise HTTPException(status_code=404, detail="User to remove not found")

    if user_to_remove.id == group.admin_id:
        raise HTTPException(status_code=400, detail="Cannot remove the owner")

    membership = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id,
        models.GroupMember.user_id == user_to_remove.id
    ).first()

    if membership:
        db.delete(membership)
        db.commit()

    return {"message": "Member removed"}

@app.put("/groups/{group_id}/owner")
async def transfer_group_ownership(
    group_id: int,
    admin_email: str = Form(...),
    new_owner_email: str = Form(...),
    db: Session = Depends(get_db)
):
    group = db.query(models.GroupChat).filter(models.GroupChat.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    admin = db.query(models.User).filter(models.User.email == admin_email).first()
    if not admin or group.admin_id != admin.id:
        raise HTTPException(status_code=403, detail="Only current owner can transfer ownership")
        
    new_owner = db.query(models.User).filter(models.User.email == new_owner_email).first()
    if not new_owner:
        raise HTTPException(status_code=404, detail="New owner not found")

    membership = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id, 
        models.GroupMember.user_id == new_owner.id
    ).first()
    
    if not membership:
        new_membership = models.GroupMember(group_id=group_id, user_id=new_owner.id)
        db.add(new_membership)

    group.admin_id = new_owner.id
    db.commit()
    
    return {"message": "Ownership transferred"}

# --- Progress & Challenges Endpoints ---

@app.get("/student/progress/{email}")
async def get_student_progress(email: str, db: Session = Depends(get_db)):
    student = db.query(models.User).filter(models.User.email == email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    progress = 0.0

    # 1. Assignments & Quizzes: +3% each
    assign_subs = db.query(models.AssignmentSubmission).filter(models.AssignmentSubmission.student_id == student.id).count()
    quiz_subs = db.query(models.QuizSubmission).filter(models.QuizSubmission.student_id == student.id).count()
    progress += (assign_subs + quiz_subs) * 3.0

    # 2. Midterm/Final Exams: >80 (+5%), >50 (+2%)
    exam_marks = db.query(models.ExamMark).filter(models.ExamMark.student_id == student.id).all()
    for em in exam_marks:
        try:
            val = float(em.mark)
            if val > 80: progress += 5.0
            elif val > 50: progress += 2.0
        except: pass

    # 3. Attendance: >80% (+2%)
    att_total = db.query(models.Attendance).filter(models.Attendance.student_id == student.id).count()
    att_present = db.query(models.Attendance).filter(models.Attendance.student_id == student.id, models.Attendance.status == "attended").count()
    if att_total > 0 and (att_present / att_total) > 0.8:
        progress += 2.0

    # 4. Weekly Challenges: +1% each, +3% if all current week done
    challenges = db.query(models.WeeklyChallenge).all()
    completions = db.query(models.ChallengeCompletion).filter(models.ChallengeCompletion.student_id == student.id).all()
    completed_ids = [c.challenge_id for c in completions]
    
    progress += len(completions) * 1.0
    
    if len(challenges) > 0 and len(completed_ids) == len(challenges):
        progress += 3.0

    # Cap at 100%
    progress = min(progress, 100.0)

    # Get real rank
    all_stats = get_all_student_averages_and_data(db, department=student.department, stage=student.stage)
    student_stats = all_stats.get(student.id)
    
    rank_text = "N/A"
    if student_stats:
        all_avgs = sorted([s["total_avg"] for s in all_stats.values()], reverse=True)
        rank = all_avgs.index(student_stats["total_avg"]) + 1 if student_stats["total_avg"] in all_avgs else len(all_avgs)
        total_students = len(all_stats)
        
        perc = (rank / total_students * 100) if total_students > 0 else 0
        if perc <= 5: rank_text = "Top 5% of Class"
        elif perc <= 10: rank_text = "Top 10% of Class"
        elif perc <= 20: rank_text = "Top 20% of Class"
        else: rank_text = f"Ranked #{rank} in Class"

    return {
        "progress": progress,
        "rank_text": rank_text,
        "rank": rank if student_stats else 0,
        "total_students": len(all_stats) if all_stats else 0
    }

@app.get("/challenges")
async def get_challenges(db: Session = Depends(get_db)):
    return db.query(models.WeeklyChallenge).order_by(models.WeeklyChallenge.created_at.desc()).all()

@app.post("/challenges")
async def create_challenge(title: str = Form(...), description: str = Form(None), points: int = Form(10), db: Session = Depends(get_db)):
    new_challenge = models.WeeklyChallenge(title=title, description=description, points=points)
    db.add(new_challenge)
    db.commit()
    db.refresh(new_challenge)
    return new_challenge

@app.post("/challenges/{challenge_id}/complete")
async def complete_challenge(challenge_id: int, student_email: str = Form(...), db: Session = Depends(get_db)):
    student = db.query(models.User).filter(models.User.email == student_email).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    existing = db.query(models.ChallengeCompletion).filter(
        models.ChallengeCompletion.challenge_id == challenge_id,
        models.ChallengeCompletion.student_id == student.id
    ).first()
    
    if existing:
        return {"message": "Already completed"}
        
    completion = models.ChallengeCompletion(challenge_id=challenge_id, student_id=student.id)
    db.add(completion)
    db.commit()
    return {"message": "Challenge completed"}

if __name__ == "__main__":
    import uvicorn
    import os
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
