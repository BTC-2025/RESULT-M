import '../../../models/feed_post_model.dart';

class HomeFeedPageDto {
  final List<LiveStory> stories;
  final List<FeedPost> posts;
  final String? nextCursor;
  final bool hasMore;

  const HomeFeedPageDto({
    this.stories = const [],
    this.posts = const [],
    this.nextCursor,
    this.hasMore = false,
  });

  factory HomeFeedPageDto.fromJson(
    Map<String, dynamic> json, {
    String? apiBaseUrl,
  }) {
    final rawPosts = _listValue(json, const ['posts', 'items', 'content']);
    final rawStories = _listValue(json, const [
      'stories',
      'liveStories',
      'live',
    ]);
    final nextCursor = _stringValue(json, const ['nextCursor', 'cursor']);
    final hasMore =
        json['hasMore'] == true ||
        json['hasNext'] == true ||
        (nextCursor != null && nextCursor.isNotEmpty);

    return HomeFeedPageDto(
      stories: rawStories
          .map((story) => _storyFromJson(story, apiBaseUrl: apiBaseUrl))
          .whereType<LiveStory>()
          .toList(),
      posts: rawPosts
          .map((post) => _postFromJson(post, apiBaseUrl: apiBaseUrl))
          .whereType<FeedPost>()
          .toList(),
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }
}

List<dynamic> _listValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}

String? _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

FeedPost? _postFromJson(dynamic value, {String? apiBaseUrl}) {
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final type = _postType(json['postType'] ?? json['type']);
  if (type == null) return null;
  final createdAt =
      DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();

  return FeedPost(
    id: json['id']?.toString() ?? 'feed-${createdAt.microsecondsSinceEpoch}',
    postType: type,
    creatorId: json['creatorId']?.toString(),
    authorName:
        json['authorName']?.toString() ??
        json['publisherName']?.toString() ??
        json['organizationName']?.toString() ??
        'ResultHub',
    authorAvatarUrl:
        json['authorAvatarUrl']?.toString() ?? json['avatarUrl']?.toString(),
    isOrganization:
        json['isOrganization'] == true ||
        json['publisherType']?.toString().toUpperCase() == 'ORGANIZATION',
    createdAt: createdAt,
    likeCount: _intValue(json['likeCount']),
    commentCount: _intValue(json['commentCount']),
    isLiked: json['liked'] == true || json['isLiked'] == true,
    isSaved: json['bookmarked'] == true || json['isSaved'] == true,
    update: type == FeedPostType.update
        ? _updatePayload(json, apiBaseUrl: apiBaseUrl)
        : null,
    complaint: type == FeedPostType.complaint
        ? _complaintPayload(json, apiBaseUrl: apiBaseUrl)
        : null,
    poll: type == FeedPostType.poll ? _pollPayload(json) : null,
    result: type == FeedPostType.result ? _resultPayload(json) : null,
    liveScore: type == FeedPostType.liveScore ? _liveScorePayload(json) : null,
  );
}

FeedPostType? _postType(dynamic value) {
  final normalized = value?.toString().toUpperCase().replaceAll('-', '_');
  switch (normalized) {
    case 'UPDATE':
    case 'IMAGE':
    case 'VIDEO':
      return FeedPostType.update;
    case 'COMPLAINT':
      return FeedPostType.complaint;
    case 'POLL':
    case 'VOTE':
    case 'VOTE_BOX':
      return FeedPostType.poll;
    case 'RESULT':
    case 'RESULT_ANNOUNCEMENT':
      return FeedPostType.result;
    case 'LIVE_SCORE':
    case 'LIVE':
      return FeedPostType.liveScore;
    default:
      return null;
  }
}

UpdatePayload _updatePayload(Map<String, dynamic> json, {String? apiBaseUrl}) {
  final payload = _payload(json);
  final mediaUrls = _strings(
    payload['mediaUrls'] ?? json['mediaUrls'],
  ).map((url) => _absoluteMediaUrl(url, apiBaseUrl)).toList();
  return UpdatePayload(
    text:
        payload['text']?.toString() ??
        payload['body']?.toString() ??
        json['text']?.toString() ??
        json['content']?.toString() ??
        '',
    mediaUrls: mediaUrls,
    locationName:
        payload['locationName']?.toString() ?? json['locationName']?.toString(),
    category: payload['category']?.toString() ?? json['category']?.toString(),
    hasVideo: mediaUrls.any(_looksLikeVideo),
  );
}

ComplaintPayload _complaintPayload(
  Map<String, dynamic> json, {
  String? apiBaseUrl,
}) {
  final payload = _payload(json);
  final id =
      payload['complaintId']?.toString() ??
      payload['id']?.toString() ??
      json['complaintId']?.toString() ??
      json['id']?.toString() ??
      '';
  return ComplaintPayload(
    complaintId: id,
    category:
        payload['category']?.toString() ??
        json['category']?.toString() ??
        'Other',
    title: payload['title']?.toString() ?? json['title']?.toString() ?? '',
    description:
        payload['description']?.toString() ??
        json['description']?.toString() ??
        '',
    status:
        payload['status']?.toString() ?? json['status']?.toString() ?? 'OPEN',
    upvotes: _intValue(payload['upvotes'] ?? json['upvotes']),
    downvotes: _intValue(payload['downvotes'] ?? json['downvotes']),
    mediaUrls: _strings(
      payload['mediaUrls'] ?? json['mediaUrls'],
    ).map((url) => _complaintMediaUrl(url, apiBaseUrl)).toList(),
    locationName:
        payload['locationName']?.toString() ?? json['locationName']?.toString(),
    userVote: payload['userVote']?.toString() ?? json['userVote']?.toString(),
  );
}

