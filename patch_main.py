import re
import os

filepath = 'edunova-backend/main.py'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern for file upload to UPLOAD_DIR
pattern1 = re.compile(
    r"""\s*file_path\s*=\s*os\.path\.join\(UPLOAD_DIR,\s*(.*?)\)\n\s*with open\(file_path, "wb"\) as buffer:\n\s*shutil\.copyfileobj\(file\.file, buffer\)\n\s*file_url\s*=\s*f"/uploads/\{os\.path\.basename\(file_path\)\}"\n""",
    re.MULTILINE | re.DOTALL
)

replacement1 = """        import uuid
        file_id = str(uuid.uuid4())
        file_content = await file.read()
        new_upload = models.UploadFile(
            id=file_id,
            filename=file.filename,
            content_type=file.content_type,
            data=file_content
        )
        db.add(new_upload)
        file_url = f"/api/files/{file_id}"
"""

content = pattern1.sub(replacement1, content)


pattern2 = re.compile(
    r"""\s*file_path\s*=\s*os\.path\.join\(UPLOAD_DIR,\s*(.*?)\)\n\s*with open\(file_path, "wb"\) as buffer:\n\s*shutil\.copyfileobj\(file\.file, buffer\)\n\s*photo_url\s*=\s*f"/uploads/\{os\.path\.basename\(file_path\)\}"\n""",
    re.MULTILINE | re.DOTALL
)

replacement2 = """        import uuid
        file_id = str(uuid.uuid4())
        file_content = await file.read()
        new_upload = models.UploadFile(
            id=file_id,
            filename=file.filename,
            content_type=file.content_type,
            data=file_content
        )
        db.add(new_upload)
        photo_url = f"/api/files/{file_id}"
"""

content = pattern2.sub(replacement2, content)


with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done patching.")
