import requests

url = "https://edunova-backend-production.up.railway.app/groups/1"
data = {"admin_email": "smsm@gmail.com"}
files = {"photo": ("test.jpg", b"hello world", "image/jpeg")}

r = requests.put(url, data=data, files=files)
print(r.status_code)
print(r.text)
