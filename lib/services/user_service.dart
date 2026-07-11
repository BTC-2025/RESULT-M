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

class UserService {
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

  UserService() {
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

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await _dio.get('/users/me');
      final data = response.data as Map<String, dynamic>;
      if (data['profilePictureBase64'] != null) {
        await _secureStorage.saveProfilePicture(data['profilePictureBase64']);
      }
      return data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMyProfile({
    required String name,
    String? phoneNumber,
    String? profilePictureBase64,
    String? bio,
    String? website,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name.trim(),
      };
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        data['phoneNumber'] = phoneNumber.trim();
      }
      if (profilePictureBase64 != null) {
        data['profilePictureBase64'] = profilePictureBase64;
      }
      if (bio != null) {
        data['bio'] = bio.trim();
      }
      if (website != null) {
        data['website'] = website.trim();
      }

      final response = await _dio.put('/users/me', data: data);
      
      // Update local secure storage name if the update was successful
      if (response.data != null) {
        if (response.data['name'] != null) {
          await _secureStorage.saveName(response.data['name']);
        }
        if (response.data['profilePictureBase64'] != null) {
          await _secureStorage.saveProfilePicture(response.data['profilePictureBase64']);
        }
      }
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      throw Exception(_extractError(e, 'Unable to update profile.'));
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception(e.toString());
    }
  }

  Future<String?> deleteMyAccount() async {
    try {
      await _dio.delete('/users/me');
      await _secureStorage.clearAll();
      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      return _extractError(e, 'Unable to delete account.');
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> getPublicProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching public profile: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return null;
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await _dio.post('/users/$userId/follow');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error following user: $e');
      }
      throw Exception(_extractError(e, 'Unable to follow user.'));
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _dio.delete('/users/$userId/follow');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error unfollowing user: $e');
      }
      throw Exception(_extractError(e, 'Unable to unfollow user.'));
    }
  }

  Future<void> removeFollower(String followerId) async {
    try {
      await _dio.delete('/users/followers/$followerId');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error removing follower: $e');
      }
      throw Exception(_extractError(e, 'Unable to remove follower.'));
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _dio.post('/users/$userId/block');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error blocking user: $e');
      }
      throw Exception(_extractError(e, 'Unable to block user.'));
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _dio.delete('/users/$userId/block');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error unblocking user: $e');
      }
      throw Exception(_extractError(e, 'Unable to unblock user.'));
    }
  }

  Future<List<dynamic>?> getFollowers(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/followers');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching followers: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return null;
    }
  }

  Future<List<dynamic>?> getFollowing(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/following');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching following: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserPosts(String userId, {String? cursor, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/feed/user/$userId',
        queryParameters: {
          // ignore: use_null_aware_elements
          if (cursor != null) 'cursor': cursor,
          'size': size,
        },
      );
      final data = response.data;
      if (data is Map) {
        return {
          'items': data['items'] as List<dynamic>? ?? [],
          'nextCursor': data['nextCursor'] as String?,
          'hasMore': data['hasMore'] as bool? ?? false,
        };
      }
      return {'items': <dynamic>[], 'nextCursor': null, 'hasMore': false};
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching user posts: $e');
      }
      return {'items': <dynamic>[], 'nextCursor': null, 'hasMore': false};
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return {'items': <dynamic>[], 'nextCursor': null, 'hasMore': false};
    }
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return e.message ?? fallback;
  }
}
