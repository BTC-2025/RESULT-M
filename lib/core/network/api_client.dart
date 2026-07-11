import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_environment.dart';
import '../storage/secure_storage.dart';
import '../routing/app_router.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(SecureStorage());
});

String _defaultBaseUrl() {
  const configuredUrl = AppEnvironment.apiBaseUrl;
  if (configuredUrl.isNotEmpty) return configuredUrl;
  if (kReleaseMode) {
    throw StateError('API_BASE_URL must be set for release builds.');
  }
  return Platform.isAndroid
      ? 'http://10.24.37.123:8080/api/v1' // Current Host IP (works for Emulator & Physical Device)
      : 'http://localhost:8080/api/v1';
}

void _assertReleaseUrlIsSafe(String baseUrl) {
  if (!kReleaseMode) return;
  final uri = Uri.tryParse(baseUrl);
  if (uri == null || uri.scheme != 'https') {
    throw StateError('Release API_BASE_URL must be a valid HTTPS URL.');
  }
}

class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequestsQueue = [];

  ApiClient(this._secureStorage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: _defaultBaseUrl(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _assertReleaseUrlIsSafe(_dio.options.baseUrl);
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
    if (AppEnvironment.enableNetworkLogs && !kReleaseMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
      );
    }
  }

  Dio get client => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if this is a workspace specific request
    final path = options.path;
    if (path.startsWith('/auth/')) {
      return handler.next(options);
    }

    final workspaceMatch = RegExp(
      r'workspaces/([a-zA-Z0-9-]+)',
    ).firstMatch(path);

    if (workspaceMatch != null) {
      final workspaceId = workspaceMatch.group(1);
      if (workspaceId != null) {
        final workspaceToken = await _secureStorage.getWorkspaceToken(
          workspaceId,
        );
        if (workspaceToken != null && workspaceToken.isNotEmpty) {
          options.headers['Authorization'] = 'Workspace $workspaceToken';
          return handler.next(options);
        }
      }
    }

    final voteBoxMatch = RegExp(r'votes/([a-zA-Z0-9-]+)').firstMatch(path);
    if (voteBoxMatch != null) {
      final voteBoxId = voteBoxMatch.group(1);
      if (voteBoxId != null) {
        final voteBoxToken = await _secureStorage.getVoteBoxToken(voteBoxId);
        if (voteBoxToken != null && voteBoxToken.isNotEmpty) {
          options.headers['Authorization'] = 'Workspace $voteBoxToken';
          return handler.next(options);
        }
      }
    }

    // Fallback to regular user token if no workspace token was applied
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Guest-Id'] = await _secureStorage.getOrCreateGuestId();
    // Effective Data Compression for large JSON payloads
    if (options.data != null && options.data is Map && options.headers['Content-Type'] == 'application/json') {
      try {
        final rawData = jsonEncode(options.data);
        if (rawData.length > 1024) { // Compress if > 1KB
          final compressedData = gzip.encode(utf8.encode(rawData));
          options.data = compressedData;
          options.headers['Content-Encoding'] = 'gzip';
          options.headers['Content-Length'] = compressedData.length.toString();
        }
      } catch (_) {
        // Fallback to uncompressed if serialization fails
      }
    }

    return handler.next(options);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    // Check if the error is 401 Unauthorized
    if (e.response?.statusCode == 401) {
      // Check if it's a workspace token failure
      final authHeader = e.requestOptions.headers['Authorization'] as String?;
      if (authHeader != null && authHeader.startsWith('Workspace ')) {
        final path = e.requestOptions.path;
        final workspaceMatch = RegExp(
          r'workspaces/([a-zA-Z0-9-]+)',
        ).firstMatch(path);
        if (workspaceMatch != null) {
          final workspaceId = workspaceMatch.group(1);
          if (workspaceId != null) {
            await _secureStorage.deleteWorkspaceToken(workspaceId);
          }
        }
        final voteBoxMatch = RegExp(r'votes/([a-zA-Z0-9-]+)').firstMatch(path);
        if (voteBoxMatch != null) {
          final voteBoxId = voteBoxMatch.group(1);
          if (voteBoxId != null) {
            await _secureStorage.deleteVoteBoxToken(voteBoxId);
          }
        }
        return handler.next(e);
      }

      // Avoid infinite loop if the refresh token call itself fails
      if (e.requestOptions.path.contains('/auth/refresh')) {
        await _secureStorage.clearAll(); // Logout on refresh fail
        try { appRouter.go('/login'); } catch (_) {}
        return handler.next(e);
      }

      if (_isRefreshing) {
        // If already refreshing, queue the failed request
        _failedRequestsQueue.add({
          'options': e.requestOptions,
          'handler': handler,
        });
        return;
      }

      _isRefreshing = true;

      try {
        final newToken = await _refreshToken();
        if (newToken != null && newToken.isNotEmpty) {
          // Refresh succeeded, update original request
          e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          // Retry the original request
          final response = await _dio.fetch(e.requestOptions);
          handler.resolve(response);

          // Retry all queued requests
          _retryQueuedRequests(newToken);
          return;
        } else {
          // Token refresh failed, reject original request and flush queue
          await _secureStorage.clearAll();
          try { appRouter.go('/login'); } catch (_) {}
          _flushQueuedRequests(e);
        }
      } catch (refreshError) {
        await _secureStorage.clearAll();
        try { appRouter.go('/login'); } catch (_) {}
        _flushQueuedRequests(e);
      } finally {
        _isRefreshing = false;
      }
    }

    // Centralized Error Handling: Map to clean messages
    final customException = _handleDioException(e);
    return handler.next(customException);
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {'Authorization': null}),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final accessToken = data['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    await _secureStorage.saveToken(accessToken);

    final rotatedRefreshToken = data['refreshToken'] as String?;
    if (rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty) {
      await _secureStorage.saveRefreshToken(rotatedRefreshToken);
    }

    final userId = data['userId']?.toString();
    if (userId != null && userId.isNotEmpty) {
      await _secureStorage.saveUserId(userId);
    }

    return accessToken;
  }

  void _retryQueuedRequests(String newToken) {
    for (var request in _failedRequestsQueue) {
      final RequestOptions options = request['options'];
      final ErrorInterceptorHandler handler = request['handler'];
      options.headers['Authorization'] = 'Bearer $newToken';
      _dio
          .fetch(options)
          .then(
            (res) => handler.resolve(res),
            onError: (err) => handler.next(
              err is DioException
                  ? err
                  : DioException(requestOptions: options, error: err),
            ),
          );
    }
    _failedRequestsQueue.clear();
  }

  void _flushQueuedRequests(DioException error) {
    for (var request in _failedRequestsQueue) {
      final ErrorInterceptorHandler handler = request['handler'];
      handler.next(error);
    }
    _failedRequestsQueue.clear();
  }

  DioException _handleDioException(DioException error) {
    String message = 'An unexpected error occurred';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message =
            'Backend is taking too long to respond. Check the API server and network.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'];
        } else if (statusCode == 400) {
          message = 'Bad request. Please verify the provided data.';
        } else if (statusCode == 403) {
          message = 'Access forbidden. You do not have permission.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Internal server error. Please try again later.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request to API server was cancelled';
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        message = 'Network error. Please ensure you have an active connection.';
        break;
    }
    // Return a new DioException with the friendly message attached to the error property
    return error.copyWith(error: message);
  }
}
