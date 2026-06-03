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

  /// Fetch Datasets for a workspace
  Future<List<dynamic>> fetchDatasets(String workspaceId, {String? workspaceToken}) async {
    try {
      final options = Options(
        headers: workspaceToken != null ? {'Authorization': 'Workspace $workspaceToken'} : null,
      );
      final response = await _apiClient.client.get('/workspaces/$workspaceId/datasets', options: options);
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load datasets');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching datasets');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Workspaces by Domain
  Future<List<dynamic>> fetchWorkspacesByDomain(String domainType) async {
    try {
      final response = await _apiClient.client.get(
        '/workspaces',
        queryParameters: {
          'domainType': domainType,
          'visibility': 'PUBLIC',
        },
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load workspaces');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching workspaces');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Published Datasets for a workspace
  Future<List<dynamic>> fetchPublishedDatasets(String workspaceId) async {
    try {
      final response = await _apiClient.client.get(
        '/workspaces/$workspaceId/datasets',
        queryParameters: {'status': 'PUBLISHED'},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load published datasets');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching published datasets');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch JSONB Dataset Records from the Spring Boot API
  Future<List<dynamic>> fetchDatasetRecords(String datasetId, {int page = 0, int size = 50}) async {
    try {
      final response = await _apiClient.client.get(
        '/datasets/$datasetId/records',
        queryParameters: {'page': page, 'size': size},
      );
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

  /// Fetch a single Dataset Record
  Future<Map<String, dynamic>> getDatasetRecord(String recordId) async {
    try {
      final response = await _apiClient.client.get('/records/$recordId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load record');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error fetching record');
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

  /// Upload PDF to Spring Boot API
  Future<String?> uploadPdf(String datasetId, String fileName, List<int> fileBytes) async {
    try {
      final formData = FormData.fromMap({
        'datasetId': datasetId,
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.client.post(
        '/pdf/import',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return response.data['importJobId'] as String;
      }
      return null;
    } on DioException catch (e) {
      developer.log('Error uploading PDF: ${e.error}');
      return null;
    } catch (e) {
      developer.log('Unexpected error uploading PDF: $e');
      return null;
    }
  }

  /// Check PDF Import Job Status
  Future<Map<String, dynamic>?> checkPdfImportJob(String jobId) async {
    try {
      final response = await _apiClient.client.get('/pdf/import/$jobId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error checking PDF job status: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> lookupRecord(String datasetId, String? rollNumber, String? dateOfBirth, {String? workspaceToken}) async {
    try {
      final queryParams = <String, String>{};
      if (rollNumber != null && rollNumber.isNotEmpty) queryParams['rollNumber'] = rollNumber;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) queryParams['dateOfBirth'] = dateOfBirth;

      final options = Options(
        headers: workspaceToken != null ? {'Authorization': 'Workspace $workspaceToken'} : null,
      );

      final response = await _apiClient.client.get(
        '/datasets/$datasetId/records/lookup',
        queryParameters: queryParams,
        options: options,
      );
      
      if (response.statusCode == 200) {
        // The API returns RecordResponse where data is the JSONB
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to lookup record');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('No result found for the provided details');
      } else if (e.response?.statusCode == 403) {
        throw Exception('This result is private. Contact your institution.');
      }
      throw Exception(e.response?.data?['message'] ?? 'Error looking up result');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update Dataset Record (Merge JSONB data)
  Future<Map<String, dynamic>> updateDatasetRecord(
    String datasetId,
    String recordId,
    Map<String, dynamic> data,
    int version,
  ) async {
    try {
      final response = await _apiClient.client.put(
        '/records/$recordId',
        data: {
          'data': data,
          'version': version,
        },
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update record');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Conflict: Record was modified by someone else.');
      }
      throw Exception(e.response?.data?['message'] ?? 'Error updating record');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
