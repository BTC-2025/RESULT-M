import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/data/home_feed_repository.dart';
import '../models/feed_post_model.dart';

FeedState? _lastGoodFeedState;

class FeedState {
  final List<LiveStory> stories;
  final List<FeedPost> posts;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const FeedState({
    this.stories = const [],
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.nextCursor,
    this.error,
  });

  FeedState copyWith({
    List<LiveStory>? stories,
    List<FeedPost>? posts,
    bool? isLoading,
    bool? hasMore,
    String? nextCursor,
    String? error,
  }) => FeedState(
    stories: stories ?? this.stories,
    posts: posts ?? this.posts,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    nextCursor: nextCursor ?? this.nextCursor,
    error: error,
  );
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);

class FeedNotifier extends Notifier<FeedState> {
  late HomeFeedRepository _repository;
  final Set<String> _pendingPostLikes = <String>{};
  final Set<String> _pendingComplaintVotes = <String>{};
  final Set<String> _pendingBookmarks = <String>{};

  @override
  FeedState build() {
    _repository = ref.watch(homeFeedRepositoryProvider);
    return _initialState();
  }

  Future<void> loadFeed() async {
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: state.posts.isEmpty, error: null);
    try {
      state = _remember(_stateFromSnapshot(await _repository.refresh()));
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  FeedState _initialState() {
    if (_lastGoodFeedState != null) {
      return _lastGoodFeedState!;
    }
    return _stateFromSnapshot(_repository.initialSnapshot());
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final snapshot = await _repository.loadMore(cursor: state.nextCursor);
      state = state.copyWith(
        posts: [...state.posts, ...snapshot.posts],
        stories: snapshot.stories.isEmpty ? state.stories : snapshot.stories,
        hasMore: snapshot.hasMore,
        nextCursor: snapshot.nextCursor,
        isLoading: false,
        error: null,
      );
      _remember(state);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> addUpdatePost({
    required String text,
    List<String> mediaUrls = const [],
    String? locationName,
    String? category,
  }) async {
    final now = DateTime.now();
    final post = FeedPost(
      id: 'local-update-${now.microsecondsSinceEpoch}',
      postType: FeedPostType.update,
      authorName: 'ResultHub User',
      createdAt: now,
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      isSaved: false,
      update: UpdatePayload(
        text: text,
        mediaUrls: mediaUrls,
        locationName: _cleanNullable(locationName),
        category: _cleanNullable(category),
        hasVideo: mediaUrls.any(_looksLikeVideo),
      ),
    );
    await _createOptimistically(
      post,
      () => _repository.createUpdatePost(
        CreateUpdatePostRequest(
          optimisticPost: post,
          text: text,
          mediaPaths: mediaUrls,
          locationName: locationName,
          category: category,
        ),
      ),
    );
  }

  Future<void> addComplaintPost({
    required String title,
    required String description,
    required String category,
    String? locationName,
    List<String> mediaUrls = const [],
    bool isAnonymous = false,
  }) async {
    final now = DateTime.now();
    final id = 'local-complaint-${now.microsecondsSinceEpoch}';
    final post = FeedPost(
      id: id,
      postType: FeedPostType.complaint,
      authorName: isAnonymous ? 'Anonymous' : 'ResultHub User',
      createdAt: now,
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      isSaved: false,
      complaint: ComplaintPayload(
        complaintId: id,
        category: category,
        title: title,
        description: description,
        status: 'OPEN',
        upvotes: 0,
        downvotes: 0,
        mediaUrls: mediaUrls,
        locationName: _cleanNullable(locationName),
      ),
    );
    await _createOptimistically(
      post,
      () => _repository.createComplaintPost(
        CreateComplaintPostRequest(
          optimisticPost: post,
          title: title,
          description: description,
          category: category,
          locationName: locationName,
          mediaPaths: mediaUrls,
          isAnonymous: isAnonymous,
        ),
      ),
    );
  }

  Future<void> addPollPost({
    required String question,
    required List<String> options,
    List<String> mediaUrls = const [],
    bool allowAnonymous = true,
    String visibility = 'PUBLIC',
  }) async {
    final now = DateTime.now();
    final id = 'local-poll-${now.microsecondsSinceEpoch}';
    final post = FeedPost(
      id: id,
      postType: FeedPostType.poll,
      authorName: 'ResultHub User',
      createdAt: now,
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      isSaved: false,
      poll: PollPayload(
        voteBoxId: id,
        question: question,
        options: [
          for (var i = 0; i < options.length; i++)
            PollOption(
              id: 'local-option-$i-${now.microsecondsSinceEpoch}',
              text: options[i],
              voteCount: 0,
            ),
        ],
        totalVotes: 0,
        endsAt: now.add(const Duration(days: 7)),
      ),
      update: mediaUrls.isEmpty
          ? null
          : UpdatePayload(text: '', mediaUrls: mediaUrls),
    );
    await _createOptimistically(
      post,
      () => _repository.createPollPost(
        CreatePollPostRequest(
          optimisticPost: post,
          question: question,
          options: options,
          mediaPaths: mediaUrls,
          allowAnonymous: allowAnonymous,
          visibility: visibility,
        ),
      ),
    );
  }

  void _prependPost(FeedPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  Future<void> _createOptimistically(
    FeedPost optimisticPost,
    Future<FeedPost> Function() create,
  ) async {
    final oldPosts = state.posts;
    _prependPost(optimisticPost);
    try {
      final createdPost = await create();
      state = state.copyWith(
        posts: _replacePost(optimisticPost.id, createdPost),
      );
      try {
        await refresh();
      } catch (error) {
        state = state.copyWith(error: error.toString());
      }
    } catch (error) {
      state = state.copyWith(posts: oldPosts, error: error.toString());
      rethrow;
    }
  }

  List<FeedPost> _replacePost(String oldPostId, FeedPost newPost) {
    return state.posts
        .map((post) => post.id == oldPostId ? newPost : post)
        .toList();
  }

  Future<void> voteComplaint(String postId, String voteType) async {
    if (!_pendingComplaintVotes.add(postId)) return;
    final oldPosts = state.posts;
    state = state.copyWith(posts: _optimisticComplaintVote(postId, voteType));

    final complaintId = oldPosts
        .where((post) => post.id == postId)
        .firstOrNull
        ?.complaint
        ?.complaintId;
    if (complaintId == null || complaintId.startsWith('local-')) {
      _pendingComplaintVotes.remove(postId);
      return;
    }

    try {
      await _repository.voteComplaint(
        complaintId: complaintId,
        voteType: voteType,
      );
    } catch (_) {
      state = state.copyWith(posts: oldPosts);
    } finally {
      _pendingComplaintVotes.remove(postId);
    }
  }

  Future<void> votePoll(String postId, String optionId) async {
    final oldPosts = state.posts;
    state = state.copyWith(posts: _optimisticPollVote(postId, optionId));

    final voteBoxId = oldPosts
        .where((post) => post.id == postId)
        .firstOrNull
        ?.poll
        ?.voteBoxId;
    if (voteBoxId == null || voteBoxId.startsWith('local-')) return;

    try {
      await _repository.votePoll(voteBoxId: voteBoxId, optionId: optionId);
    } catch (_) {
      state = state.copyWith(posts: oldPosts);
    }
  }

  Future<PostInteractionSnapshot> fetchPostInteractions(String postId) {
    return _repository.fetchPostInteractions(postId);
  }

  Future<PostInteractionSnapshot> likePost(String postId) async {
    if (!_pendingPostLikes.add(postId)) {
      return _repository.fetchPostInteractions(postId);
    }

    // Optimistic UI update
    final oldPosts = state.posts;
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return FeedPost(
            id: post.id,
            postType: post.postType,
            authorName: post.authorName,
            createdAt: post.createdAt,
            authorAvatarUrl: post.authorAvatarUrl,
            isOrganization: post.isOrganization,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
            commentCount: post.commentCount,
            isLiked: !post.isLiked,
            isSaved: post.isSaved,
            liveScore: post.liveScore,
            result: post.result,
            update: post.update,
            poll: post.poll,
            complaint: post.complaint,
          );
        }
        return post;
      }).toList(),
    );

