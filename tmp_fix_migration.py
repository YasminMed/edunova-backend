import codecs

path = r'c:\src\flutter-apps\edunova_application\edunova-backend\main.py'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# 1. Fix the manual table creation for Quizzes and Submissions (SQLite syntax)
# id INTEGER PRIMARY KEY AUTOINCREMENT -> SERIAL PRIMARY KEY (for Postgres)
# DATETIME -> TIMESTAMP (Standard)
# Also add exam_marks table creation if missing from early startup

target_quizzes = """        try:
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

replacement_tables = """        # Create tables if create_all failed for some reason on existing DB
        try:
            # Check if we are on postgres
            is_postgres = "postgresql" in str(engine.url)
            
            serial_type = "SERIAL" if is_postgres else "INTEGER PRIMARY KEY AUTOINCREMENT"
            timestamp_type = "TIMESTAMP" if is_postgres else "DATETIME"
            
            # Quizzes
            db.execute(text(f'''CREATE TABLE IF NOT EXISTS quizzes (
                id {serial_type} PRIMARY KEY if is_postgres else "id INTEGER PRIMARY KEY AUTOINCREMENT",
                course_id INTEGER REFERENCES courses(id),
                title VARCHAR NOT NULL,
                content VARCHAR NOT NULL,
                file_url VARCHAR,
                created_at {timestamp_type} DEFAULT CURRENT_TIMESTAMP
            )'''))
            db.commit()
        except Exception as e:
            db.rollback()
            print(f"DEBUG Error creating quizzes: {e}")

        # Wait, the f-string logic above is messy. Let's do it cleaner.
        
        try:
            # Quiz Submissions
            db.execute(text(f"CREATE TABLE IF NOT EXISTS quiz_submissions (id SERIAL PRIMARY KEY, quiz_id INTEGER REFERENCES quizzes(id), student_id INTEGER REFERENCES users(id), solution_text TEXT, file_url TEXT, grade VARCHAR, lecturer_note TEXT, submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, is_graded INTEGER DEFAULT 0)") if "postgresql" in str(engine.url) else text("CREATE TABLE IF NOT EXISTS quiz_submissions (id INTEGER PRIMARY KEY AUTOINCREMENT, quiz_id INTEGER REFERENCES quizzes(id), student_id INTEGER REFERENCES users(id), solution_text VARCHAR, file_url VARCHAR, grade VARCHAR, lecturer_note VARCHAR, submitted_at DATETIME, is_graded INTEGER DEFAULT 0)"))
            db.commit()
        except Exception:
            db.rollback()

        try:
            # Exam Marks
            db.execute(text("CREATE TABLE IF NOT EXISTS exam_marks (id SERIAL PRIMARY KEY, course_id INTEGER REFERENCES courses(id), student_id INTEGER REFERENCES users(id), exam_type VARCHAR NOT NULL, mark VARCHAR NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)") if "postgresql" in str(engine.url) else text("CREATE TABLE IF NOT EXISTS exam_marks (id INTEGER PRIMARY KEY AUTOINCREMENT, course_id INTEGER REFERENCES courses(id), student_id INTEGER REFERENCES users(id), exam_type VARCHAR NOT NULL, mark VARCHAR NOT NULL, created_at DATETIME)"))
            db.commit()
        except Exception:
            db.rollback()"""

# Actually, the most robust way is to rely on Base.metadata.create_all(bind=engine)
# If it fails, it's often because of existing tables. 
# Let's just fix the manual ones to be simpler and cross-compatible or just stick to standard SQL.

replacement_fixed = """        # Create tables using standard SQL where possible or detect engine
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
        )"""

text = text.replace(target_quizzes, replacement_fixed)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("main.py migration logic fixed")
