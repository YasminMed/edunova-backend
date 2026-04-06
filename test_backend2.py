import urllib.request
import urllib.parse
import json

url = "http://127.0.0.1:8000/courses/1/assignments"

def post_data(title, content, category):
    data = urllib.parse.urlencode({
        "title": title,
        "content": content,
        "category": category
    }).encode("utf-8")
    req = urllib.request.Request(url, data=data)
    try:
        with urllib.request.urlopen(req) as response:
            print("Create", category, response.status, response.read().decode())
    except urllib.error.URLError as e:
        print("Error creating:", e)

post_data("Test Assgn 2", "Test", "assignment")
post_data("Test Quiz 2", "Test", "quiz")

def get_data(category):
    req = urllib.request.Request(url + f"?category={category}")
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            print("Get", category, "count:", len(data))
            for item in data:
                print(f" - {item.get('title')} : {item.get('category')}")
    except urllib.error.URLError as e:
        print("Error fetching:", e)

get_data("assignment")
get_data("quiz")
