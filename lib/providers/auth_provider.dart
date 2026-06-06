import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final String? name;
  final String? email;

  AuthState({this.isLoggedIn = false, this.name, this.email});
}

class AuthNotifier extends Notifier<AuthState> {
  final SecureStorage _storage = SecureStorage();

  @override
  AuthState build() {
    Future.microtask(() => checkAuthStatus());
    return AuthState();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getToken();
    final name = await _storage.getName();
    final email = await _storage.getEmail();

    state = AuthState(
      isLoggedIn: token != null && token.isNotEmpty,
      name: name,
      email: email,
    );
  }

  Future<void> logout() async {
    state = AuthState(isLoggedIn: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
