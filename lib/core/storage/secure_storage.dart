import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const String _keyToken = 'jwt_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';

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

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> saveName(String name) async {
    await _storage.write(key: _keyName, value: name);
  }

  Future<String?> getName() async {
    return await _storage.read(key: _keyName);
  }

  Future<void> saveEmail(String email) async {
    await _storage.write(key: _keyEmail, value: email);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
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

  Future<void> saveVoteBoxToken(String voteBoxId, String token) async {
    await _storage.write(key: 'vote_box_token_$voteBoxId', value: token);
  }

  Future<String?> getVoteBoxToken(String voteBoxId) async {
    return await _storage.read(key: 'vote_box_token_$voteBoxId');
  }

  Future<void> deleteVoteBoxToken(String voteBoxId) async {
    await _storage.delete(key: 'vote_box_token_$voteBoxId');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
