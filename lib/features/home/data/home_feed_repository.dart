import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/feed_post_model.dart';
import '../../../services/api_service.dart';
import '../application/home_preferences_provider.dart';
import 'home_feed_dto.dart';

class HomeFeedSnapshot {
  final List<LiveStory> stories;
  final List<FeedPost> posts;
  final bool hasMore;
  final String? nextCursor;

  const HomeFeedSnapshot({
    this.stories = const [],
    this.posts = const [],
    this.hasMore = false,
    this.nextCursor,
  });
}

abstract class HomeFeedRepository {
  HomeFeedSnapshot initialSnapshot();

  Future<HomeFeedSnapshot> refresh();

  Future<HomeFeedSnapshot> loadMore({String? cursor});

  Future<HomeFeedSnapshot> fetchUserPosts(String userId, {String? cursor});

  Future<FeedPost> createUpdatePost(CreateUpdatePostRequest request);

  Future<FeedPost> createComplaintPost(CreateComplaintPostRequest request);

  Future<FeedPost> createPollPost(CreatePollPostRequest request);

  Future<void> voteComplaint({
    required String complaintId,
    required String voteType,
  });

  Future<void> votePoll({required String voteBoxId, required String optionId});

  Future<PostInteractionSnapshot> fetchPostInteractions(String postId);

  Future<PostInteractionSnapshot> likePost(String postId);

  Future<PostInteractionSnapshot> unlikePost(String postId);

  Future<PostInteractionSnapshot> bookmarkPost(String postId);

  Future<PostInteractionSnapshot> removeBookmark(String postId);

  Future<bool> bookmarkComplaint(String complaintId);

  Future<bool> removeComplaintBookmark(String complaintId);

  Future<List<FeedPost>> fetchSavedPosts();

  Future<List<PostCommentDto>> fetchPostComments(String postId);

  Future<PostCommentDto> addPostComment({
    required String postId,
    required String content,
    String? parentCommentId,
  });

  Future<PostCommentDto> likePostComment(String commentId);

  Future<PostCommentDto> unlikePostComment(String commentId);

  Future<List<PostCommentDto>> fetchComplaintComments(String complaintId);

  Future<PostCommentDto> addComplaintComment({
    required String complaintId,
    required String content,
    String? parentCommentId,
  });

  Future<PostCommentDto> likeComplaintComment(String commentId);

  Future<PostCommentDto> unlikeComplaintComment(String commentId);
}

class PostInteractionSnapshot {
  final String postId;
  final bool liked;
  final bool bookmarked;
  final int likeCount;
  final int commentCount;

  const PostInteractionSnapshot({
    required this.postId,
    required this.liked,
    required this.bookmarked,
    required this.likeCount,
    required this.commentCount,
  });

  factory PostInteractionSnapshot.fromJson(Map<String, dynamic> json) {
    return PostInteractionSnapshot(
      postId: json['postId']?.toString() ?? '',
      liked: json['liked'] == true,
      bookmarked: json['bookmarked'] == true,
      likeCount: int.tryParse(json['likeCount']?.toString() ?? '') ?? 0,
      commentCount: int.tryParse(json['commentCount']?.toString() ?? '') ?? 0,
    );
  }
}

class PostCommentDto {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String content;
  final String creatorName;
  final DateTime createdAt;
  final int likeCount;
  final bool liked;
  final int replyCount;

  const PostCommentDto({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.content,
    required this.creatorName,
    required this.createdAt,
    this.likeCount = 0,
    this.liked = false,
    this.replyCount = 0,
  });

  factory PostCommentDto.fromJson(Map<String, dynamic> json) {
    return PostCommentDto(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      parentCommentId: json['parentCommentId']?.toString(),
      content: json['content']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? 'Member',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      likeCount: int.tryParse(json['likeCount']?.toString() ?? '') ?? 0,
      liked: json['liked'] == true,
      replyCount: int.tryParse(json['replyCount']?.toString() ?? '') ?? 0,
    );
  }

