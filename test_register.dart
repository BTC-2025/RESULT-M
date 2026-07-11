import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('http://localhost:8080/api/v1/auth/register'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({
      'name': 'Super Admin',
      'email': 'admin@resulthub.com',
      'password': 'password123'
    }));
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Status: ${response.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
