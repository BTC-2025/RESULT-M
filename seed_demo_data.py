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
        print(f"Error {e.code}: {e.read().decode()}")
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

print('--- Seeding Demo Data ---')

email = f"admin_{int(time.time())}@demo.com"
password = "password123"

print(f"\n1. Creating Admin User ({email})...")
api_post('/auth/register', {
    'name': 'Demo Admin',
    'email': email,
    'password': password
})

print("Logging in...")
login_res = api_post('/auth/login', {
    'email': email,
    'password': password
})

if not login_res or 'token' not in login_res:
    print("Login failed!")
    exit(1)

token = login_res['token']

# 2. Anna University
print('\n2. Creating Academic Workspace...')
ws1 = api_post('/workspaces', {
    'name': 'Anna University',
    'description': 'Official portal for university results and announcements.',
    'domainType': 'ACADEMIC'
}, token)
ws1_id = ws1['id']

print('Creating Academic Dataset...')
ds1 = api_post(f'/workspaces/{ws1_id}/datasets', {
    'name': 'B.E/B.Tech Nov/Dec 2025 Results',
    'slug': 'btech-nov-dec-2025',
    'description': 'UG Degree Examination Results',
    'domainType': 'ACADEMIC'
}, token)
ds1_id = ds1['id']

print('Publishing Dataset...')
api_put(f'/workspaces/{ws1_id}/datasets/{ds1_id}', {
    'name': 'B.E/B.Tech Nov/Dec 2025 Results',
    'slug': 'btech-nov-dec-2025',
    'description': 'UG Degree Examination Results',
    'domainType': 'ACADEMIC',
    'status': 'PUBLISHED'
}, token)

print('Inserting Academic Records...')
api_post(f'/datasets/{ds1_id}/records', {
    'recordKey': '1928374',
    'recordTitle': 'Rahul Kumar',
    'tags': ['CS', 'Pass'],
    'data': {
        'Name': 'Rahul Kumar',
        'Roll Number': '1928374',
        'Department': 'Computer Science',
        'GPA': 8.9,
        'Result': 'PASS'
    }
}, token)

api_post(f'/datasets/{ds1_id}/records', {
    'recordKey': '1928375',
    'recordTitle': 'Priya Sharma',
    'tags': ['EE', 'Pass'],
    'data': {
        'Name': 'Priya Sharma',
        'Roll Number': '1928375',
        'Department': 'Electrical Engineering',
        'GPA': 9.2,
        'Result': 'PASS'
    }
}, token)

# 3. IPL 2026
print('\n3. Creating Sports Workspace...')
ws2 = api_post('/workspaces', {
    'name': 'IPL 2026',
    'description': 'Official Live Scores for Indian Premier League',
    'domainType': 'SPORT'
}, token)
ws2_id = ws2['id']

print('Creating Sports Dataset...')
ds2 = api_post(f'/workspaces/{ws2_id}/datasets', {
    'name': 'Match 47: MI vs CSK',
    'slug': 'match-47-mi-csk',
    'description': 'Live ball-by-ball updates',
    'domainType': 'SPORT'
}, token)
ds2_id = ds2['id']

api_put(f'/workspaces/{ws2_id}/datasets/{ds2_id}', {
    'name': 'Match 47: MI vs CSK',
    'slug': 'match-47-mi-csk',
    'description': 'Live ball-by-ball updates',
    'domainType': 'SPORT',
    'status': 'PUBLISHED'
}, token)

print('Inserting Sports Records...')
api_post(f'/datasets/{ds2_id}/records', {
    'recordKey': 'inn2_ov15',
    'recordTitle': 'Over 15.2',
    'tags': ['LIVE', 'Boundary'],
    'data': {
        'Innings': 2,
        'Batting Team': 'MI',
        'Score': '186/4',
        'Batsman': 'Rohit Sharma (72*)',
        'Bowler': 'Ravindra Jadeja',
        'Commentary': 'FOUR! Swept perfectly in the gap.',
        'Target': 232
    }
}, token)

# 4. TN Election Commission
print('\n4. Creating Government Workspace...')
ws3 = api_post('/workspaces', {
    'name': 'TN Election Commission',
    'description': 'Live Election Counting 2026',
    'domainType': 'ELECTION'
}, token)
ws3_id = ws3['id']

print('Creating Election Dataset...')
ds3 = api_post(f'/workspaces/{ws3_id}/datasets', {
    'name': 'Chennai South Constituency',
    'slug': 'chennai-south-2026',
    'description': 'Assembly Election Live Counts',
    'domainType': 'ELECTION'
}, token)
ds3_id = ds3['id']

api_put(f'/workspaces/{ws3_id}/datasets/{ds3_id}', {
    'name': 'Chennai South Constituency',
    'slug': 'chennai-south-2026',
    'description': 'Assembly Election Live Counts',
    'domainType': 'ELECTION',
    'status': 'PUBLISHED'
}, token)

print('Inserting Election Records...')
api_post(f'/datasets/{ds3_id}/records', {
    'recordKey': 'round_12',
    'recordTitle': 'Round 12 Counting',
    'tags': ['Counting', 'Update'],
    'data': {
        'Candidate 1 (DMK)': 45200,
        'Candidate 2 (AIADMK)': 32150,
        'Candidate 3 (NTK)': 8400,
        'Status': 'Counting in Progress',
        'Leading': 'DMK (+13,050)'
    }
}, token)

print('\n--- Demo Data Seeding Completed ---')