  PostCommentDto copyWith({
    String? content,
    int? likeCount,
    bool? liked,
    int? replyCount,
  }) {
    return PostCommentDto(
      id: id,
      postId: postId,
      parentCommentId: parentCommentId,
      content: content ?? this.content,
      creatorName: creatorName,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}

class CreateUpdatePostRequest {
  final FeedPost optimisticPost;
  final String text;
  final List<String> mediaPaths;
  final String? locationName;
  final String? category;

  const CreateUpdatePostRequest({
    required this.optimisticPost,
    required this.text,
    this.mediaPaths = const [],
    this.locationName,
    this.category,
  });
}

class CreateComplaintPostRequest {
  final FeedPost optimisticPost;
  final String title;
  final String description;
  final String category;
  final String? locationName;
  final List<String> mediaPaths;
  final bool isAnonymous;

  const CreateComplaintPostRequest({
    required this.optimisticPost,
    required this.title,
    required this.description,
    required this.category,
    this.locationName,
    this.mediaPaths = const [],
    this.isAnonymous = false,
  });
}

class CreatePollPostRequest {
  final FeedPost optimisticPost;
  final String question;
  final List<String> options;
  final List<String> mediaPaths;
  final bool allowAnonymous;
  final String visibility;

  const CreatePollPostRequest({
    required this.optimisticPost,
    required this.question,
    required this.options,
    this.mediaPaths = const [],
    this.allowAnonymous = true,
    this.visibility = 'PUBLIC',
  });
}

final homeFeedRepositoryProvider = Provider<HomeFeedRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final interests = ref
      .watch(homeInterestTagsProvider)
      .maybeWhen(data: (tags) => tags, orElse: () => const <String>{});
  return ApiHomeFeedRepository(api, interests: interests);
});


class ApiHomeFeedRepository implements HomeFeedRepository {
  final ApiService _api;
  final Set<String> interests;
  final Set<String> followingWorkspaceIds;

  const ApiHomeFeedRepository(
    this._api, {
    this.interests = const {},
    this.followingWorkspaceIds = const {},
  });

  @override
  HomeFeedSnapshot initialSnapshot() {
    return const HomeFeedSnapshot();
  }

  @override
  Future<HomeFeedSnapshot> refresh() async {
    return _fetchFeed();
  }

  @override
  Future<HomeFeedSnapshot> loadMore({String? cursor}) async {
    if (cursor == null || cursor.isEmpty) {
      return const HomeFeedSnapshot(hasMore: false);
    }
    return _fetchFeed(cursor: cursor);
  }

  @override
  Future<HomeFeedSnapshot> fetchUserPosts(String userId, {String? cursor}) async {
    final dto = HomeFeedPageDto.fromJson(
      await _api.fetchUserFeed(userId: userId, cursor: cursor),
      apiBaseUrl: _api.baseUrl,
    );
    return HomeFeedSnapshot(
      posts: dto.posts,
      hasMore: dto.hasMore,
      nextCursor: dto.nextCursor,
    );
  }

