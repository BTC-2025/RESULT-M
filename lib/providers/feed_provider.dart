import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_post_model.dart';
import '../services/api_service.dart';

class FeedState {
  final List<LiveStory> stories;
  final List<FeedPost> posts;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  const FeedState({
    this.stories = const [],
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  FeedState copyWith({
    List<LiveStory>? stories,
    List<FeedPost>? posts,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) =>
      FeedState(
        stories: stories ?? this.stories,
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        error: error,
      );
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);

class FeedNotifier extends Notifier<FeedState> {
  late ApiService _api;

  @override
  FeedState build() {
    _api = ref.watch(apiServiceProvider);
    Future.microtask(loadFeed);
    return const FeedState(isLoading: true);
  }

  Future<void> loadFeed() async {
    if (state.isLoading && state.page > 0) return;
    state = FeedState(
      stories: _fallbackStories(),
      posts: _fallbackPosts(),
      isLoading: false,
      hasMore: false,
      page: 1,
      error: null,
    );

    try {
      final workspaces = await _safeList(
        _api.fetchPublicWorkspaces(),
        timeout: const Duration(seconds: 3),
      );
      final voteBoxes = await _safeList(
        _api.fetchVoteBoxes(page: 0, size: 8),
        timeout: const Duration(seconds: 3),
      );
      final complaints = await _safeList(
        _api.fetchComplaints(sort: 'trending', page: 0, size: 8),
        timeout: const Duration(seconds: 3),
      );

      final stories = _storiesFromWorkspaces(workspaces);
      final fetchedPosts = <FeedPost>[
        ...workspaces
            .take(6)
            .whereType<Map<String, dynamic>>()
            .map((workspace) => _resultPostFromWorkspace(workspace, null)),
        ...voteBoxes.take(4).map(_pollPostFromJson),
        ...complaints.take(5).map(_complaintPostFromJson),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Always include our permanent Hubs and fallback posts at the top
      final posts = <FeedPost>[
        ..._fallbackPosts(),
        ...fetchedPosts,
      ];

      state = state.copyWith(
        stories: stories.isEmpty ? _fallbackStories() : stories,
        posts: posts,
        isLoading: false,
        hasMore: false,
        page: 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: null);
    }
  }

  Future<void> refresh() async {
    state = const FeedState(isLoading: true);
    await loadFeed();
  }

  void loadMore() {}

  Future<void> voteComplaint(String postId, String voteType) async {
    final oldPosts = state.posts;
    state = state.copyWith(posts: _optimisticComplaintVote(postId, voteType));

    final complaintId = oldPosts
        .where((post) => post.id == postId)
        .firstOrNull
        ?.complaint
        ?.complaintId;
    if (complaintId == null || complaintId.startsWith('offline-')) return;

    try {
      await _api.castComplaintVote(complaintId, voteType);
    } catch (_) {
      state = state.copyWith(posts: oldPosts);
    }
  }

  Future<void> votePoll(String postId, String optionId) async {
    final oldPosts = state.posts;
    state = state.copyWith(posts: _optimisticPollVote(postId, optionId));

    final voteBoxId =
        oldPosts.where((post) => post.id == postId).firstOrNull?.poll?.voteBoxId;
    if (voteBoxId == null || voteBoxId.startsWith('offline-')) return;

    try {
      await _api.castVote(voteBoxId, optionId, null);
    } catch (_) {
      state = state.copyWith(posts: oldPosts);
    }
  }

  Future<List<dynamic>> _safeList(
    Future<List<dynamic>> future, {
    required Duration timeout,
  }) async {
    try {
      return await future.timeout(timeout);
    } catch (_) {
      return const [];
    }
  }

  List<LiveStory> _storiesFromWorkspaces(List<dynamic> workspaces) {
    return workspaces.whereType<Map<String, dynamic>>().take(10).map((workspace) {
      final id = workspace['id']?.toString() ?? workspace['name'].toString();
      final domainType = _normalizeDomain(workspace['domainType']?.toString());
      return LiveStory(
        id: id,
        label: workspace['name']?.toString() ?? 'Live',
        emoji: _domainEmoji(domainType),
        isLive: _isLiveDomain(domainType),
        workspaceId: workspace['id']?.toString(),
        domainType: domainType,
      );
    }).toList();
  }

  FeedPost _resultPostFromWorkspace(
    Map<String, dynamic> workspace,
    Map<String, dynamic>? dataset,
  ) {
    final workspaceId = workspace['id']?.toString();
    final domainType = _normalizeDomain(
      dataset?['domainType']?.toString() ?? workspace['domainType']?.toString(),
    );
    final title = dataset?['name']?.toString() ??
        workspace['name']?.toString() ??
        'Published result';

    return FeedPost(
      id: 'workspace-$workspaceId-${dataset?['id'] ?? 'summary'}',
      postType: FeedPostType.result,
      authorName: workspace['name']?.toString() ?? 'ResultHub',
      isOrganization: true,
      createdAt: _parseDate(dataset?['updatedAt'] ?? workspace['updatedAt']) ??
          DateTime.now().subtract(const Duration(minutes: 20)),
      likeCount: _countFromId(workspaceId, 200),
      commentCount: _countFromId(dataset?['id']?.toString(), 35),
      result: ResultPayload(
        domainType: domainType,
        title: title,
        subtitle: workspace['description']?.toString() ??
            dataset?['description']?.toString() ??
            'Live result campaign is open.',
        badge: _isLiveDomain(domainType) ? 'LIVE' : 'NEW',
        workspaceId: workspaceId,
        datasetId: dataset?['id']?.toString(),
        isPublic: _isLiveDomain(domainType),
      ),
    );
  }

  FeedPost _pollPostFromJson(dynamic raw) {
    final data = Map<String, dynamic>.from(raw as Map);
    final options = (data['options'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((option) => PollOption(
              id: option['id']?.toString() ?? option['optionText'].toString(),
              text: option['optionText']?.toString() ??
                  option['text']?.toString() ??
                  'Option',
              voteCount: _asInt(option['voteCount']),
            ))
        .toList();

    return FeedPost(
      id: 'poll-${data['id']}',
      postType: FeedPostType.poll,
      authorName: 'ResultHub Community',
      isOrganization: true,
      createdAt:
          _parseDate(data['createdAt']) ?? DateTime.now().subtract(const Duration(hours: 1)),
      likeCount: _asInt(data['totalVotes']),
      commentCount: _countFromId(data['id']?.toString(), 50),
      poll: PollPayload(
        voteBoxId: data['id']?.toString() ?? '',
        question: data['title']?.toString() ?? 'Community poll',
        options: options,
        totalVotes: _asInt(data['totalVotes']),
        hasVoted: data['hasVoted'] == true,
        userVotedOptionId: data['selectedOptionId']?.toString(),
        endsAt: _parseDate(data['endsAt']),
      ),
    );
  }

  FeedPost _complaintPostFromJson(dynamic raw) {
    final data = Map<String, dynamic>.from(raw as Map);
    return FeedPost(
      id: 'complaint-${data['id']}',
      postType: FeedPostType.complaint,
      authorName: data['isAnonymous'] == true ? 'Anonymous' : 'Community member',
      createdAt:
          _parseDate(data['createdAt']) ?? DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: _asInt(data['netScore']),
      commentCount: _asInt(data['commentCount']),
      complaint: ComplaintPayload(
        complaintId: data['id']?.toString() ?? '',
        category: data['category']?.toString() ?? 'Other',
        title: data['title']?.toString() ?? 'Community complaint',
        description: data['description']?.toString() ?? '',
        status: data['status']?.toString() ?? 'OPEN',
        upvotes: _asInt(data['upvotes']),
        downvotes: _asInt(data['downvotes']),
        mediaUrls: (data['mediaUrls'] as List<dynamic>? ?? [])
            .map((url) => url.toString())
            .toList(),
        locationName: data['locationName']?.toString(),
        userVote: data['hasUserVoted']?.toString(),
      ),
    );
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
          poll: post.poll!.copyWithVote(optionId),
        );
      }
      return post;
    }).toList();
  }
}

String _normalizeDomain(String? raw) {
  if (raw == null) return 'RESULT';
  final upper = raw.toUpperCase();
  
  if (upper.contains('SPORT') || upper.contains('CRICKET') || upper.contains('FOOTBALL') || upper.contains('SOCCER') || upper.contains('GAME')) {
    return 'SPORT';
  } else if (upper.contains('POLITIC') || upper.contains('ELECTION') || upper.contains('VOTE')) {
    return 'ELECTION';
  } else if (upper.contains('EDU') || upper.contains('ACADEMIC') || upper.contains('SCHOOL') || upper.contains('COLLEGE') || upper.contains('EXAM')) {
    return 'ACADEMIC';
  } else if (upper.contains('FINANCE') || upper.contains('MARKET') || upper.contains('ECONOMY')) {
    return 'FINANCE';
  } else if (upper.contains('ENTERTAIN') || upper.contains('MEDIA') || upper.contains('MOVIE')) {
    return 'ENTERTAINMENT';
  } else if (upper.contains('LAW') || upper.contains('GOV') || upper.contains('COURT')) {
    return 'LAW';
  } else if (upper.contains('TECH') || upper.contains('INNOVATION') || upper.contains('SOFTWARE')) {
    return 'TECH';
  }
  return 'RESULT';
}

bool _isLiveDomain(String domainType) {
  return domainType == 'SPORT' ||
      domainType == 'ELECTION' ||
      domainType == 'FINANCE' ||
      domainType == 'ENTERTAINMENT';
}

String _domainEmoji(String domainType) {
  switch (domainType) {
    case 'SPORT':
      return 'S';
    case 'ELECTION':
      return 'E';
    case 'ACADEMIC':
      return 'A';
    case 'FINANCE':
      return 'F';
    case 'ENTERTAINMENT':
      return 'M';
    default:
      return 'R';
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _countFromId(String? id, int max) {
  if (id == null || id.isEmpty) return max ~/ 3;
  final sum = id.codeUnits.fold<int>(0, (total, unit) => total + unit);
  return (sum % max) + 1;
}

List<LiveStory> _fallbackStories() => const [
      LiveStory(id: 'live-sports', label: 'Cricket', emoji: '🏏', isLive: true, domainType: 'SPORT', imageUrl: 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=200&q=80'),
      LiveStory(id: 'live-election', label: 'Election', emoji: '🗳️', isLive: true, domainType: 'ELECTION', imageUrl: 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?w=200&q=80'),
      LiveStory(id: 'live-anna', label: 'Anna Univ', emoji: '🎓', isLive: true, domainType: 'ACADEMIC', imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/49/Anna_University_Logo.svg/1200px-Anna_University_Logo.svg.png'),
      LiveStory(id: 'live-market', label: 'Markets', emoji: '📈', isLive: true, domainType: 'FINANCE', imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=200&q=80'),
    ];

List<FeedPost> _fallbackPosts() => [
      FeedPost(
        id: 'fallback-live',
        postType: FeedPostType.liveScore,
        authorName: 'City Cricket Finals',
        authorAvatarUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/BCCI_logo.svg/1200px-BCCI_logo.svg.png',
        isOrganization: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        likeCount: 920,
        commentCount: 64,
        liveScore: const LiveScorePayload(
          domainType: 'SPORT',
          eventTitle: 'City Cricket Finals Live Scoreboard',
          teamA: 'Chennai Kings',
          teamB: 'Mumbai Strikers',
          scoreA: '186/4',
          scoreB: '142/6',
          logoUrlA: 'https://upload.wikimedia.org/wikipedia/en/thumb/2/2b/Chennai_Super_Kings_Logo.svg/1200px-Chennai_Super_Kings_Logo.svg.png',
          logoUrlB: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/cd/Mumbai_Indians_Logo.svg/1200px-Mumbai_Indians_Logo.svg.png',
          status: 'LIVE',
          isLive: true,
          workspaceId: '22222222-2222-4222-8222-222222222222',
        ),
      ),
      FeedPost(
        id: 'fallback-result',
        postType: FeedPostType.result,
        authorName: 'ResultHub Education',
        authorAvatarUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/49/Anna_University_Logo.svg/1200px-Anna_University_Logo.svg.png',
        isOrganization: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        likeCount: 2100,
        commentCount: 176,
        result: const ResultPayload(
          domainType: 'ACADEMIC_HUB',
          title: 'University Results Hub',
          subtitle: 'Search across 500+ Indian Universities & Boards.',
          logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/49/Anna_University_Logo.svg/1200px-Anna_University_Logo.svg.png',
          badge: 'NEW',
          workspaceId: '11111111-1111-4111-8111-111111111111',
          datasetId: 'univ_hub',
        ),
      ),
      FeedPost(
        id: 'fallback-school-result',
        postType: FeedPostType.result,
        authorName: 'National Board of Education',
        authorAvatarUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/95/CBSE_new_logo.svg/1200px-CBSE_new_logo.svg.png',
        isOrganization: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        likeCount: 3400,
        commentCount: 215,
        result: const ResultPayload(
          domainType: 'SCHOOL_HUB',
          title: 'School Board Results Hub',
          subtitle: 'Check 10th & 12th Board Results (CBSE, State Boards).',
          logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/95/CBSE_new_logo.svg/1200px-CBSE_new_logo.svg.png',
          badge: 'HOT',
          workspaceId: '22222222-2222-4222-8222-222222222222',
          datasetId: 'school_hub',
        ),
      ),
      FeedPost(
        id: 'fallback-poll',
        postType: FeedPostType.poll,
        authorName: 'ResultHub Community',
        isOrganization: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 128,
        commentCount: 12,
        poll: PollPayload(
          voteBoxId: 'offline-vote-1',
          question: 'Which result alert should be pinned first?',
          totalVotes: 128,
          options: const [
            PollOption(id: 'opt-1', text: 'Exam results', voteCount: 61),
            PollOption(id: 'opt-2', text: 'Sports scores', voteCount: 39),
            PollOption(id: 'opt-3', text: 'Market alerts', voteCount: 28),
          ],
          endsAt: DateTime.now().add(const Duration(days: 2)),
        ),
      ),
    ];
