from database import SessionLocal
import models
import os

def set_admin_password():
    db = SessionLocal()
    try:
        user = db.query(models.User).filter(models.User.email == "root@edunova.com").first()
        if user:
            user.password = "Admin123!"
            db.commit()
            print(f"Successfully set password for {user.email}")
        else:
            print("Admin user root@edunova.com not found.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    set_admin_password()
