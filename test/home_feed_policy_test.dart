import 'package:flutter_test/flutter_test.dart';
import 'package:result_publishing_app/features/home/application/home_feed_policy.dart';
import 'package:result_publishing_app/features/home/domain/home_feed_tab.dart';
import 'package:result_publishing_app/models/feed_post_model.dart';

void main() {
  const policy = HomeFeedPolicy();

  test('complaints tab sorts by net complaint score', () {
    final now = DateTime.now();
    final posts = [
      FeedPost(
        id: 'low',
        postType: FeedPostType.complaint,
        authorName: 'A',
        createdAt: now,
        complaint: const ComplaintPayload(
          complaintId: 'low',
          category: 'Infrastructure',
          title: 'Low score',
          description: 'Low',
          status: 'OPEN',
          upvotes: 4,
          downvotes: 2,
        ),
      ),
      FeedPost(
        id: 'high',
        postType: FeedPostType.complaint,
        authorName: 'B',
        createdAt: now,
        complaint: const ComplaintPayload(
          complaintId: 'high',
          category: 'Infrastructure',
          title: 'High score',
          description: 'High',
          status: 'OPEN',
          upvotes: 10,
          downvotes: 1,
        ),
      ),
    ];

    final result = policy.postsForTab(posts, HomeFeedTab.complaints);

    expect(result.map((post) => post.id), ['high', 'low']);
  });

  test('for you tab boosts onboarding interest matches', () {
    final now = DateTime.now();
    final posts = [
      FeedPost(
        id: 'generic',
        postType: FeedPostType.update,
        authorName: 'Generic',
        createdAt: now,
        likeCount: 20,
        update: const UpdatePayload(text: 'Generic', category: 'Sports'),
      ),
      FeedPost(
        id: 'interest',
        postType: FeedPostType.update,
        authorName: 'Exam Desk',
        createdAt: now.subtract(const Duration(hours: 2)),
        likeCount: 1,
        update: const UpdatePayload(text: 'Exam result', category: 'Exams'),
      ),
    ];

    final result = policy.postsForTab(
      posts,
      HomeFeedTab.forYou,
      interestTags: {'Exams'},
    );

    expect(result.first.id, 'interest');
  });

  test('live score posts are excluded from feed tabs', () {
    final now = DateTime.now();
    final posts = [
      FeedPost(
        id: 'live',
        postType: FeedPostType.liveScore,
        authorName: 'Live',
        createdAt: now,
        liveScore: const LiveScorePayload(
          domainType: 'SPORT',
          eventTitle: 'Match',
          teamA: 'A',
          scoreA: '1',
        ),
      ),
    ];

    final result = policy.postsForTab(posts, HomeFeedTab.forYou);

    expect(result, isEmpty);
  });
}
