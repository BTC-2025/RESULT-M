import '../../../models/feed_post_model.dart';
import '../domain/home_feed_tab.dart';

class HomeFeedPolicy {
  const HomeFeedPolicy();

  List<FeedPost> postsForTab(
    List<FeedPost> posts,
    HomeFeedTab tab, {
    Set<String> interestTags = const {},
    Set<String> followedPublisherIds = const {},
  }) {
    final visiblePosts = posts
        .where((post) => post.postType != FeedPostType.liveScore)
        .toList();

    switch (tab) {
      case HomeFeedTab.forYou:
        return visiblePosts
          ..sort(
            (a, b) => _personalizedScore(
              b,
              interestTags: interestTags,
              followedPublisherIds: followedPublisherIds,
            ).compareTo(
              _personalizedScore(
                a,
                interestTags: interestTags,
                followedPublisherIds: followedPublisherIds,
              ),
            ),
          );
      case HomeFeedTab.complaints:
        return visiblePosts
            .where((post) => post.postType == FeedPostType.complaint)
            .toList()
          ..sort((a, b) => _complaintScore(b).compareTo(_complaintScore(a)));
      case HomeFeedTab.polls:
        return visiblePosts
            .where((post) => post.postType == FeedPostType.poll)
            .toList()
          ..sort((a, b) {
            final activeCompare =
                _activePollWeight(b).compareTo(_activePollWeight(a));
            if (activeCompare != 0) return activeCompare;
            return b.createdAt.compareTo(a.createdAt);
          });
      case HomeFeedTab.trending:
        return visiblePosts
          ..sort((a, b) => engagement(b).compareTo(engagement(a)));
      case HomeFeedTab.following:
        if (followedPublisherIds.isEmpty) return const [];
        return visiblePosts.where((post) {
          return followedPublisherIds.contains(post.authorName);
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  int engagement(FeedPost post) {
    return post.likeCount +
        post.commentCount +
        _complaintScore(post) +
        (post.poll?.totalVotes ?? 0);
  }

  int _personalizedScore(
    FeedPost post, {
    required Set<String> interestTags,
    required Set<String> followedPublisherIds,
  }) {
    final age = DateTime.now().difference(post.createdAt);
    final recency = age.inMinutes < 5
        ? 100
        : age.inHours < 1
            ? 70
            : age.inHours < 12
                ? 35
                : 10;
    final interestBoost = _matchesInterest(post, interestTags) ? 160 : 0;
    final followBoost = followedPublisherIds.contains(post.authorName) ? 120 : 0;
    return engagement(post) + recency + interestBoost + followBoost;
  }

  bool _matchesInterest(FeedPost post, Set<String> interestTags) {
    if (interestTags.isEmpty) return false;
    final tags = <String?>[
      post.update?.category,
      post.complaint?.category,
      post.result?.domainType,
      post.poll?.question,
    ]
        .whereType<String>()
        .map((value) => value.toLowerCase())
        .join(' ');
    return interestTags.any((tag) => tags.contains(tag.toLowerCase()));
  }

  int _activePollWeight(FeedPost post) {
    return post.poll?.isExpired == false ? 1 : 0;
  }

  int _complaintScore(FeedPost post) {
    return (post.complaint?.upvotes ?? 0) - (post.complaint?.downvotes ?? 0);
  }
}