  @override
  Future<FeedPost> createUpdatePost(CreateUpdatePostRequest request) async {
    final payload = {
      'postType': _postTypeFor(request),
      'text': request.text,
      'category': request.category,
      'locationName': request.locationName,
    };

    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(payload),
        contentType: DioMediaType.parse('application/json'),
      ),
    });

    for (final path in request.mediaPaths) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(path, filename: _basename(path)),
        ),
      );
    }

    final response = await _api.createFeedPost(formData);
    return _postFromFeedItemResponse(
      response,
      request.optimisticPost,
      apiBaseUrl: _api.baseUrl,
    );
  }

  @override
  Future<FeedPost> createComplaintPost(
    CreateComplaintPostRequest request,
  ) async {
    final payload = {
      'title': request.title,
      'description': request.description,
      'category': request.category,
      'locationName': request.locationName,
      'latitude': null,
      'longitude': null,
      'isAnonymous': request.isAnonymous,
    };

    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(payload),
        contentType: DioMediaType.parse('application/json'),
      ),
    });

    for (final path in request.mediaPaths) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(path, filename: _basename(path)),
        ),
      );
    }

    final response = await _api.createComplaint(formData);
    return _complaintPostFromResponse(response, request.optimisticPost);
  }

  @override
  Future<FeedPost> createPollPost(CreatePollPostRequest request) async {
    final response = await _api.createVoteBox({
      'title': request.question,
      'description': '',
      'visibility': _backendVisibility(request.visibility),
      'allowAnonymous': request.allowAnonymous,
      'hideResultsUntilEnd': false,
      'options': request.options,
    });
    return _pollPostFromResponse(response, request.optimisticPost);
  }

  @override
  Future<void> voteComplaint({
    required String complaintId,
    required String voteType,
  }) {
    return _api.castComplaintVote(complaintId, voteType);
  }

  @override
  Future<void> votePoll({required String voteBoxId, required String optionId}) {
    return _api.castVote(voteBoxId, optionId, null);
  }

  @override
  Future<PostInteractionSnapshot> fetchPostInteractions(String postId) async {
    return PostInteractionSnapshot.fromJson(
      await _api.fetchPostInteractions(postId),
    );
  }

  @override
  Future<PostInteractionSnapshot> likePost(String postId) async {
    return PostInteractionSnapshot.fromJson(await _api.likeFeedPost(postId));
  }

  @override
  Future<PostInteractionSnapshot> unlikePost(String postId) async {
    return PostInteractionSnapshot.fromJson(await _api.unlikeFeedPost(postId));
  }

  @override
  Future<PostInteractionSnapshot> bookmarkPost(String postId) async {
    return PostInteractionSnapshot.fromJson(
      await _api.bookmarkFeedPost(postId),
    );
  }

  @override
  Future<PostInteractionSnapshot> removeBookmark(String postId) async {
    return PostInteractionSnapshot.fromJson(
      await _api.removeFeedPostBookmark(postId),
    );
  }

  @override
  Future<bool> bookmarkComplaint(String complaintId) async {
    final json = await _api.bookmarkComplaint(complaintId);
    return json['bookmarked'] == true;
  }

  @override
  Future<bool> removeComplaintBookmark(String complaintId) async {
    final json = await _api.removeComplaintBookmark(complaintId);
    return json['bookmarked'] == true;
  }

  @override
  Future<List<FeedPost>> fetchSavedPosts() async {
    return (await _api.fetchSavedFeedItems())
        .whereType<Map>()
        .map((item) {
          return HomeFeedPageDto.fromJson({
            'items': [Map<String, dynamic>.from(item)],
          }, apiBaseUrl: _api.baseUrl).posts;
        })
        .expand((posts) => posts)
        .toList();
  }

  @override
  Future<List<PostCommentDto>> fetchPostComments(String postId) async {
    return (await _api.fetchFeedPostComments(postId))
        .whereType<Map>()
        .map((json) => PostCommentDto.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<PostCommentDto> addPostComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    return PostCommentDto.fromJson(
      await _api.addFeedPostComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      ),
    );
  }

  @override
  Future<PostCommentDto> likePostComment(String commentId) async {
    return PostCommentDto.fromJson(await _api.likeFeedPostComment(commentId));
  }

  @override
  Future<PostCommentDto> unlikePostComment(String commentId) async {
    return PostCommentDto.fromJson(await _api.unlikeFeedPostComment(commentId));
  }

  @override
  Future<List<PostCommentDto>> fetchComplaintComments(
    String complaintId,
  ) async {
    return (await _api.fetchComments(complaintId))
        .whereType<Map>()
        .map(
          (comment) => PostCommentDto.fromJson({
            ...Map<String, dynamic>.from(comment),
            'postId': complaintId,
          }),
        )
        .toList();
  }

  @override
  Future<PostCommentDto> addComplaintComment({
    required String complaintId,
    required String content,
    String? parentCommentId,
  }) async {
    return PostCommentDto.fromJson({
      ...await _api.postComment(complaintId, content, false, parentCommentId),
      'postId': complaintId,
    });
  }

  @override
  Future<PostCommentDto> likeComplaintComment(String commentId) async {
    return PostCommentDto.fromJson(await _api.likeComplaintComment(commentId));
  }

  @override
  Future<PostCommentDto> unlikeComplaintComment(String commentId) async {
    return PostCommentDto.fromJson(
      await _api.unlikeComplaintComment(commentId),
    );
  }

  Future<HomeFeedSnapshot> _fetchFeed({String? cursor}) async {
    final dto = HomeFeedPageDto.fromJson(
      await _api.fetchHomeFeed(
        cursor: cursor,
        interests: interests,
        followingWorkspaceIds: followingWorkspaceIds,
      ),
      apiBaseUrl: _api.baseUrl,
    );
    return HomeFeedSnapshot(
      stories: dto.stories,
      posts: dto.posts,
      hasMore: dto.hasMore,
      nextCursor: dto.nextCursor,
    );
  }
}