PollPayload _pollPayload(Map<String, dynamic> json) {
  final payload = _payload(json);
  final options = _listValue(payload, const ['options'])
      .whereType<Map>()
      .map(
        (option) => PollOption(
          id: option['id']?.toString() ?? '',
          text:
              option['text']?.toString() ??
              option['optionText']?.toString() ??
              '',
          voteCount: _intValue(option['voteCount']),
        ),
      )
      .where((option) => option.id.isNotEmpty && option.text.isNotEmpty)
      .toList();
  return PollPayload(
    voteBoxId:
        payload['voteBoxId']?.toString() ??
        payload['id']?.toString() ??
        json['voteBoxId']?.toString() ??
        json['id']?.toString() ??
        '',
    question:
        payload['question']?.toString() ?? json['title']?.toString() ?? '',
    options: options,
    totalVotes: _intValue(payload['totalVotes'] ?? json['totalVotes']),
    hasVoted: payload['hasVoted'] == true || json['hasVoted'] == true,
    userVotedOptionId:
        payload['selectedOptionId']?.toString() ??
        json['selectedOptionId']?.toString(),
    endsAt: DateTime.tryParse(payload['endsAt']?.toString() ?? ''),
    isExpired: payload['isExpired'] == true || json['isExpired'] == true,
  );
}

ResultPayload _resultPayload(Map<String, dynamic> json) {
  final payload = _payload(json);
  return ResultPayload(
    domainType:
        payload['domainType']?.toString() ??
        json['domainType']?.toString() ??
        'CUSTOM',
    title: payload['title']?.toString() ?? json['title']?.toString() ?? '',
    subtitle:
        payload['subtitle']?.toString() ?? json['subtitle']?.toString() ?? '',
    logoUrl: payload['logoUrl']?.toString() ?? json['logoUrl']?.toString(),
    badge: payload['badge']?.toString() ?? json['badge']?.toString(),
    workspaceId:
        payload['workspaceId']?.toString() ?? json['workspaceId']?.toString(),
    datasetId:
        payload['datasetId']?.toString() ?? json['datasetId']?.toString(),
    isPublic: payload['isPublic'] == true || json['isPublic'] == true,
  );
}

LiveScorePayload _liveScorePayload(Map<String, dynamic> json) {
  final payload = _payload(json);
  return LiveScorePayload(
    domainType:
        payload['domainType']?.toString() ??
        json['domainType']?.toString() ??
        'LIVE',
    eventTitle:
        payload['eventTitle']?.toString() ??
        json['title']?.toString() ??
        'Live result',
    teamA: payload['teamA']?.toString() ?? '',
    teamB: payload['teamB']?.toString(),
    scoreA: payload['scoreA']?.toString() ?? '',
    scoreB: payload['scoreB']?.toString(),
    logoUrlA: payload['logoUrlA']?.toString(),
    logoUrlB: payload['logoUrlB']?.toString(),
    status: payload['status']?.toString(),
    isLive: payload['isLive'] == true || json['isLive'] == true,
    workspaceId:
        payload['workspaceId']?.toString() ?? json['workspaceId']?.toString(),
  );
}

LiveStory? _storyFromJson(dynamic value, {String? apiBaseUrl}) {
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final rawImageUrl =
      json['imageUrl']?.toString() ?? json['avatarUrl']?.toString();
  return LiveStory(
    id: json['id']?.toString() ?? '',
    label:
        json['label']?.toString() ??
        json['name']?.toString() ??
        json['title']?.toString() ??
        'Live',
    domainType: json['domainType']?.toString() ?? 'CUSTOM',
    emoji: json['emoji']?.toString(),
    imageUrl: rawImageUrl == null || rawImageUrl.trim().isEmpty
        ? null
        : _absoluteMediaUrl(rawImageUrl, apiBaseUrl),
    isLive: json['isLive'] == true || json['live'] == true,
    workspaceId: json['workspaceId']?.toString(),
  );
}

Map<String, dynamic> _payload(Map<String, dynamic> json) {
  final value = json['payload'] ?? json['data'];
  if (value is Map) return Map<String, dynamic>.from(value);
  return json;
}

List<String> _strings(dynamic value) {
  if (value is! Iterable) return const [];
  return value.map((item) => item.toString()).toList();
}

int _intValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _looksLikeVideo(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.mkv') ||
      lower.endsWith('.webm');
}

String _absoluteMediaUrl(String? value, String? apiBaseUrl) {
  if (value == null || value.trim().isEmpty) return '';
  final url = value.trim();
  final parsed = Uri.tryParse(url);
  if (parsed != null && parsed.hasScheme) return url;
  if (apiBaseUrl == null || apiBaseUrl.trim().isEmpty) return url;
  final base = Uri.tryParse(apiBaseUrl);
  if (base == null) return url;
  final origin = '${base.scheme}://${base.authority}';
  if (url.startsWith('/')) return '$origin$url';
  return '${apiBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/$url';
}

String _complaintMediaUrl(String value, String? apiBaseUrl) {
  if (value.startsWith('/api/') || value.startsWith('http')) {
    return _absoluteMediaUrl(value, apiBaseUrl);
  }
  if (apiBaseUrl == null || apiBaseUrl.trim().isEmpty) return value;
  return '${apiBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/complaints/media/$value';
}
