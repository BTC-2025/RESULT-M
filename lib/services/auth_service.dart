import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/storage/secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

String _defaultAuthBaseUrl() {
  const configuredUrl = String.fromEnvironment('API_BASE_URL');
  if (configuredUrl.isNotEmpty) return configuredUrl;
  return Platform.isAndroid
      ? 'http://127.0.0.1:8080/api/v1'
      : 'http://localhost:8080/api/v1';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
  );

  // Sign Up with Email & Password
  Future<String?> signUp({
    required String email,
    required String password,
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name?.trim().isNotEmpty == true ? name!.trim() : email,
          'email': email,
          'password': password,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
      await _storeAuthResponse(response.data);
      return null; // Null means success
    } on DioException catch (e) {
      return _extractError(e, 'Unable to create account.');
    } catch (e) {
      return e.toString();
    }
  }

  // Login with Email & Password
  Future<String?> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _storeAuthResponse(response.data);
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

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut(); // Ensure Google session is also cleared
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
      final response = await _dio.post(
        '/auth/register/organization',
        data: {
          'name': name,
          'organizationType': organizationType,
          'email': email,
          'password': password,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (website != null) 'website': website,
          if (city != null) 'city': city,
        },
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
      await _dio.post('/auth/forgot-password', data: {'email': email});
      return null;
    } on DioException catch (e) {
      return _extractError(e, 'Unable to send OTP.');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifyOtp({required String email, required String otp}) async {
    try {
      await _dio.post('/auth/verify-otp', data: {'email': email, 'otp': otp});
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
      await _dio.post('/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
      return null;
    } on DioException catch (e) {
      return _extractError(e, 'Unable to reset password.');
    } catch (e) {
      return e.toString();
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      // Initialize the Google Sign-In instance
      await GoogleSignIn.instance.initialize();

      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      await _auth.signInWithCredential(credential);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return 'An account already exists with the same email but different sign-in method.';
      }
      return e.message ?? 'An unknown Firebase error occurred.';
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
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? fallback;
  }
}
