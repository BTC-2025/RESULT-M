import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8080/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true,
  ));

  print('--- Seeding Demo Data ---');

  // 1. Sign Up Admin User
  final email = 'admin_${DateTime.now().millisecondsSinceEpoch}@demo.com';
  final password = 'password123';
  
  print('\n1. Creating Admin User ($email)...');
  await dio.post('/auth/register', data: {
    'name': 'Demo Admin',
    'email': email,
    'password': password,
  });

  // 2. Login
  final loginResponse = await dio.post('/auth/login', data: {
    'email': email,
    'password': password,
  });
  
  if (loginResponse.statusCode != 200) {
    print('Login failed. Stopping test.');
    return;
  }

  final token = loginResponse.data['token'];
  dio.options.headers['Authorization'] = 'Bearer $token';

  // 3. Create Anna University Workspace
  print('\n2. Creating Academic Workspace...');
  final ws1Res = await dio.post('/workspaces', data: {
    'name': 'Anna University',
    'description': 'Official portal for university results and announcements.',
    'domainType': 'ACADEMIC',
  });
  final ws1Id = ws1Res.data['id'];

  print('Creating Academic Dataset...');
  final ds1Res = await dio.post('/workspaces/$ws1Id/datasets', data: {
    'name': 'B.E/B.Tech Nov/Dec 2025 Results',
    'slug': 'btech-nov-dec-2025',
    'description': 'UG Degree Examination Results',
    'domainType': 'ACADEMIC'
  });
  final ds1Id = ds1Res.data['id'];

  // Publish Dataset
  await dio.put('/workspaces/$ws1Id/datasets/$ds1Id', data: {
    'name': 'B.E/B.Tech Nov/Dec 2025 Results',
    'slug': 'btech-nov-dec-2025',
    'description': 'UG Degree Examination Results',
    'domainType': 'ACADEMIC',
    'status': 'PUBLISHED'
  });

  print('Inserting Academic Records...');
  await dio.post('/datasets/$ds1Id/records', data: {
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
  });
  await dio.post('/datasets/$ds1Id/records', data: {
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
  });

  // 4. Create Sports Workspace
  print('\n3. Creating Sports Workspace...');
  final ws2Res = await dio.post('/workspaces', data: {
    'name': 'IPL 2026',
    'description': 'Official Live Scores for Indian Premier League',
    'domainType': 'SPORT',
  });
  final ws2Id = ws2Res.data['id'];

  print('Creating Sports Dataset...');
  final ds2Res = await dio.post('/workspaces/$ws2Id/datasets', data: {
    'name': 'Match 47: MI vs CSK',
    'slug': 'match-47-mi-csk',
    'description': 'Live ball-by-ball updates',
    'domainType': 'SPORT'
  });
  final ds2Id = ds2Res.data['id'];

  await dio.put('/workspaces/$ws2Id/datasets/$ds2Id', data: {
    'name': 'Match 47: MI vs CSK',
    'slug': 'match-47-mi-csk',
    'description': 'Live ball-by-ball updates',
    'domainType': 'SPORT',
    'status': 'PUBLISHED'
  });

  print('Inserting Sports Records...');
  await dio.post('/datasets/$ds2Id/records', data: {
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
  });

  // 5. Create Government Workspace
  print('\n4. Creating Government Workspace...');
  final ws3Res = await dio.post('/workspaces', data: {
    'name': 'TN Election Commission',
    'description': 'Live Election Counting 2026',
    'domainType': 'ELECTION',
  });
  final ws3Id = ws3Res.data['id'];

  print('Creating Election Dataset...');
  final ds3Res = await dio.post('/workspaces/$ws3Id/datasets', data: {
    'name': 'Chennai South Constituency',
    'slug': 'chennai-south-2026',
    'description': 'Assembly Election Live Counts',
    'domainType': 'ELECTION'
  });
  final ds3Id = ds3Res.data['id'];

  await dio.put('/workspaces/$ws3Id/datasets/$ds3Id', data: {
    'name': 'Chennai South Constituency',
    'slug': 'chennai-south-2026',
    'description': 'Assembly Election Live Counts',
    'domainType': 'ELECTION',
    'status': 'PUBLISHED'
  });

  print('Inserting Election Records...');
  await dio.post('/datasets/$ds3Id/records', data: {
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
  });

  print('\n--- Demo Data Seeding Completed ---');
  print('Try searching for "1928374" in the app!');
}
