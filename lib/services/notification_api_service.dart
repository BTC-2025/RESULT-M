import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_environment.dart';
import '../core/storage/secure_storage.dart';
import '../models/app_notification_model.dart';

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

class NotificationApiService {
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

  NotificationApiService() {
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

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final list = response.data as List<dynamic>;
      return list.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('/notifications/$id/read');
    } catch (e) {
      if (kDebugMode) print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } catch (e) {
      if (kDebugMode) print('Error marking all notifications as read: $e');
    }
  }
}
