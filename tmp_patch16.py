import codecs

path = r'c:\src\flutter-apps\edunova_application\edunova-backend\models.py'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """class AssignmentSubmission(Base):
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
    student = relationship("User")"""

replacement = """class AssignmentSubmission(Base):
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
    student = relationship("User")"""

if target in text:
    text = text.replace(target, replacement)
elif target.replace('\\n', '\\r\\n') in text:
    text = text.replace(target.replace('\\n', '\\r\\n'), replacement.replace('\\n', '\\r\\n'))
else:
    print("WARNING: target not found")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("models.py patched")