    try {
      final snapshot = await _repository.likePost(postId);
      _applyPostInteraction(snapshot);
      return snapshot;
    } catch (e) {
      // Revert on failure
      state = state.copyWith(posts: oldPosts);
      rethrow;
    } finally {
      _pendingPostLikes.remove(postId);
    }
  }

  Future<PostInteractionSnapshot> unlikePost(String postId) async {
    final snapshot = await _repository.unlikePost(postId);
    _applyPostInteraction(snapshot);
    return snapshot;
  }

  Future<PostInteractionSnapshot> bookmarkPost(String postId) async {
    if (!_pendingBookmarks.add(postId)) {
      return _snapshotForPost(postId);
    }
    // Optimistic UI update
    final oldPosts = state.posts;
    final target = state.posts.where((post) => post.id == postId).firstOrNull;
    final nextSaved = !(target?.isSaved ?? false);
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return FeedPost(
            id: post.id,
            postType: post.postType,
            authorName: post.authorName,
            createdAt: post.createdAt,
            authorAvatarUrl: post.authorAvatarUrl,
            isOrganization: post.isOrganization,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: post.isLiked,
            isSaved: nextSaved,
            liveScore: post.liveScore,
            result: post.result,
            update: post.update,
            poll: post.poll,
            complaint: post.complaint,
          );
        }
        return post;
      }).toList(),
    );

    try {
      final snapshot = target?.postType == FeedPostType.complaint
          ? PostInteractionSnapshot(
              postId: postId,
              liked: target?.isLiked ?? false,
              bookmarked: nextSaved
                  ? await _repository.bookmarkComplaint(
                      target?.complaint?.complaintId ?? postId,
                    )
                  : await _repository.removeComplaintBookmark(
                      target?.complaint?.complaintId ?? postId,
                    ),
              likeCount: target?.likeCount ?? 0,
              commentCount: target?.commentCount ?? 0,
            )
          : nextSaved
          ? await _repository.bookmarkPost(postId)
          : await _repository.removeBookmark(postId);
      _applyPostInteraction(snapshot);
      return snapshot;
    } catch (e) {
      state = state.copyWith(posts: oldPosts);
      rethrow;
    } finally {
      _pendingBookmarks.remove(postId);
    }
  }

  Future<PostInteractionSnapshot> removeBookmark(String postId) async {
    final snapshot = await _repository.removeBookmark(postId);
    _applyPostInteraction(snapshot);
    return snapshot;
  }

  Future<List<PostCommentDto>> fetchPostComments(String postId) {
    return _repository.fetchPostComments(postId);
  }

  Future<PostCommentDto> addPostComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final comment = await _repository.addPostComment(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );
    final snapshot = await _repository.fetchPostInteractions(postId);
    _applyPostInteraction(snapshot);
    return comment;
  }

  Future<PostCommentDto> likePostComment(String commentId) {
    return _repository.likePostComment(commentId);
  }

  Future<PostCommentDto> unlikePostComment(String commentId) {
    return _repository.unlikePostComment(commentId);
  }

  Future<List<PostCommentDto>> fetchComplaintComments(String complaintId) {
    return _repository.fetchComplaintComments(complaintId);
  }

  Future<PostCommentDto> addComplaintComment({
    required String complaintId,
    required String content,
    String? parentCommentId,
  }) async {
    final comment = await _repository.addComplaintComment(
      complaintId: complaintId,
      content: content,
      parentCommentId: parentCommentId,
    );
    return comment;
  }

  Future<PostCommentDto> likeComplaintComment(String commentId) {
    return _repository.likeComplaintComment(commentId);
  }

  Future<PostCommentDto> unlikeComplaintComment(String commentId) {
    return _repository.unlikeComplaintComment(commentId);
  }

  List<FeedPost> _optimisticComplaintVote(String postId, String voteType) {
    return state.posts.map((post) {
      if (post.id == postId && post.complaint != null) {
        return FeedPost(
          id: post.id,
          postType: post.postType,
          authorName: post.authorName,
          createdAt: post.createdAt,
          authorAvatarUrl: post.authorAvatarUrl,
          isOrganization: post.isOrganization,
          likeCount: post.likeCount,
          commentCount: post.commentCount,
          isLiked: post.isLiked,
          isSaved: post.isSaved,
          liveScore: post.liveScore,
          result: post.result,
          update: post.update,
          poll: post.poll,
          complaint: post.complaint!.copyWithVote(voteType),
        );
      }
      return post;
    }).toList();
  }

  List<FeedPost> _optimisticPollVote(String postId, String optionId) {
    return state.posts.map((post) {
      if (post.id == postId && post.poll != null && !post.poll!.hasVoted) {
        return FeedPost(
          id: post.id,
          postType: post.postType,
          authorName: post.authorName,
          createdAt: post.createdAt,
          authorAvatarUrl: post.authorAvatarUrl,
          isOrganization: post.isOrganization,
          likeCount: post.likeCount,
          commentCount: post.commentCount,
          isLiked: post.isLiked,
          isSaved: post.isSaved,
          liveScore: post.liveScore,
          result: post.result,
          update: post.update,
          complaint: post.complaint,
          poll: post.poll!.copyWithVote(optionId),
        );
      }
      return post;
    }).toList();
  }

  void _applyPostInteraction(PostInteractionSnapshot snapshot) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != snapshot.postId) return post;
        return FeedPost(
          id: post.id,
          postType: post.postType,
          authorName: post.authorName,
          createdAt: post.createdAt,
          authorAvatarUrl: post.authorAvatarUrl,
          isOrganization: post.isOrganization,
          likeCount: snapshot.likeCount,
          commentCount: snapshot.commentCount,
          isLiked: snapshot.liked,
          isSaved: snapshot.bookmarked,
          liveScore: post.liveScore,
          result: post.result,
          update: post.update,
          poll: post.poll,
          complaint: post.complaint,
        );
      }).toList(),
    );
  }

  PostInteractionSnapshot _snapshotForPost(String postId) {
    final post = state.posts.where((item) => item.id == postId).firstOrNull;
    return PostInteractionSnapshot(
      postId: postId,
      liked: post?.isLiked ?? false,
      bookmarked: post?.isSaved ?? false,
      likeCount: post?.likeCount ?? 0,
      commentCount: post?.commentCount ?? 0,
    );
  }
}

FeedState _stateFromSnapshot(HomeFeedSnapshot snapshot) {
  return FeedState(
    stories: snapshot.stories,
    posts: snapshot.posts,
    hasMore: snapshot.hasMore,
    nextCursor: snapshot.nextCursor,
    isLoading: false,
  );
}

FeedState _remember(FeedState state) {
  if (state.posts.isNotEmpty || state.stories.isNotEmpty) {
    _lastGoodFeedState = state.copyWith(isLoading: false, error: null);
  }
  return state;
}

String? _cleanNullable(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

bool _looksLikeVideo(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.mkv') ||
      lower.endsWith('.webm');
}
