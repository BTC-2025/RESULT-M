import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const String _keyToken = 'jwt_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<void> saveWorkspaceToken(String workspaceId, String token) async {
    await _storage.write(key: 'workspace_token_$workspaceId', value: token);
  }

  Future<String?> getWorkspaceToken(String workspaceId) async {
    return await _storage.read(key: 'workspace_token_$workspaceId');
  }

  Future<void> deleteWorkspaceToken(String workspaceId) async {
    await _storage.delete(key: 'workspace_token_$workspaceId');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
