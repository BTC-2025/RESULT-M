import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessState {
  final bool isPasswordProtected;
  final bool isUnlocked;
  final bool isPrivateBlocked;
  final String? accessToken;
  final String? error;

  AccessState({
    this.isPasswordProtected = false,
    this.isUnlocked = false,
    this.isPrivateBlocked = false,
    this.accessToken,
    this.error,
  });

  AccessState copyWith({
    bool? isPasswordProtected,
    bool? isUnlocked,
    bool? isPrivateBlocked,
    String? accessToken,
    String? error,
  }) {
    return AccessState(
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isPrivateBlocked: isPrivateBlocked ?? this.isPrivateBlocked,
      accessToken: accessToken ?? this.accessToken,
      error: error, // Can be null intentionally
    );
  }
}

class AccessNotifier extends StateNotifier<AccessState> {
  AccessNotifier() : super(AccessState());

  void initializeForDataset(bool requiresPassword, bool isPrivate) {
    state = AccessState(
      isPasswordProtected: requiresPassword,
      isPrivateBlocked: isPrivate,
      isUnlocked: !requiresPassword && !isPrivate,
    );
  }

  Future<bool> unlockWithPassword(String password) async {
    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (password == '1234') { // Mock success password
      state = state.copyWith(isUnlocked: true, error: null, accessToken: 'mock_jwt_token');
      return true;
    } else {
      state = state.copyWith(error: 'Invalid password. Please try again.');
      return false;
    }
  }
}

final accessStateProvider = StateNotifierProvider.family<AccessNotifier, AccessState, String>((ref, datasetId) {
  return AccessNotifier();
});
