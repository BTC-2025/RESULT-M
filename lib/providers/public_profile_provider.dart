import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/user_service.dart';

final publicProfileProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, userId) async {
  final userService = UserService();
  return await userService.getPublicProfile(userId);
});

class UserPostsState {
  final List<dynamic> posts;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.nextCursor,
    this.error,
  });

  UserPostsState copyWith({
    List<dynamic>? posts,
    bool? isLoading,
    bool? hasMore,
    String? nextCursor,
    String? error,
  }) => UserPostsState(
    posts: posts ?? this.posts,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    nextCursor: nextCursor ?? this.nextCursor,
    error: error,
  );
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {
  final UserService userService;
  final String userId;

  UserPostsNotifier({required this.userService, required this.userId}) : super(const UserPostsState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await userService.getUserPosts(userId);
      state = state.copyWith(
        posts: response['items'] as List<dynamic>,
        nextCursor: response['nextCursor'] as String?,
        hasMore: response['hasMore'] as bool,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await userService.getUserPosts(userId, cursor: state.nextCursor);
      state = state.copyWith(
        posts: [...state.posts, ...response['items'] as List<dynamic>],
        nextCursor: response['nextCursor'] as String?,
        hasMore: response['hasMore'] as bool,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await userService.getUserPosts(userId);
      state = state.copyWith(
        posts: response['items'] as List<dynamic>,
        nextCursor: response['nextCursor'] as String?,
        hasMore: response['hasMore'] as bool,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userPostsProvider = StateNotifierProvider.autoDispose.family<UserPostsNotifier, UserPostsState, String>((ref, userId) {
  return UserPostsNotifier(userService: UserService(), userId: userId);
});

class FollowController extends StateNotifier<bool> {
  final String userId;
  final UserService userService;

  FollowController(this.userId, this.userService, bool initialFollowStatus) : super(initialFollowStatus);

  Future<void> toggleFollow() async {
    final wasFollowing = state;
    state = !state; // Optimistic update
    try {
      if (wasFollowing) {
        await userService.unfollowUser(userId);
      } else {
        await userService.followUser(userId);
      }
    } catch (e) {
      state = wasFollowing; // Revert on failure
    }
  }

  void setFollowing(bool value) => state = value;
}

final followControllerProvider = StateNotifierProvider.autoDispose.family<FollowController, bool, String>((ref, userId) {
  return FollowController(userId, UserService(), false);
});
