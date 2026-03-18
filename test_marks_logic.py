import sys
import os

# Add the backend directory to sys.path so we can import models and database
backend_dir = os.path.join(os.getcwd(), "edunova-backend")
sys.path.append(backend_dir)

import models
from database import SessionLocal, engine
import datetime

def setup_test_data():
    db = SessionLocal()
    try:
        # 1. Create a test student
        test_email = "test_student@example.com"
        student = db.query(models.User).filter(models.User.email == test_email).first()
        if not student:
            student = models.User(email=test_email, password="password", full_name="Test Student", role="student")
            db.add(student)
            db.commit()
            db.refresh(student)
        
        # 2. Create another student for ranking
        other_email = "other_student@example.com"
        other_student = db.query(models.User).filter(models.User.email == other_email).first()
        if not other_student:
            other_student = models.User(email=other_email, password="password", full_name="Other Student", role="student")
            db.add(other_student)
            db.commit()
            db.refresh(other_student)

        # 3. Create a course
        course = db.query(models.Course).filter(models.Course.code == "TEST101").first()
        if not course:
            course = models.Course(name="Test Subject", code="TEST101", lecturer_id=1)
            db.add(course)
            db.commit()
            db.refresh(course)

        # 4. Add Marks for Test Student
        # Quiz
        quiz = models.Quiz(course_id=course.id, title="Quiz 1", content="Content")
        db.add(quiz)
        db.commit()
        db.refresh(quiz)
        
        sub1 = models.QuizSubmission(quiz_id=quiz.id, student_id=student.id, grade="90", is_graded=1)
        db.add(sub1)
        
        # Assignment
        assign = models.Assignment(course_id=course.id, title="Assign 1", content="Content")
        db.add(assign)
        db.commit()
        db.refresh(assign)
        
        sub2 = models.AssignmentSubmission(assignment_id=assign.id, student_id=student.id, grade="80", is_graded=1)
        db.add(sub2)
        
        # Exams
        m_mark = models.ExamMark(course_id=course.id, student_id=student.id, exam_type="midterm", mark="85")
        f_mark = models.ExamMark(course_id=course.id, student_id=student.id, exam_type="final", mark="95")
        db.add_all([m_mark, f_mark])
        
        # Attendance: 4 attended out of 5 -> 80% (+5% bonus)
        for i in range(4):
            db.add(models.Attendance(course_id=course.id, student_id=student.id, student_name="Test Student", status="attended"))
        db.add(models.Attendance(course_id=course.id, student_id=student.id, student_name="Test Student", status="absent"))

        # 5. Add lower marks for Other Student
        db.add(models.ExamMark(course_id=course.id, student_id=other_student.id, exam_type="final", mark="70"))
        db.add(models.Attendance(course_id=course.id, student_id=other_student.id, student_name="Other Student", status="attended"))

        db.commit()
        print("Test data setup complete.")
        return test_email
    except Exception as e:
        db.rollback()
        print(f"Error setting up test data: {e}")
        return None
    finally:
        db.close()

def test_api(email):
    import requests
    base_url = "http://127.0.0.1:8000"
    try:
        response = requests.get(f"{base_url}/student/academic-marks?student_email={email}")
        if response.status_code == 200:
            data = response.json()
            print("API Response:", data)
            
            # Expected values for Test Student:
            # Quiz avg: 90
            # Assign avg: 80
            # Midterm: 85
            # Final: 95
            # Base avg: (90+80+85+95)/4 = 350/4 = 87.5
            # Attendance: 4/5 = 80% -> +5% bonus
            # Final mark: 87.5 + 5 = 92.5
            
            subject = data['subjects'][0]
            print(f"Subject Mark: {subject['mark']} (Expected: 92.5)")
            print(f"Rank: {data['rank']} (Expected: 1)")
            
            if subject['mark'] == 92.5 and data['rank'] == 1:
                print("VERIFICATION SUCCESSFUL")
            else:
                print("VERIFICATION FAILED")
        else:
            print(f"API Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Connection Error: {e}")

if __name__ == "__main__":
    email = setup_test_data()
    if email:
        test_api(email)
