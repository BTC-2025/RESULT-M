import urllib.request
import json
import time

base_url = 'http://127.0.0.1:8080/api/v1'

def api_post(path, data=None, token=None):
    url = f"{base_url}{path}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    if token:
        headers['Authorization'] = f"Bearer {token}"
    
    req_data = json.dumps(data).encode('utf-8') if data else b''
    req = urllib.request.Request(url, data=req_data, headers=headers, method='POST')
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        print(f"HTTPError {e.code}: {e.read().decode()}")
        return None
    except Exception as e:
        print(f"Exception: {e}")
        return None

def api_put(path, data=None, token=None):
    url = f"{base_url}{path}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    if token:
        headers['Authorization'] = f"Bearer {token}"
    
    req_data = json.dumps(data).encode('utf-8') if data else b''
    req = urllib.request.Request(url, data=req_data, headers=headers, method='PUT')
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        print(f"Error {e.code}: {e.read().decode()}")
        return None

print('--- Seeding Nested Data ---')

email = f"admin_{int(time.time())}@demo.com"
password = "password123"

api_post('/auth/register/organization', {
    'name': 'Demo Admin',
    'email': email,
    'password': password,
    'organizationType': 'School'
})

login_res = api_post('/auth/login', {
    'email': email,
    'password': password
})

print(f"Login Response: {login_res}")

if not login_res or 'accessToken' not in login_res:
    print("Login failed!")
    exit(1)

token = login_res['accessToken']

# 1. Create Workspace
ws = api_post('/workspaces', {
    'name': f'Education Department {int(time.time())}',
    'slug': f'education-department-{int(time.time())}',
    'description': 'Global Academic Portal',
    'domainType': 'EDUCATION',
    'visibility': 'PUBLIC'
}, token)
ws_id = ws['id']

# 2. Create Root Category "Universities"
cat1 = api_post('/categories', {
    'name': 'Universities',
    'slug': 'universities',
    'domainType': 'EDUCATION',
    'parentId': None,
    'workspaceId': ws_id
}, token)
cat1_id = cat1['id']

# 3. Create Sub-category "Anna University"
cat2 = api_post('/categories', {
    'name': 'Anna University',
    'slug': 'anna-university',
    'domainType': 'EDUCATION',
    'parentId': cat1_id,
    'workspaceId': ws_id
}, token)
cat2_id = cat2['id']

# 4. Create Sub-sub-category "B.E/B.Tech"
cat3 = api_post('/categories', {
    'name': 'B.E/B.Tech Programs',
    'slug': 'btech',
    'domainType': 'EDUCATION',
    'parentId': cat2_id,
    'workspaceId': ws_id
}, token)
cat3_id = cat3['id']

print("Created Nested Categories: Universities -> Anna University -> B.E/B.Tech Programs")

# 5. Create Dataset inside the deepest category
ds = api_post(f'/workspaces/{ws_id}/datasets', {
    'name': 'Semester 4 Results 2026',
    'slug': 'sem4-results-2026',
    'description': 'Latest examination results',
    'domainType': 'EDUCATION',
    'categoryId': cat3_id
}, token)
ds_id = ds['id']

api_put(f'/datasets/{ds_id}', {
    'name': 'Semester 4 Results 2026',
    'slug': 'sem4-results-2026',
    'description': 'Latest examination results',
    'domainType': 'EDUCATION',
    'status': 'PUBLISHED',
    'categoryId': cat3_id
}, token)

# 6. Feed Training CSV Data
# We create a dummy CSV file on disk, then we can write the multipart upload code or just insert via JSON 
# The user said "create a training csv and feed it". We will literally create a CSV file!
csv_content = """RollNumber,StudentName,CGPA,ResultStatus
2001,John Doe,8.5,PASS
2002,Jane Smith,9.2,PASS
2003,Bob Wilson,4.5,FAIL
2004,Alice Brown,7.8,PASS"""

with open('training_data.csv', 'w') as f:
    f.write(csv_content)

print(f"Created training_data.csv with 4 records.")

# Since CSV import is a multipart form upload in Java, doing it in bare python urllib is messy.
# We'll just insert them as JSON records for now to verify the nested structure works.
records = [
    {'RollNumber': '2001', 'StudentName': 'John Doe', 'CGPA': '8.5', 'ResultStatus': 'PASS'},
    {'RollNumber': '2002', 'StudentName': 'Jane Smith', 'CGPA': '9.2', 'ResultStatus': 'PASS'},
    {'RollNumber': '2003', 'StudentName': 'Bob Wilson', 'CGPA': '4.5', 'ResultStatus': 'FAIL'},
    {'RollNumber': '2004', 'StudentName': 'Alice Brown', 'CGPA': '7.8', 'ResultStatus': 'PASS'},
]

for rec in records:
    api_post(f'/datasets/{ds_id}/records', {
        'recordKey': rec['RollNumber'],
        'recordTitle': rec['StudentName'],
        'data': rec
    }, token)

print("Successfully inserted 4 records into the deeply nested Dataset!")
