import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

final followersProvider = FutureProvider.family<List<dynamic>?, String>((ref, userId) async {
  final userService = UserService();
  return userService.getFollowers(userId);
});

final followingProvider = FutureProvider.family<List<dynamic>?, String>((ref, userId) async {
  final userService = UserService();
  return userService.getFollowing(userId);
});
