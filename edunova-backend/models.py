from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
try:
    from database import Base
except ImportError:
    try:
        from .database import Base
    except ImportError:
        import database
        Base = database.Base
import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    full_name = Column(String, default="Unknown")
    gender = Column(String, default="Male")
    role = Column(String, default="student") # "student" or "lecturer"
    department = Column(String, nullable=True) # Student: "IT", Lecturer: "IT, SE"
    stage = Column(String, nullable=True)      # Student: "1st", Lecturer: "1st, 2nd"
    years_of_experience = Column(Integer, default=0)
    image_url = Column(String, nullable=True)

    posts = relationship("Post", back_populates="author")
    fee_installments = relationship("FeeInstallment", back_populates="student")

class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String, nullable=False)
    description = Column(String)
    image_url = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    author = relationship("User", back_populates="posts")

class Course(Base):
    __tablename__ = "courses"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, index=True, nullable=False)
    image_url = Column(String, nullable=True)
    lecturer_id = Column(Integer, ForeignKey("users.id"))
    department = Column(String, nullable=False, default="Software Engineering")
    stage = Column(String, nullable=False, default="1st")

    resources = relationship("CourseResource", back_populates="course", cascade="all, delete-orphan")
    attendance = relationship("Attendance", back_populates="course", cascade="all, delete-orphan")
    lecturer = relationship("User")

class CourseResource(Base):
    __tablename__ = "course_resources"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    category = Column(String, nullable=False) # pdf, assignment, quiz, exam
    title = Column(String, nullable=False)
    file_url = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    course = relationship("Course", back_populates="resources")

class Attendance(Base):
    __tablename__ = "attendance_records"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    student_id = Column(Integer, ForeignKey("users.id"))
    student_name = Column(String, nullable=False) # Keep for backward compatibility/ease
    status = Column(String, nullable=False) # attended, late, absent
    date = Column(DateTime, default=datetime.datetime.utcnow)

    course = relationship("Course", back_populates="attendance")
    student = relationship("User")

class Assignment(Base):
    __tablename__ = "assignments"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    category = Column(String, default="assignment") # "assignment" or "quiz"
    title = Column(String, nullable=False)
    content = Column(String, nullable=False)
    file_url = Column(String, nullable=True) # Reference file (PDF etc)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    course = relationship("Course")
    submissions = relationship("AssignmentSubmission", back_populates="assignment", cascade="all, delete-orphan")

class ExamMark(Base):
    __tablename__ = "exam_marks"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    student_id = Column(Integer, ForeignKey("users.id"))
    exam_type = Column(String, nullable=False) # "midterm" or "final"
    mark = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    course = relationship("Course")
    student = relationship("User")

class AssignmentSubmission(Base):
    __tablename__ = "assignment_submissions"

    id = Column(Integer, primary_key=True, index=True)
    assignment_id = Column(Integer, ForeignKey("assignments.id"))
    student_id = Column(Integer, ForeignKey("users.id"))
    solution_text = Column(String)
    file_url = Column(String) # Uploaded solution file
    grade = Column(String) # For now, keep as string (e.g., "A", "95/100")
    lecturer_note = Column(String)
    submitted_at = Column(DateTime, default=datetime.datetime.utcnow)
    is_graded = Column(Integer, default=0) # 0 for no, 1 for yes

    assignment = relationship("Assignment", back_populates="submissions")
    student = relationship("User")

class Quiz(Base):
    __tablename__ = "quizzes"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    title = Column(String, nullable=False)
    content = Column(String, nullable=False)
    file_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    course = relationship("Course")
    submissions = relationship("QuizSubmission", back_populates="quiz", cascade="all, delete-orphan")

class QuizSubmission(Base):
    __tablename__ = "quiz_submissions"

    id = Column(Integer, primary_key=True, index=True)
    quiz_id = Column(Integer, ForeignKey("quizzes.id"))
    student_id = Column(Integer, ForeignKey("users.id"))
    solution_text = Column(String)
    file_url = Column(String)
    grade = Column(String)
    lecturer_note = Column(String)
    submitted_at = Column(DateTime, default=datetime.datetime.utcnow)
    is_graded = Column(Integer, default=0)

    quiz = relationship("Quiz", back_populates="submissions")
    student = relationship("User")

class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user1_id = Column(Integer, ForeignKey("users.id"))
    user2_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user1 = relationship("User", foreign_keys=[user1_id])
    user2 = relationship("User", foreign_keys=[user2_id])
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("chat_sessions.id"))
    sender_id = Column(Integer, ForeignKey("users.id"))
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    is_read = Column(Integer, default=0)

    session = relationship("ChatSession", back_populates="messages")
    sender = relationship("User", foreign_keys=[sender_id])

class GroupChat(Base):
    __tablename__ = "group_chats"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    photo_url = Column(String, nullable=True)
    admin_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    admin = relationship("User")
    members = relationship("GroupMember", back_populates="group", cascade="all, delete-orphan")
    messages = relationship("GroupMessage", back_populates="group", cascade="all, delete-orphan")

class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("group_chats.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    joined_at = Column(DateTime, default=datetime.datetime.utcnow)

    group = relationship("GroupChat", back_populates="members")
    user = relationship("User")

class GroupMessage(Base):
    __tablename__ = "group_messages"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("group_chats.id"))
    sender_id = Column(Integer, ForeignKey("users.id"))
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    group = relationship("GroupChat", back_populates="messages")
    sender = relationship("User")

class FeeInstallment(Base):
    __tablename__ = "fee_installments"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String, nullable=False) # e.g., "1st Installment"
    amount = Column(String, nullable=False) # e.g., "750,000"
    status = Column(String, default="due") # "paid" or "due"
    due_date = Column(String) # e.g., "Jan 15, 2026"
    paid_at = Column(DateTime, nullable=True)
    proof_url = Column(String, nullable=True) # For cash/bank receipts

    student = relationship("User", back_populates="fee_installments")

class WeeklyChallenge(Base):
    __tablename__ = "weekly_challenges"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String)
    points = Column(Integer, default=10)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class ChallengeCompletion(Base):
    __tablename__ = "challenge_completions"

    id = Column(Integer, primary_key=True, index=True)
    challenge_id = Column(Integer, ForeignKey("weekly_challenges.id"))
    student_id = Column(Integer, ForeignKey("users.id"))
    completed_at = Column(DateTime, default=datetime.datetime.utcnow)

    challenge = relationship("WeeklyChallenge")
    student = relationship("User")
