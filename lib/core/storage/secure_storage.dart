import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SecureStorage {
  static const String _keyToken = 'jwt_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyRole = 'user_role';
  static const String _keyProfilePicture = 'user_profile_picture';
  static const String _keyGuestId = 'guest_id';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyToken);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyRefreshToken);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserId, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserId);
  }

  Future<void> saveName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_keyName, name);
  }

  Future<String?> getName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyName);
  }

  Future<void> saveEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_keyEmail, email);
  }

  Future<String?> getEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmail);
  }

  Future<void> saveRole(String role) async {
    final prefs = await _prefs;
    await prefs.setString(_keyRole, role);
  }

  Future<String?> getRole() async {
    final prefs = await _prefs;
    return prefs.getString(_keyRole);
  }

  Future<void> saveProfilePicture(String base64String) async {
    final prefs = await _prefs;
    await prefs.setString(_keyProfilePicture, base64String);
  }

  Future<String?> getProfilePicture() async {
    final prefs = await _prefs;
    return prefs.getString(_keyProfilePicture);
  }

  Future<String> getOrCreateGuestId() async {
    final prefs = await _prefs;
    final existing = prefs.getString(_keyGuestId);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure().nextInt(1 << 32).toRadixString(36);
    final created =
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-$random';
    await prefs.setString(_keyGuestId, created);
    return created;
  }

  Future<void> saveWorkspaceToken(String workspaceId, String token) async {
    final prefs = await _prefs;
    await prefs.setString('workspace_token_$workspaceId', token);
  }

  Future<String?> getWorkspaceToken(String workspaceId) async {
    final prefs = await _prefs;
    return prefs.getString('workspace_token_$workspaceId');
  }

  Future<void> deleteWorkspaceToken(String workspaceId) async {
    final prefs = await _prefs;
    await prefs.remove('workspace_token_$workspaceId');
  }

  Future<void> saveVoteBoxToken(String voteBoxId, String token) async {
    final prefs = await _prefs;
    await prefs.setString('vote_box_token_$voteBoxId', token);
  }

  Future<String?> getVoteBoxToken(String voteBoxId) async {
    final prefs = await _prefs;
    return prefs.getString('vote_box_token_$voteBoxId');
  }

  Future<void> deleteVoteBoxToken(String voteBoxId) async {
    final prefs = await _prefs;
    await prefs.remove('vote_box_token_$voteBoxId');
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
