import 'dart:developer' as developer;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

// Create a Riverpod provider for the API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiService(apiClient);
});

class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  String get baseUrl => _apiClient.client.options.baseUrl;
  Future<Map<String, dynamic>> fetchHomeFeed({
    String? cursor,
    int size = 20,
    Iterable<String> interests = const [],
    Iterable<String> followingWorkspaceIds = const [],
  }) async {
    try {
      final queryParams = <String, dynamic>{'size': size};
      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }
      final cleanInterests = interests
          .map((interest) => interest.trim())
          .where((interest) => interest.isNotEmpty)
          .toSet()
          .toList();
      final cleanFollowingWorkspaceIds = followingWorkspaceIds
          .map((workspaceId) => workspaceId.trim())
          .where((workspaceId) => workspaceId.isNotEmpty)
          .toSet()
          .toList();
      if (cleanInterests.isNotEmpty) {
        queryParams['interests'] = cleanInterests;
      }
      if (cleanFollowingWorkspaceIds.isNotEmpty) {
        queryParams['followingWorkspaceIds'] = cleanFollowingWorkspaceIds;
      }
      final response = await _apiClient.client.get(
        '/feed',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to load home feed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching home feed');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserFeed({
    required String userId,
    String? cursor,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'size': size};
      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }
      final response = await _apiClient.client.get(
        '/feed/user/$userId',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to load user feed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching user feed');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> createFeedPost(FormData formData) async {
    try {
      final response = await _apiClient.client.post(
        '/posts',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      if (response.statusCode == 201 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to create post');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error creating post');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPostInteractions(String postId) async {
    try {
      final response = await _apiClient.client.get(
        '/posts/$postId/interactions',
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to load post interactions');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching post interactions');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> likeFeedPost(String postId) async {
    return _postInteractionMutation('/posts/$postId/like');
  }

  Future<Map<String, dynamic>> unlikeFeedPost(String postId) async {
    return _deleteInteractionMutation('/posts/$postId/like');
  }

  Future<Map<String, dynamic>> bookmarkFeedPost(String postId) async {
    return _postInteractionMutation('/posts/$postId/bookmark');
  }

  Future<Map<String, dynamic>> removeFeedPostBookmark(String postId) async {
    return _deleteInteractionMutation('/posts/$postId/bookmark');
  }

  Future<Map<String, dynamic>> bookmarkComplaint(String complaintId) async {
    final response = await _apiClient.client.post(
      '/complaints/$complaintId/bookmark',
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> removeComplaintBookmark(
    String complaintId,
  ) async {
    final response = await _apiClient.client.delete(
      '/complaints/$complaintId/bookmark',
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> fetchSavedFeedItems() async {
    final response = await _apiClient.client.get('/feed/saved');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> fetchFeedPostComments(String postId) async {
    try {
      final response = await _apiClient.client.get('/posts/$postId/comments');
      if (response.statusCode == 200 && response.data is List) {
        return response.data as List<dynamic>;
      }
      throw Exception('Failed to load post comments');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching post comments');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> addFeedPostComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final response = await _apiClient.client.post(
        '/posts/$postId/comments',
        data: {'content': content, 'parentCommentId': ?parentCommentId},
      );
      if (response.statusCode == 201 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to post comment');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error posting comment');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> likeFeedPostComment(String commentId) async {
    try {
      final response = await _apiClient.client.post(
        '/posts/comments/$commentId/like',
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to like comment');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error liking comment');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> unlikeFeedPostComment(String commentId) async {
    try {
      final response = await _apiClient.client.delete(
        '/posts/comments/$commentId/like',
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to unlike comment');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error unliking comment');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> _postInteractionMutation(String path) async {
    try {
      final response = await _apiClient.client.post(path);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Post interaction failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error updating post interaction');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> _deleteInteractionMutation(String path) async {
    try {
      final response = await _apiClient.client.delete(path);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Post interaction failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error updating post interaction');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  

  

  

  

  

  

  

  

  

  

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic> && data['content'] is List<dynamic>) {
      return data['content'] as List<dynamic>;
    }
    throw Exception('Unexpected response format');
  }

  Future<Map<String, dynamic>> createWorkspace(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.client.post('/workspaces', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to create workspace');
    } on DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map && resData['message'] != null) {
        throw Exception(resData['message'].toString());
      }
      throw Exception(e.message ?? 'Error creating workspace');
    }
  }

  Future<Map<String, dynamic>> fetchWorkspace(String workspaceId) async {

    try {
      final response = await _apiClient.client.get('/workspaces/$workspaceId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load workspace');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching workspace');
    }
  }

  Future<List<dynamic>> fetchWorkspaceMembers(String workspaceId) async {
    try {
      final response = await _apiClient.client.get(
        '/workspaces/$workspaceId/members',
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception('Failed to load workspace members');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching workspace members');
    }
  }

  Future<Map<String, dynamic>> inviteWorkspaceMember(
    String workspaceId,
    String email,
    String role,
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/workspaces/$workspaceId/invite',
        data: {'email': email, 'role': role},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to invite member');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error inviting member');
    }
  }

  Future<void> updateWorkspaceMemberRole(String memberId, String role) async {
    try {
      final response = await _apiClient.client.patch(
        '/members/$memberId/role',
        queryParameters: {'newRole': role},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update member role');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error updating member role');
    }
  }

  Future<void> removeWorkspaceMember(String memberId) async {
    try {
      final response = await _apiClient.client.delete('/members/$memberId');
      if (response.statusCode != 204) {
        throw Exception('Failed to remove member');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error removing member');
    }
  }

  Future<Map<String, dynamic>> regenerateWorkspaceCode(
    String workspaceId,
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/workspaces/$workspaceId/regenerate-code',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to regenerate access code');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error regenerating access code');
    }
  }

  Future<Map<String, dynamic>> fetchGlobalAnalytics() async {
    try {
      final response = await _apiClient.client.get('/analytics/global');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load analytics');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching analytics');
    }
  }

  /// Fetch dataset metadata (schema: search fields, display fields, access type)
  Future<Map<String, dynamic>> fetchDatasetMeta(String datasetId) async {
    try {
      final response = await _apiClient.client.get('/datasets/$datasetId/meta');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load dataset meta');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching dataset meta');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  

  Future<List<dynamic>> fetchMyWorkspaces({int page = 0, int size = 50}) async {
    try {
      final response = await _apiClient.client.get(
        '/workspaces/my',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Failed to load workspaces');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching workspaces');
    }
  }

  Future<Map<String, dynamic>> createDataset(
    String workspaceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/workspaces/$workspaceId/datasets',
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to create dataset');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error creating dataset');
    }
  }

  /// Fetch Public Workspaces from the Spring Boot API
  Future<List<dynamic>> fetchPublicWorkspaces({String? domainType}) async {
    try {
      final queryParams = <String, dynamic>{'size': 50};
      if (domainType != null && domainType != 'All') {
        queryParams['domainType'] = domainType;
      }
      final response = await _apiClient.client.get(
        '/workspaces/public',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final workspaces = _extractList(response.data);
        return workspaces;
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

  Future<List<dynamic>> globalSearch(String query, {int size = 20}) async {
    try {
      final response = await _apiClient.client.get(
        '/search',
        queryParameters: {'q': query, 'size': size},
      );
      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>? ?? [];
        return results;
      }
      throw Exception('Search service returned ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error during global search');
    }
  }

  Future<List<dynamic>> searchUsers(String query, {int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.client.get(
        '/users/search',
        queryParameters: {'q': query, 'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map && response.data['content'] is List) {
          return response.data['content'] as List<dynamic>;
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error searching users');
    }
  }

  /// Fetch Datasets for a workspace
  Future<List<dynamic>> fetchDatasets(
    String workspaceId, {
    String? workspaceToken,
  }) async {

    try {
      final options = Options(
        headers: workspaceToken != null
            ? {'Authorization': 'Workspace $workspaceToken'}
            : null,
      );
      final response = await _apiClient.client.get(
        '/workspaces/$workspaceId/datasets',
        options: options,
      );
      if (response.statusCode == 200) {
        final datasets = _extractList(response.data);
        if (datasets.isEmpty) {
        }
        return datasets;
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
        '/workspaces/public',
        queryParameters: {'domainType': domainType},
      );
      if (response.statusCode == 200) {
        final workspaces = _extractList(response.data);
        if (workspaces.isEmpty) {
        }
        return workspaces;
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
        final datasets = _extractList(response.data);
        if (datasets.isEmpty) {
        }
        return datasets;
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
  Future<List<dynamic>> fetchDatasetRecords(
    String datasetId, {
    int page = 0,
    int size = 50,
    String? workspaceToken,
    String? query,
  }) async {
    try {

      final options = Options(
        headers: workspaceToken != null
            ? {'Authorization': 'Workspace $workspaceToken'}
            : null,
      );
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      final response = await _apiClient.client.get(
        '/datasets/$datasetId/records',
        queryParameters: queryParams,
        options: options,
      );
      if (response.statusCode == 200) {
        return _extractList(response.data);
      } else {
        throw Exception('Failed to load records');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching records');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Stream<String>> streamDatasetRecordEvents(
    String datasetId, {
    String? workspaceToken,
  }) async {
    final options = Options(
      responseType: ResponseType.stream,
      headers: workspaceToken != null
          ? {
              'Authorization': 'Workspace $workspaceToken',
              'Accept': 'text/event-stream',
            }
          : {'Accept': 'text/event-stream'},
    );

    final response = await _apiClient.client.get<ResponseBody>(
      '/datasets/$datasetId/records/stream',
      options: options,
    );

    final stream = response.data?.stream;
    if (stream == null) {
      throw Exception('Dataset event stream was empty');
    }

    return stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.startsWith('data:'))
        .map((line) => line.substring(5).trim())
        .where((payload) => payload.isNotEmpty);
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
  Future<bool> uploadCsv(
    String datasetId,
    String fileName,
    List<int> fileBytes, {
    String? recordKeyColumn,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await _apiClient.client.post(
        '/datasets/$datasetId/upload-csv',
        data: formData,
        queryParameters: {
          if (recordKeyColumn != null && recordKeyColumn.isNotEmpty)
            'recordKeyColumn': recordKeyColumn,
        },
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
  Future<String?> uploadPdf(
    String datasetId,
    String fileName,
    List<int> fileBytes,
  ) async {
    try {
      final formData = FormData.fromMap({
        'datasetId': datasetId,
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
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

  Future<Map<String, dynamic>> lookupRecord(
    String datasetId, {
    String? rollNumber,
    String? dateOfBirth,
    String? workspaceToken,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (rollNumber != null && rollNumber.isNotEmpty) {
        queryParams['rollNumber'] = rollNumber;
      }
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        queryParams['dateOfBirth'] = dateOfBirth;
      }

      final options = Options(
        headers: workspaceToken != null
            ? {'Authorization': 'Workspace $workspaceToken'}
            : null,
      );

      final response = await _apiClient.client.get(
        '/datasets/$datasetId/records/lookup',
        queryParameters: queryParams,
        options: options,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to lookup record');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.response?.data?['error'];
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        throw Exception(msg ?? 'No result found for the provided details');
      } else if (e.response?.statusCode == 403) {
        throw Exception('This result is private. Contact your institution.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('No result found. Please check your details and try again.');
      }
      throw Exception(msg ?? 'Error looking up result');
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<dynamic>> searchRecords(String datasetId, Map<String, dynamic> queryParams) async {
    try {
      final response = await _apiClient.client.get('/datasets/$datasetId/records/search', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception('Failed to search records');
    } catch (e) {
      throw Exception('Error searching records: $e');
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
        data: {'data': data, 'version': version},
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
  

  // ---------------------------------------------------------------------------
  // COMPLAINT BOX PILLAR
  // ---------------------------------------------------------------------------

  /// Fetch Complaints (Paginated, Sorted, Filtered)
  Future<List<dynamic>> fetchComplaints({
    String sort = 'trending',
    String? category,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sort': sort,
        'page': page,
        'size': size,
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.client.get(
        '/complaints',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        // Spring Data JPA Page object returns data in 'content' array
        return response.data['content'] as List<dynamic>;
      } else {
        throw Exception('Failed to load complaints');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching complaints');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create a Complaint (Multipart)
  Future<Map<String, dynamic>> createComplaint(FormData formData) async {
    try {
      final response = await _apiClient.client.post(
        '/complaints',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create complaint');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error creating complaint');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Cast a Vote on a Complaint
  Future<void> castComplaintVote(String complaintId, String voteType) async {
    try {
      final response = await _apiClient.client.post(
        '/complaints/$complaintId/vote',
        data: {'voteType': voteType},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to cast vote');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error casting vote');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Flag a Complaint
  Future<void> flagComplaint(String complaintId) async {
    try {
      final response = await _apiClient.client.post(
        '/complaints/$complaintId/flag',
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to flag complaint');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error flagging complaint');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Comments for a Complaint
  Future<List<dynamic>> fetchComments(String complaintId) async {
    try {
      final response = await _apiClient.client.get(
        '/complaints/$complaintId/comments',
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load comments');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching comments');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Post a Comment to a Complaint
  Future<Map<String, dynamic>> postComment(
    String complaintId,
    String content,
    bool isAnonymous,
    String? parentCommentId,
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/complaints/$complaintId/comments',
        queryParameters: {
          'content': content,
          'isAnonymous': isAnonymous,
          'parentCommentId': ?parentCommentId,
        },
      );
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to post comment');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error posting comment');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> likeComplaintComment(String commentId) async {
    try {
      final response = await _apiClient.client.post(
        '/complaints/comments/$commentId/like',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to like comment');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error liking comment');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> unlikeComplaintComment(String commentId) async {
    try {
      final response = await _apiClient.client.delete(
        '/complaints/comments/$commentId/like',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to unlike comment');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error unliking comment');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }



  // ---------------------------------------------------------------------------
  // VOTING HUB PILLAR
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> fetchVoteBoxes({int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.client.get(
        '/votes',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        final votes = response.data['content'] as List<dynamic>? ?? [];
        return votes;
      } else {
        throw Exception('Failed to load vote boxes');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching vote boxes');
    }
  }

  Future<Map<String, dynamic>> fetchVoteBoxDetail(String voteBoxId) async {
    try {
      final response = await _apiClient.client.get('/votes/$voteBoxId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load vote box detail');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching vote box detail');
    }
  }

  Future<void> castVote(
    String voteBoxId,
    String optionId,
    String? deviceFingerprint,
  ) async {
    try {
      final data = {'optionId': optionId};
      if (deviceFingerprint != null) {
        data['deviceFingerprint'] = deviceFingerprint;
      }
      final response = await _apiClient.client.post(
        '/votes/$voteBoxId/cast',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to cast vote');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error casting vote');
    }
  }

  Future<List<dynamic>> fetchVoteResults(String voteBoxId) async {
    try {
      final response = await _apiClient.client.get('/votes/$voteBoxId/results');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch vote results');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error fetching vote results');
    }
  }

  Future<Map<String, dynamic>> createVoteBox(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/votes',
        data: requestData,
      );
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create vote box');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error creating vote box');
    }
  }

  Future<String> unlockVoteBox(String voteBoxId, String accessCode) async {
    try {
      final response = await _apiClient.client.post(
        '/votes/$voteBoxId/unlock',
        data: {'accessCode': accessCode},
      );
      if (response.statusCode == 200) {
        return response.data['token'] as String;
      } else {
        throw Exception('Failed to unlock vote box');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error unlocking vote box');
    }
  }

  /// Create Dataset Record manually
  Future<Map<String, dynamic>> createDatasetRecord(
    String datasetId,
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/datasets/$datasetId/records',
        data: requestBody,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create record');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error creating record');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete Dataset Record
  Future<void> deleteDatasetRecord(String recordId) async {
    try {
      final response = await _apiClient.client.delete('/records/$recordId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete record');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error deleting record');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update Dataset Metadata (name, description)
  Future<Map<String, dynamic>> updateDatasetMetadata(
    String datasetId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.client.patch(
        '/datasets/$datasetId',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update dataset');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Error updating dataset');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete a Dataset permanently
  Future<void> deleteDataset(String datasetId) async {
    try {
      final response =
          await _apiClient.client.delete('/datasets/$datasetId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete dataset');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Error deleting dataset');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

