import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? userId;
  final String? name;
  final String? email;
  final String? role;
  final String? error;
  final String? profilePictureBase64;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.userId,
    this.name,
    this.email,
    this.role,
    this.error,
    this.profilePictureBase64,
  });

  bool get isOrganization => role == 'ORGANIZATION';
}

class AuthNotifier extends Notifier<AuthState> {
  final SecureStorage _storage = SecureStorage();

  @override
  AuthState build() {
    Future.microtask(() => checkAuthStatus());
    return const AuthState(isLoading: true);
  }

  Future<void> checkAuthStatus() async {
    state = AuthState(
      isLoading: true,
      isLoggedIn: state.isLoggedIn,
      userId: state.userId,
      name: state.name,
      email: state.email,
      role: state.role,
      profilePictureBase64: state.profilePictureBase64,
    );
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();
    final name = await _storage.getName();
    final email = await _storage.getEmail();
    final role = await _storage.getRole();
    final profilePic = await _storage.getProfilePicture();

    state = AuthState(
      isLoggedIn: token != null && token.isNotEmpty,
      isLoading: false,
      userId: userId,
      name: name,
      email: email,
      role: role,
      profilePictureBase64: profilePic,
    );
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(isLoggedIn: false, isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
