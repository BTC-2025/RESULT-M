import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_environment.dart';
import '../core/storage/secure_storage.dart';

String _defaultApiBaseUrl() {
  const configuredUrl = AppEnvironment.apiBaseUrl;
  if (configuredUrl.isNotEmpty) return configuredUrl;
  if (kReleaseMode) {
    throw StateError('API_BASE_URL must be set for release builds.');
  }
  return Platform.isAndroid
      ? 'http://10.182.157.123:8080/api/v1' // Current Host IP (works for Emulator & Physical Device)
      : 'http://localhost:8080/api/v1';
}

class MessageService {
  final SecureStorage _secureStorage = SecureStorage();
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _defaultApiBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  MessageService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<dynamic>> getInbox() async {
    try {
      final response = await _dio.get('/messages/inbox');
      return response.data as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print('Error fetching inbox: $e');
      return [];
    }
  }

  Future<int> getGlobalUnreadCount() async {
    try {
      final response = await _dio.get('/messages/unread-count');
      return response.data as int;
    } catch (e) {
      if (kDebugMode) print('Error fetching unread count: $e');
      return 0;
    }
  }

  Future<List<dynamic>> getConversationHistory(String userId) async {
    try {
      final response = await _dio.get('/messages/$userId');
      return response.data as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print('Error fetching conversation: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String userId, String content) async {
    try {
      final response = await _dio.post('/messages/$userId', data: {'content': content});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('Error sending message: $e');
      return null;
    }
  }
}
