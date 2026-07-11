import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_environment.dart';
import '../core/storage/secure_storage.dart';

String _defaultAuthBaseUrl() {
  const configuredUrl = AppEnvironment.apiBaseUrl;
  if (configuredUrl.isNotEmpty) return configuredUrl;
  if (kReleaseMode) {
    throw StateError('API_BASE_URL must be set for release builds.');
  }
  return Platform.isAndroid
      ? 'http://10.182.157.123:8080/api/v1' // Current Host IP (works for Emulator & Physical Device)
      : 'http://localhost:8080/api/v1';
}

void _assertReleaseUrlIsSafe(String baseUrl) {
  if (!kReleaseMode) return;
  final uri = Uri.tryParse(baseUrl);
  if (uri == null || uri.scheme != 'https') {
    throw StateError('Release API_BASE_URL must be a valid HTTPS URL.');
  }
}

class AuthService {
  final SecureStorage _secureStorage = SecureStorage();
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _defaultAuthBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..options.baseUrl = _validatedBaseUrl(_defaultAuthBaseUrl());

  static String _validatedBaseUrl(String baseUrl) {
    _assertReleaseUrlIsSafe(baseUrl);
    return baseUrl;
  }

  // Sign Up with Email & Password
  Future<String?> signUp({
    required String email,
    required String password,
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name?.trim().isNotEmpty == true ? name!.trim() : email,
        'email': email.trim().toLowerCase(),
        'password': password,
      };
      if (phoneNumber != null) {
        data['phoneNumber'] = phoneNumber;
      }

      await _dio.post('/auth/register', data: data);
      // No token is returned yet, we just successfully sent the OTP.
      return null; // Null means success
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) return null;
      return _extractError(e, 'Unable to create account.');
    } catch (e) {
      return e.toString();
    }
  }

  // Login with Email & Password
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );
      
      final data = response.data;
      if (data is Map && data['mfaRequired'] == true) {
        return {
          'mfaRequired': true,
          'mfaToken': data['mfaToken'],
        };
      }

      await _storeAuthResponse(data);
      return null; // Null means success
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return 'Incorrect email or password.';
      }
      return _extractError(e, 'Unable to log in.');
    } catch (e) {
      return e.toString();
    }
  }

  // Verify MFA for Login
  Future<String?> verifyMfaLogin({
    required String mfaToken,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login/mfa',
        data: {'mfaToken': mfaToken, 'code': code},
      );
      await _storeAuthResponse(response.data);
      return null;
    } on DioException catch (e) {
      return _extractError(e, 'Invalid or expired MFA code.');
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  // Organization Sign Up
  Future<String?> signUpOrganization({
    required String name,
    required String organizationType,
    required String email,
    required String password,
    String? phoneNumber,
    String? website,
    String? city,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'organizationType': organizationType,
        'email': email.trim().toLowerCase(),
        'password': password,
      };
      if (phoneNumber != null) {
        data['phoneNumber'] = phoneNumber;
      }
      if (website != null) {
        data['website'] = website;
      }
      if (city != null) {
        data['city'] = city;
      }

      final response = await _dio.post(
        '/auth/register/organization',
        data: data,
      );
      await _storeAuthResponse(response.data);
      return null;
    } on DioException catch (e) {
      return _extractError(e, 'Unable to create organization account.');
    } catch (e) {
      return e.toString();
    }
  }

  // Forgot Password Flow
  Future<String?> forgotPassword(String email) async {
    try {
      await _dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) return null;
      return _extractError(e, 'Unable to send OTP.');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _dio.post(
        '/auth/verify-otp',
        data: {'email': email.trim().toLowerCase(), 'otp': otp},
      );
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) return null;
      return _extractError(e, 'Invalid or expired OTP.');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/verify',
        data: {'email': email.trim().toLowerCase(), 'otp': otp},
      );
      await _storeAuthResponse(response.data);
      return null;
    } on DioException catch (e) {
      return _extractError(e, 'Invalid or expired OTP.');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) return null;
      return _extractError(e, 'Unable to reset password.');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return 'Not authenticated';
      
      await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) return null;
      return _extractError(e, 'Unable to change password.');
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _storeAuthResponse(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected auth response.');
    }

    final accessToken = data['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Login response did not include an access token.');
    }

    await _secureStorage.saveToken(accessToken);

    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.saveRefreshToken(refreshToken);
    }

    final userId = data['userId']?.toString();
    if (userId != null && userId.isNotEmpty) {
      await _secureStorage.saveUserId(userId);
    }

    final name = data['name']?.toString();
    if (name != null && name.isNotEmpty) {
      await _secureStorage.saveName(name);
    }

    final email = data['email']?.toString();
    if (email != null && email.isNotEmpty) {
      await _secureStorage.saveEmail(email);
    }

    final role = data['role']?.toString();
    if (role != null && role.isNotEmpty) {
      await _secureStorage.saveRole(role);
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