FeedPost _complaintPostFromResponse(
  Map<String, dynamic> data,
  FeedPost fallback,
) {
  final id = data['id']?.toString() ?? fallback.id;
  return FeedPost(
    id: id,
    postType: FeedPostType.complaint,
    authorName: fallback.authorName,
    authorAvatarUrl: fallback.authorAvatarUrl,
    isOrganization: fallback.isOrganization,
    createdAt:
        DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
        fallback.createdAt,
    likeCount: 0,
    commentCount:
        int.tryParse(data['commentCount']?.toString() ?? '') ??
        fallback.commentCount,
    complaint: ComplaintPayload(
      complaintId: id,
      category:
          data['category']?.toString() ??
          fallback.complaint?.category ??
          'Other',
      title: data['title']?.toString() ?? fallback.complaint?.title ?? '',
      description:
          data['description']?.toString() ??
          fallback.complaint?.description ??
          '',
      status: data['status']?.toString() ?? 'OPEN',
      upvotes: int.tryParse(data['upvotes']?.toString() ?? '') ?? 0,
      downvotes: int.tryParse(data['downvotes']?.toString() ?? '') ?? 0,
      mediaUrls: _stringList(data['mediaUrls']).isEmpty
          ? fallback.complaint?.mediaUrls ?? const []
          : _stringList(data['mediaUrls']),
      locationName:
          data['locationName']?.toString() ?? fallback.complaint?.locationName,
    ),
  );
}

FeedPost _pollPostFromResponse(Map<String, dynamic> data, FeedPost fallback) {
  final id = data['id']?.toString() ?? fallback.id;
  final options = data['options'] is Iterable
      ? (data['options'] as Iterable)
            .whereType<Map>()
            .map(
              (option) => PollOption(
                id: option['id']?.toString() ?? '',
                text:
                    option['optionText']?.toString() ??
                    option['text']?.toString() ??
                    '',
                voteCount:
                    int.tryParse(option['voteCount']?.toString() ?? '') ?? 0,
              ),
            )
            .where((option) => option.id.isNotEmpty && option.text.isNotEmpty)
            .toList()
      : const <PollOption>[];
  return FeedPost(
    id: id,
    postType: FeedPostType.poll,
    authorName: fallback.authorName,
    authorAvatarUrl: fallback.authorAvatarUrl,
    isOrganization: fallback.isOrganization,
    createdAt:
        DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
        fallback.createdAt,
    likeCount: 0,
    commentCount: fallback.commentCount,
    poll: PollPayload(
      voteBoxId: id,
      question: data['title']?.toString() ?? fallback.poll?.question ?? '',
      options: options.isEmpty ? fallback.poll?.options ?? const [] : options,
      totalVotes: int.tryParse(data['totalVotes']?.toString() ?? '') ?? 0,
      hasVoted: false,
      endsAt: DateTime.tryParse(data['endsAt']?.toString() ?? ''),
      isExpired: data['isExpired'] == true,
    ),
    update: fallback.update,
  );
}

List<String> _stringList(dynamic value) {
  if (value is! Iterable) return const [];
  return value.map((item) => item.toString()).toList();
}

String _backendVisibility(String visibility) {
  return visibility.trim().toUpperCase().replaceAll(' ', '_');
}

String _postTypeFor(CreateUpdatePostRequest request) {
  if (request.mediaPaths.any(_looksLikeVideoPath)) return 'VIDEO';
  if (request.mediaPaths.isNotEmpty) return 'IMAGE';
  return 'UPDATE';
}

FeedPost _postFromFeedItemResponse(
  Map<String, dynamic> data,
  FeedPost fallback, {
  String? apiBaseUrl,
}) {
  final page = HomeFeedPageDto.fromJson({
    'items': [data],
  }, apiBaseUrl: apiBaseUrl);
  return page.posts.isEmpty ? fallback : page.posts.first;
}

String _basename(String path) {
  return path.split(RegExp(r'[\\/]')).last;
}

bool _looksLikeVideoPath(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.mkv') ||
      lower.endsWith('.webm');
}
