import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/result_model.dart';
import '../core/network/api_client.dart';

// Create a Riverpod provider for the API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiService(apiClient);
});

// Create a FutureProvider that can be called to fetch results
final resultProvider = FutureProvider.family<ResultModel, String>((ref, rollNumber) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchResult(rollNumber);
});

class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  /// Fetch Public Workspaces from the Spring Boot API
  Future<List<dynamic>> fetchPublicWorkspaces() async {
    try {
      final response = await _apiClient.client.get('/workspaces/public');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load workspaces');
      }
    } on DioException catch (e) {
      // The centralized error handler in ApiClient attached a friendly message
      throw Exception(e.error ?? 'Error fetching workspaces');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch JSONB Dataset Records from the Spring Boot API
  Future<List<dynamic>> fetchDatasetRecords(String datasetId) async {
    try {
      final response = await _apiClient.client.get('/datasets/$datasetId/records');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load records');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching records');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Upload CSV to Spring Boot API
  Future<bool> uploadCsv(String datasetId, String fileName, List<int> fileBytes) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.client.post(
        '/datasets/$datasetId/upload-csv',
        data: formData,
      );
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      developer.log('Error uploading CSV: ${e.error}');
      return false;
    } catch (e) {
      developer.log('Unexpected error uploading CSV: $e');
      return false;
    }
  }

  // MOCK DATA: For UI building purposes
  Future<ResultModel> fetchResult(String rollNumber) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network latency

    if (rollNumber.isEmpty) {
      throw Exception('Please enter a valid roll number.');
    }

    if (rollNumber == '0000') {
      throw Exception('Result not found for this Roll Number.');
    }

    // Mock JSON response
    final mockJsonResponse = {
      'studentName': 'Alex Johnson',
      'rollNumber': rollNumber,
      'courseName': 'B.Tech Computer Science',
      'semester': 'Semester 6',
      'status': 'PASS',
      'cgpa': 8.7,
      'subjects': [
        {'subjectCode': 'CS301', 'name': 'Data Structures', 'internalMarks': 25, 'externalMarks': 60, 'marksObtained': 85, 'totalMarks': 100, 'grade': 'A', 'credits': 4},
        {'subjectCode': 'CS302', 'name': 'Algorithms', 'internalMarks': 28, 'externalMarks': 64, 'marksObtained': 92, 'totalMarks': 100, 'grade': 'A+', 'credits': 4},
        {'subjectCode': 'CS303', 'name': 'Database Systems', 'internalMarks': 20, 'externalMarks': 58, 'marksObtained': 78, 'totalMarks': 100, 'grade': 'B+', 'credits': 3},
        {'subjectCode': 'CS304', 'name': 'Operating Systems', 'internalMarks': 26, 'externalMarks': 62, 'marksObtained': 88, 'totalMarks': 100, 'grade': 'A', 'credits': 3},
      ]
    };

    return ResultModel.fromJson(mockJsonResponse);
  }
}
