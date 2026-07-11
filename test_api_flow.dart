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
    validateStatus: (status) => true, // Don't throw on error status codes
  ));

  print('--- Testing Authentication & Organization Flow ---');

  // 1. Sign Up
  final email = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
  final password = 'password123';
  
  print('\n1. Attempting to Sign Up ($email)...');
  final signupResponse = await dio.post('/auth/register', data: {
    'name': 'Test User',
    'email': email,
    'password': password,
  });
  print('Status: ${signupResponse.statusCode}');
  print('Response: ${signupResponse.data}');

  // 2. Login
  print('\n2. Attempting to Login...');
  final loginResponse = await dio.post('/auth/login', data: {
    'email': email,
    'password': password,
  });
  print('Status: ${loginResponse.statusCode}');
  print('Response: ${loginResponse.data}');
  
  if (loginResponse.statusCode != 200) {
    print('Login failed. Stopping test.');
    return;
  }

  final token = loginResponse.data['token'];
  dio.options.headers['Authorization'] = 'Bearer $token';

  // 3. Fetch Workspaces (Should be empty initially)
  print('\n3. Fetching My Workspaces...');
  final workspacesResponse = await dio.get('/workspaces/my');
  print('Status: ${workspacesResponse.statusCode}');
  print('Response: ${workspacesResponse.data}');

  // 4. Create Workspace
  print('\n4. Creating Organization (Workspace)...');
  final createWorkspaceResponse = await dio.post('/workspaces', data: {
    'name': 'Test University',
    'description': 'A university created via automated test.',
    'domainType': 'Education',
  });
  print('Status: ${createWorkspaceResponse.statusCode}');
  print('Response: ${createWorkspaceResponse.data}');

  // 5. Fetch Workspaces Again (Should have 1 now)
  print('\n5. Fetching My Workspaces Again...');
  final workspacesAgainResponse = await dio.get('/workspaces/my');
  print('Status: ${workspacesAgainResponse.statusCode}');
  print('Response: ${workspacesAgainResponse.data}');
  
  print('\n--- Test Completed ---');
}
