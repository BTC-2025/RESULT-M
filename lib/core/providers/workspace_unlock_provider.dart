import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';

enum WorkspaceUnlockState { idle, loading, success, error }

class WorkspaceUnlockStateData {
  final WorkspaceUnlockState status;
  final String? errorMessage;

  WorkspaceUnlockStateData({this.status = WorkspaceUnlockState.idle, this.errorMessage});

  WorkspaceUnlockStateData copyWith({WorkspaceUnlockState? status, String? errorMessage}) {
    return WorkspaceUnlockStateData(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WorkspaceUnlockNotifier extends StateNotifier<WorkspaceUnlockStateData> {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  WorkspaceUnlockNotifier(this._apiClient, this._secureStorage) : super(WorkspaceUnlockStateData());

  Future<bool> unlockWorkspace(String workspaceId, String accessCode) async {
    state = state.copyWith(status: WorkspaceUnlockState.loading, errorMessage: null);

    try {
      final response = await _apiClient.client.post(
        '/workspaces/$workspaceId/unlock',
        data: {'accessCode': accessCode},
      );

      final token = response.data['token'] as String?;
      if (token != null) {
        await _secureStorage.saveWorkspaceToken(workspaceId, token);
        state = state.copyWith(status: WorkspaceUnlockState.success);
        return true;
      } else {
        state = state.copyWith(status: WorkspaceUnlockState.error, errorMessage: 'Invalid response from server.');
        return false;
      }
    } on DioException catch (e) {
      final customMessage = e.error as String?; // Assuming our interceptor sets this
      state = state.copyWith(
        status: WorkspaceUnlockState.error, 
        errorMessage: customMessage ?? 'Incorrect code. Try again.'
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: WorkspaceUnlockState.error, 
        errorMessage: 'An unexpected error occurred. Please try again.'
      );
      return false;
    }
  }
}

final workspaceUnlockProvider = StateNotifierProvider<WorkspaceUnlockNotifier, WorkspaceUnlockStateData>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // SecureStorage is usually instantiated directly or via a provider, we'll instantiate it
  final secureStorage = SecureStorage();
  return WorkspaceUnlockNotifier(apiClient, secureStorage);
});
