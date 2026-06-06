import 'dart:developer' as developer;
import 'dart:convert';
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
final resultProvider = FutureProvider.family<ResultModel, String>((
  ref,
  rollNumber,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchResult(rollNumber);
});

class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  bool _isBackendOffline(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  String _nowMinus(Duration duration) {
    return DateTime.now().subtract(duration).toIso8601String();
  }

  String _nowPlus(Duration duration) {
    return DateTime.now().add(duration).toIso8601String();
  }

  List<dynamic> _offlinePublicWorkspaces() {
    return [
      {
        'id': '11111111-1111-4111-8111-111111111111',
        'name': 'Anna University Results Desk',
        'description': 'Semester 6 marks and revaluation updates',
        'domainType': 'EDUCATION',
      },
      {
        'id': '22222222-2222-4222-8222-222222222222',
        'name': 'City Cricket Finals',
        'description': 'Live scores, toss notes, and final standings',
        'domainType': 'SPORTS',
      },
      {
        'id': '33333333-3333-4333-8333-333333333333',
        'name': 'Election Live Desk',
        'description': 'Seat count, leads, and constituency updates',
        'domainType': 'POLITICS',
      },
      {
        'id': '44444444-4444-4444-8444-444444444444',
        'name': 'Market Watchroom',
        'description': 'Nifty, Sensex, and sector movement snapshots',
        'domainType': 'FINANCE',
      },
      {
        'id': '55555555-5555-4555-8555-555555555555',
        'name': 'Entertainment Awards Desk',
        'description': 'Awards, box office, and live winner boards',
        'domainType': 'ENTERTAINMENT',
      },
    ];
  }

  List<dynamic> _offlineWorkspacesForDomain(String domainType) {
    var normalized = domainType.toUpperCase();
    normalized = switch (normalized) {
      'SPORT' => 'SPORTS',
      'ACADEMIC' => 'EDUCATION',
      'ELECTION' => 'POLITICS',
      'GOVERNMENT' || 'LAW' || 'TECH' || 'HYPERLOCAL' => 'CUSTOM',
      _ => normalized,
    };
    final workspaces = _offlinePublicWorkspaces();
    if (normalized == 'ALL') return workspaces;
    if (normalized == 'CUSTOM') return workspaces;
    return workspaces
        .where((workspace) =>
            workspace['domainType']?.toString().toUpperCase() == normalized)
        .toList();
  }

  Map<String, dynamic>? _offlineWorkspaceById(String workspaceId) {
    for (final workspace in _offlinePublicWorkspaces()) {
      if (workspace['id'] == workspaceId) {
        return Map<String, dynamic>.from(workspace as Map);
      }
    }
    return null;
  }

  List<dynamic> _offlineSearchResults(String query) {
    final normalized = query.trim().toLowerCase();
    final results = <Map<String, dynamic>>[
      {
        'id': '11111111-1111-4111-8111-111111111111',
        'type': 'WORKSPACE',
        'title': 'Anna University Results Desk',
        'description': 'Semester results and student lookup',
        'domainType': 'EDUCATION',
      },
      {
        'id': 'anna_univ_demo',
        'type': 'DATASET',
        'title': 'Anna University B.E / B.Tech Semester Results',
        'description': 'Search by register number',
        'domainType': 'EDUCATION',
      },
      {
        'id': '22222222-2222-4222-8222-222222222222',
        'type': 'WORKSPACE',
        'title': 'City Cricket Finals',
        'description': 'Live scores and points table',
        'domainType': 'SPORTS',
      },
      {
        'id': '33333333-3333-4333-8333-333333333333',
        'type': 'WORKSPACE',
        'title': 'Election Live Desk',
        'description': 'Live counting, leads, and seat share',
        'domainType': 'POLITICS',
      },
      {
        'id': 'offline-vote-1',
        'type': 'VOTEBOX',
        'title': 'Which result alert should be pinned first?',
        'description': 'Community poll',
        'domainType': 'POLL',
      },
    ];

    if (normalized.isEmpty) return results;
    return results.where((result) {
      final title = result['title']?.toString().toLowerCase() ?? '';
      final description =
          result['description']?.toString().toLowerCase() ?? '';
      final domain = result['domainType']?.toString().toLowerCase() ?? '';
      return title.contains(normalized) ||
          description.contains(normalized) ||
          domain.contains(normalized);
    }).toList();
  }

  List<dynamic> _offlineComplaints() {
    return [
      {
        'id': 'offline-complaint-1',
        'creatorId': null,
        'category': 'Civic',
        'title': 'Street light outage near bus stand',
        'description':
            'Multiple lights are off on the east side road. Evening foot traffic is high and residents have requested a quick repair.',
        'mediaUrls': [],
        'latitude': null,
        'longitude': null,
        'locationName': 'Gandhi Road, Ward 12',
        'status': 'OPEN',
        'isAnonymous': true,
        'flagCount': 0,
        'upvotes': 42,
        'downvotes': 3,
        'netScore': 39,
        'createdAt': _nowMinus(const Duration(hours: 2)),
        'updatedAt': _nowMinus(const Duration(hours: 1)),
        'hasUserVoted': null,
        'commentCount': 11,
      },
      {
        'id': 'offline-complaint-2',
        'creatorId': null,
        'category': 'Campus',
        'title': 'Exam hall seating list not visible',
        'description':
            'Students are asking for the seating plan to be published earlier and pinned at the main entry gate.',
        'mediaUrls': [],
        'latitude': null,
        'longitude': null,
        'locationName': 'Engineering Block A',
        'status': 'UNDER_REVIEW',
        'isAnonymous': false,
        'flagCount': 0,
        'upvotes': 28,
        'downvotes': 2,
        'netScore': 26,
        'createdAt': _nowMinus(const Duration(hours: 5)),
        'updatedAt': _nowMinus(const Duration(hours: 3)),
        'hasUserVoted': 'UP',
        'commentCount': 7,
      },
    ];
  }

  List<dynamic> _offlineVoteBoxes() {
    return [
      {
        'id': 'offline-vote-1',
        'title': 'Which result alert should be pinned first?',
        'description':
            'Choose the most useful alert for the home live desk this week.',
        'visibility': 'PUBLIC',
        'allowAnonymous': true,
        'endsAt': _nowPlus(const Duration(days: 2)),
        'linkedWorkspaceId': null,
        'hideResultsUntilEnd': false,
        'totalVotes': 128,
        'createdAt': _nowMinus(const Duration(days: 1)),
        'hasVoted': false,
        'selectedOptionId': null,
        'options': [
          {'id': 'opt-1', 'optionText': 'Exam results', 'voteCount': 61},
          {'id': 'opt-2', 'optionText': 'Sports scores', 'voteCount': 39},
          {'id': 'opt-3', 'optionText': 'Market alerts', 'voteCount': 28},
        ],
      },
      {
        'id': 'offline-vote-2',
        'title': 'Preferred complaint sorting for first view',
        'description': 'Help tune the community feed default order.',
        'visibility': 'PUBLIC',
        'allowAnonymous': true,
        'endsAt': _nowPlus(const Duration(hours: 18)),
        'linkedWorkspaceId': null,
        'hideResultsUntilEnd': false,
        'totalVotes': 76,
        'createdAt': _nowMinus(const Duration(hours: 10)),
        'hasVoted': true,
        'selectedOptionId': 'opt-4',
        'options': [
          {'id': 'opt-4', 'optionText': 'Trending', 'voteCount': 43},
          {'id': 'opt-5', 'optionText': 'Newest', 'voteCount': 21},
          {'id': 'opt-6', 'optionText': 'Top score', 'voteCount': 12},
        ],
      },
    ];
  }

  List<dynamic> _offlineDatasetsForWorkspace(String workspaceId) {
    if (workspaceId == 'university' ||
        workspaceId == '11111111-1111-4111-8111-111111111111') {
      return [
        {
          'id': 'anna_univ_demo',
          'name': 'Anna University B.E / B.Tech Semester Results',
          'description': 'Demo dataset for student result lookup',
          'status': 'PUBLISHED',
          'domainType': 'EDUCATION',
        },
      ];
    }
    if (workspaceId == '22222222-2222-4222-8222-222222222222') {
      return [
        {
          'id': 'sports_demo',
          'name': 'City Cricket Finals Live Scoreboard',
          'description': 'Live match scores and player stats',
          'status': 'PUBLISHED',
          'domainType': 'SPORTS',
        },
      ];
    }
    if (workspaceId == '33333333-3333-4333-8333-333333333333') {
      return [
        {
          'id': 'politics_demo',
          'name': 'Election Counting Live Board',
          'description': 'Live seats, leads, and vote share',
          'status': 'PUBLISHED',
          'domainType': 'POLITICS',
        },
      ];
    }
    if (workspaceId == '44444444-4444-4444-8444-444444444444') {
      return [
        {
          'id': 'finance_demo',
          'name': 'Market Closing Snapshot',
          'description': 'Index and sector movement',
          'status': 'PUBLISHED',
          'domainType': 'FINANCE',
        },
      ];
    }
    if (workspaceId == '55555555-5555-4555-8555-555555555555') {
      return [
        {
          'id': 'entertainment_demo',
          'name': 'Awards and Box Office Board',
          'description': 'Live awards and weekly collection rankings',
          'status': 'PUBLISHED',
          'domainType': 'ENTERTAINMENT',
        },
      ];
    }
    if (workspaceId == 'upsc' || workspaceId == 'boards') {
      return [
        {
          'id': '${workspaceId}_demo',
          'name': 'Published Result Dataset',
          'description': 'Demo dataset for result lookup',
          'status': 'PUBLISHED',
        },
      ];
    }
    return [];
  }

  Map<String, dynamic>? _offlineRecordForDataset(
    String datasetId,
    String? rollNumber,
  ) {
    final normalizedRoll = rollNumber?.trim();
    if (datasetId == 'anna_univ_demo' || datasetId == 'univ_hub') {
      return {
        'studentName': 'Demo Student',
        'registerNumber': normalizedRoll?.isNotEmpty == true
            ? normalizedRoll
            : 'AU2026CS001',
        'institution': 'Anna University',
        'course': 'B.E Computer Science and Engineering',
        'semester': 'Semester 6',
        'resultStatus': 'PASS',
        'gpa': '8.42',
        'grade': 'First Class',
        'publishedAt': '2026-06-01',
      };
    }
    if (datasetId == 'school_results' || datasetId == 'school_hub') {
      return {
        'studentName': 'Demo High School Student',
        'roll_no': normalizedRoll?.isNotEmpty == true ? normalizedRoll : '1234567',
        'dob': '15/08/2008',
        'school': 'St. John\'s High School',
        'result': 'PASS',
      };
    }
    if (datasetId.endsWith('_demo')) {
      return {
        'candidateName': 'Demo Candidate',
        'rollNumber': normalizedRoll?.isNotEmpty == true
            ? normalizedRoll
            : 'RH2026001',
        'status': 'QUALIFIED',
        'rank': '128',
        'publishedAt': '2026-06-01',
      };
    }
    return null;
  }

  List<dynamic> _offlineRecordsForDataset(String datasetId, {String? query}) {
    final singleRecord = _offlineRecordForDataset(datasetId, query);
    if (singleRecord != null) {
      return [
        {
          'id': '${datasetId}_record_1',
          'recordTitle': singleRecord['studentName'] ??
              singleRecord['candidateName'] ??
              singleRecord['team'] ??
              singleRecord['party'] ??
              'Demo Result',
          'recordKey': singleRecord['registerNumber'] ??
              singleRecord['rollNumber'] ??
              singleRecord['matchId'] ??
              singleRecord['constituency'] ??
              datasetId,
          'data': singleRecord,
        },
      ];
    }

    final rows = switch (datasetId) {
      'sports_demo' => [
          {
            'teamA': 'Chennai Kings',
            'teamB': 'Mumbai Strikers',
            'scoreA': '186/4',
            'scoreB': '142/6',
            'status': 'LIVE - Over 15.2',
            'venue': 'City Stadium',
          },
          {
            'teamA': 'Royal Challengers',
            'teamB': 'Delhi Capitals',
            'scoreA': 'Yet to bat',
            'scoreB': '98/2',
            'status': 'LIVE - Over 9.4',
            'venue': 'South Ground',
          },
        ],
      'politics_demo' => [
          {
            'constituency': 'Central Ward',
            'leadingParty': 'People First',
            'leadMargin': '12,420',
            'counted': 'Round 8 of 12',
            'status': 'Counting',
          },
          {
            'constituency': 'North District',
            'leadingParty': 'United Front',
            'leadMargin': '4,118',
            'counted': 'Round 6 of 10',
            'status': 'Counting',
          },
        ],
      'finance_demo' => [
          {
            'index': 'NIFTY 50',
            'value': '24,512.20',
            'change': '+1.2%',
            'status': 'Market Closed',
          },
          {
            'index': 'SENSEX',
            'value': '80,234.10',
            'change': '+0.9%',
            'status': 'Market Closed',
          },
        ],
      'entertainment_demo' => [
          {
            'rank': '1',
            'title': 'Weekend Box Office India',
            'winner': 'Kalki 2898 AD',
            'collection': 'Rs 82 Cr',
          },
          {
            'rank': '2',
            'title': 'Music Top 50',
            'winner': 'Kesariya 2.0',
            'streams': '14.2M',
          },
        ],
      _ => <Map<String, dynamic>>[],
    };

    return rows.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final data = entry.value;
      return {
        'id': '${datasetId}_record_$index',
        'recordTitle': data['title'] ??
            data['teamA'] ??
            data['constituency'] ??
            data['index'] ??
            'Record $index',
        'recordKey': data['constituency'] ??
            data['index'] ??
            data['rank'] ??
            'REC-$index',
        'data': data,
      };
    }).toList();
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
      throw Exception(e.error ?? 'Error creating workspace');
    }
  }

  Future<Map<String, dynamic>> fetchWorkspace(String workspaceId) async {
    final offlineWorkspace = _offlineWorkspaceById(workspaceId);
    if (offlineWorkspace != null) {
      return offlineWorkspace;
    }

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
      final response = await _apiClient.client.get('/workspaces/public', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final workspaces = _extractList(response.data);
        if (workspaces.isEmpty && domainType != null) {
          return _offlineWorkspacesForDomain(domainType);
        }
        if (workspaces.isEmpty) return _offlinePublicWorkspaces();
        return workspaces;
      } else {
        throw Exception('Failed to load workspaces');
      }
    } on DioException catch (e) {
      if (_isBackendOffline(e)) {
        developer.log('Backend offline, using public workspace sample data.');
        return _offlinePublicWorkspaces();
      }
      // The centralized error handler in ApiClient attached a friendly message
      throw Exception(e.error ?? 'Error fetching workspaces');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<dynamic>> globalSearch(String query, {int size = 20}) async {
    try {
      final response = await _apiClient.client.get('/search', queryParameters: {'q': query, 'size': size});
      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>? ?? [];
        if (results.isEmpty) return _offlineSearchResults(query);
        return results;
      }
      return _offlineSearchResults(query);
    } on DioException catch (e) {
      if (_isBackendOffline(e) || e.response?.statusCode == 404) {
        return _offlineSearchResults(query);
      }
      throw Exception(e.error ?? 'Error during global search');
    }
  }

  /// Fetch Datasets for a workspace
  Future<List<dynamic>> fetchDatasets(
    String workspaceId, {
    String? workspaceToken,
  }) async {
    final offlineDatasets = _offlineDatasetsForWorkspace(workspaceId);
    if (offlineDatasets.isNotEmpty) {
      return offlineDatasets;
    }

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
          return _offlineDatasetsForWorkspace(workspaceId);
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
          return _offlineWorkspacesForDomain(domainType);
        }
        return workspaces;
      } else {
        throw Exception('Failed to load workspaces');
      }
    } on DioException catch (e) {
      final offlineWorkspaces = _offlineWorkspacesForDomain(domainType);
      if (offlineWorkspaces.isNotEmpty &&
          (_isBackendOffline(e) || e.response?.statusCode == 404)) {
        developer.log('Using sample workspaces for domain $domainType.');
        return offlineWorkspaces;
      }
      throw Exception(e.error ?? 'Error fetching workspaces');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch Published Datasets for a workspace
  Future<List<dynamic>> fetchPublishedDatasets(String workspaceId) async {
    final offlineDatasets = _offlineDatasetsForWorkspace(workspaceId);
    if (offlineDatasets.isNotEmpty) {
      return offlineDatasets;
    }

    try {
      final response = await _apiClient.client.get(
        '/workspaces/$workspaceId/datasets',
        queryParameters: {'status': 'PUBLISHED'},
      );
      if (response.statusCode == 200) {
        final datasets = _extractList(response.data);
        if (datasets.isEmpty) {
          return _offlineDatasetsForWorkspace(workspaceId);
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
      final offlineRecords = _offlineRecordsForDataset(datasetId, query: query);
      if (offlineRecords.isNotEmpty) {
        return offlineRecords;
      }

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
    String datasetId,
    String? rollNumber,
    String? dateOfBirth, {
    String? workspaceToken,
  }) async {
    try {
      final offlineRecord = _offlineRecordForDataset(datasetId, rollNumber);
      if (offlineRecord != null) {
        return offlineRecord;
      }

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
      throw Exception(
        e.response?.data?['message'] ?? 'Error looking up result',
      );
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
  Future<ResultModel> fetchResult(String rollNumber) async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simulate network latency

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
        {
          'subjectCode': 'CS301',
          'name': 'Data Structures',
          'internalMarks': 25,
          'externalMarks': 60,
          'marksObtained': 85,
          'totalMarks': 100,
          'grade': 'A',
          'credits': 4,
        },
        {
          'subjectCode': 'CS302',
          'name': 'Algorithms',
          'internalMarks': 28,
          'externalMarks': 64,
          'marksObtained': 92,
          'totalMarks': 100,
          'grade': 'A+',
          'credits': 4,
        },
        {
          'subjectCode': 'CS303',
          'name': 'Database Systems',
          'internalMarks': 20,
          'externalMarks': 58,
          'marksObtained': 78,
          'totalMarks': 100,
          'grade': 'B+',
          'credits': 3,
        },
        {
          'subjectCode': 'CS304',
          'name': 'Operating Systems',
          'internalMarks': 26,
          'externalMarks': 62,
          'marksObtained': 88,
          'totalMarks': 100,
          'grade': 'A',
          'credits': 3,
        },
      ],
    };

    return ResultModel.fromJson(mockJsonResponse);
  }

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
      if (_isBackendOffline(e)) {
        developer.log('Backend offline, using complaint sample data.');
        return _offlineComplaints();
      }
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
  ) async {
    try {
      final response = await _apiClient.client.post(
        '/complaints/$complaintId/comments',
        queryParameters: {'content': content, 'isAnonymous': isAnonymous},
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

  /// Update complaint moderation status. Requires an ADMIN backend JWT.
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    try {
      final response = await _apiClient.client.patch(
        '/complaints/$complaintId/status',
        queryParameters: {'status': status},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update complaint status');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Error updating complaint status');
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
        if (votes.isEmpty) return _offlineVoteBoxes();
        return votes;
      } else {
        throw Exception('Failed to load vote boxes');
      }
    } on DioException catch (e) {
      if (_isBackendOffline(e)) {
        developer.log('Backend offline, using vote box sample data.');
        return _offlineVoteBoxes();
      }
      throw Exception(e.error ?? 'Error fetching vote boxes');
    }
  }

  Future<Map<String, dynamic>> fetchVoteBoxDetail(String voteBoxId) async {
    final offlineVote = _offlineVoteBoxes().cast<Map<String, dynamic>?>()
        .firstWhere((vote) => vote?['id'] == voteBoxId, orElse: () => null);
    if (offlineVote != null) {
      return offlineVote;
    }

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


}
