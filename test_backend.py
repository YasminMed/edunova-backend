import requests

url = "http://127.0.0.1:8000/courses/1/assignments"

# Create Assignment
res1 = requests.post(url, data={
    "title": "Test Assignment",
    "content": "This is an assignment",
    "category": "assignment"
})
print("Create Assignment:", res1.status_code, res1.text)

# Create Quiz
res2 = requests.post(url, data={
    "title": "Test Quiz",
    "content": "This is a quiz",
    "category": "quiz"
})
print("Create Quiz:", res2.status_code, res2.text)

# Get Assignments
get1 = requests.get(url + "?category=assignment")
print("Get Assignments:", get1.status_code)
for item in get1.json():
    print(f" - {item['title']} : {item['category']}")

# Get Quizzes
get2 = requests.get(url + "?category=quiz")
print("Get Quizzes:", get2.status_code)
for item in get2.json():
    print(f" - {item['title']} : {item['category']}")
