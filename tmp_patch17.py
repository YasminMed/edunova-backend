import codecs
import re

path = r'c:\src\flutter-apps\edunova_application\edunova-backend\main.py'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Just append the new endpoints before the Exams endpoint.
# First, let's find the spot just after the assignments
target_split = "# --- Student & Exam Endpoints ---"

new_endpoints = """
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
"""

if target_split in text:
    text = text.replace(target_split, new_endpoints)
else:
    print("WARNING: Could not inject quiz endpoints.")

# Replace save_exam_marks with single item version, add PUT
target2 = """@app.post("/courses/{course_id}/exam_marks")
async def save_exam_marks(
    course_id: int,
    exam_type: str = Body(...),
    marks_data: list = Body(...), # [{"student_id": 1, "mark": "90"}]
    db: Session = Depends(get_db)
):
    for item in marks_data:
        student_id = item.get("student_id")
        mark_value = item.get("mark")
        if not student_id or not mark_value:
            continue
            
        existing_mark = db.query(models.ExamMark).filter(
            models.ExamMark.course_id == course_id,
            models.ExamMark.student_id == student_id,
            models.ExamMark.exam_type == exam_type
        ).first()
        
        if existing_mark:
            existing_mark.mark = str(mark_value)
        else:
            new_mark = models.ExamMark(
                course_id=course_id,
                student_id=student_id,
                exam_type=exam_type,
                mark=str(mark_value)
            )
            db.add(new_mark)
            
    db.commit()
    return {"message": "Exam marks saved successfully"}"""

replacement2 = """@app.get("/courses/{course_id}/exam_marks_full")
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
    return {"message": "Exam mark updated successfully"}"""

if target2 in text:
    text = text.replace(target2, replacement2)
elif target2.replace('\\n', '\\r\\n') in text:
    text = text.replace(target2.replace('\\n', '\\r\\n'), replacement2.replace('\\n', '\\r\\n'))
else:
    print("WARNING: Could not replace exam POST endpoint")

# Create tables in main.py
target3 = """        try:
            db.execute(text("ALTER TABLE assignments ADD COLUMN category VARCHAR DEFAULT 'assignment'"))
            db.commit()
            print("DEBUG: Added category column to assignments")
        except Exception:
            db.rollback()"""

replacement3 = """        try:
            db.execute(text("ALTER TABLE assignments ADD COLUMN category VARCHAR DEFAULT 'assignment'"))
            db.commit()
            print("DEBUG: Added category column to assignments")
        except Exception:
            db.rollback()

        try:
            db.execute(text('''CREATE TABLE IF NOT EXISTS quizzes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                course_id INTEGER REFERENCES courses(id),
                title VARCHAR NOT NULL,
                content VARCHAR NOT NULL,
                file_url VARCHAR,
                created_at DATETIME
            )'''))
            db.commit()
        except Exception as e:
            db.rollback()

        try:
            db.execute(text('''CREATE TABLE IF NOT EXISTS quiz_submissions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                quiz_id INTEGER REFERENCES quizzes(id),
                student_id INTEGER REFERENCES users(id),
                solution_text VARCHAR,
                file_url VARCHAR,
                grade VARCHAR,
                lecturer_note VARCHAR,
                submitted_at DATETIME,
                is_graded INTEGER DEFAULT 0
            )'''))
            db.commit()
        except Exception as e:
            db.rollback()"""

if target3 in text:
    text = text.replace(target3, replacement3)
elif target3.replace('\\n', '\\r\\n') in text:
    text = text.replace(target3.replace('\\n', '\\r\\n'), replacement3.replace('\\n', '\\r\\n'))

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("main.py patched")
