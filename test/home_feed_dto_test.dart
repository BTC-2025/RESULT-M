import 'package:flutter_test/flutter_test.dart';
import 'package:result_publishing_app/features/home/data/home_feed_dto.dart';
import 'package:result_publishing_app/models/feed_post_model.dart';

void main() {
  test('maps cursor feed response into stories and posts', () {
    final page = HomeFeedPageDto.fromJson({
      'nextCursor': 'cursor-2',
      'items': [
        {
          'id': 'update-1',
          'postType': 'UPDATE',
          'authorName': 'Anna University',
          'isOrganization': true,
          'createdAt': '2026-06-08T10:00:00.000Z',
          'payload': {
            'text': 'Semester results published.',
            'category': 'Academic',
            'mediaUrls': ['https://cdn.example.com/result.jpg'],
          },
        },
        {
          'id': 'complaint-1',
          'type': 'COMPLAINT',
          'authorName': 'Anonymous',
          'createdAt': '2026-06-08T10:05:00.000Z',
          'payload': {
            'title': 'Hall ticket not loading',
            'description': 'Portal is timing out.',
            'category': 'Education',
            'status': 'OPEN',
            'upvotes': 9,
            'downvotes': 1,
          },
        },
        {
          'id': 'poll-1',
          'type': 'POLL',
          'authorName': 'ResultHub',
          'createdAt': '2026-06-08T10:10:00.000Z',
          'payload': {
            'question': 'Which alert should be pinned?',
            'totalVotes': 12,
            'options': [
              {'id': 'a', 'text': 'Results', 'voteCount': 7},
              {'id': 'b', 'text': 'Complaints', 'voteCount': 5},
            ],
          },
        },
      ],
      'liveStories': [
        {
          'id': 'live-1',
          'label': 'Election',
          'domainType': 'POLITICS',
          'isLive': true,
          'workspaceId': 'workspace-1',
        },
      ],
    });

    expect(page.hasMore, isTrue);
    expect(page.nextCursor, 'cursor-2');
    expect(page.stories, hasLength(1));
    expect(page.stories.first.isLive, isTrue);
    expect(page.posts, hasLength(3));
    expect(page.posts[0].postType, FeedPostType.update);
    expect(page.posts[0].update?.text, 'Semester results published.');
    expect(page.posts[1].complaint?.upvotes, 9);
    expect(page.posts[2].poll?.options, hasLength(2));
  });

  test('ignores unknown post types instead of crashing', () {
    final page = HomeFeedPageDto.fromJson({
      'posts': [
        {'id': 'bad-1', 'type': 'UNKNOWN'},
      ],
    });

    expect(page.posts, isEmpty);
  });

  test('maps backend feed contract payloads', () {
    final page = HomeFeedPageDto.fromJson({
      'hasMore': false,
      'items': [
        {
          'id': 'dataset-1',
          'postType': 'RESULT',
          'authorName': 'Anna University',
          'isOrganization': true,
          'createdAt': '2026-06-08T12:00:00',
          'likeCount': 0,
          'commentCount': 0,
          'payload': {
            'domainType': 'EDUCATION',
            'title': 'Campus Education Results',
            'subtitle': 'Published semester result data',
            'badge': 'NEW',
            'workspaceId': 'workspace-1',
            'datasetId': 'dataset-1',
            'isPublic': true,
          },
        },
        {
          'id': 'complaint-2',
          'postType': 'COMPLAINT',
          'authorName': 'Anonymous',
          'createdAt': '2026-06-08T12:05:00',
          'commentCount': 2,
          'payload': {
            'complaintId': 'complaint-2',
            'category': 'campus',
            'title': 'Water issue',
            'description': 'Water supply issue near library block.',
            'status': 'OPEN',
            'upvotes': 7,
            'downvotes': 1,
            'mediaUrls': [],
            'locationName': 'Library Block',
          },
        },
        {
          'id': 'vote-1',
          'postType': 'POLL',
          'authorName': 'ResultHub Community',
          'createdAt': '2026-06-08T12:10:00',
          'likeCount': 7,
          'payload': {
            'voteBoxId': 'vote-1',
            'question': 'Campus facility poll',
            'totalVotes': 7,
            'hasVoted': false,
            'isExpired': false,
            'options': [
              {'id': 'option-1', 'text': 'Library seating', 'voteCount': 4},
              {'id': 'option-2', 'text': 'Lab equipment', 'voteCount': 3},
            ],
          },
        },
      ],
      'liveStories': [
        {
          'id': 'workspace-1',
          'label': 'Feed Education Hub',
          'imageUrl': null,
          'isLive': true,
          'workspaceId': 'workspace-1',
          'domainType': 'CUSTOM',
        },
      ],
    });

    expect(page.hasMore, isFalse);
    expect(page.nextCursor, isNull);
    expect(page.stories.single.label, 'Feed Education Hub');
    expect(page.posts, hasLength(3));
    expect(page.posts[0].result?.datasetId, 'dataset-1');
    expect(page.posts[0].result?.workspaceId, 'workspace-1');
    expect(page.posts[1].complaint?.locationName, 'Library Block');
    expect(page.posts[1].commentCount, 2);
    expect(page.posts[2].poll?.totalVotes, 7);
    expect(page.posts[2].poll?.options.last.text, 'Lab equipment');
  });

  test('normalizes backend media paths using API base URL', () {
    final page = HomeFeedPageDto.fromJson({
      'items': [
        {
          'id': 'image-post-1',
          'postType': 'IMAGE',
          'authorName': 'ResultHub User',
          'createdAt': '2026-06-08T12:00:00',
          'payload': {
            'text': 'Campus photo',
            'mediaUrls': ['/api/v1/posts/media/post-1/photo.jpg'],
          },
        },
        {
          'id': 'complaint-3',
          'postType': 'COMPLAINT',
          'authorName': 'Anonymous',
          'createdAt': '2026-06-08T12:05:00',
          'payload': {
            'complaintId': 'complaint-3',
            'category': 'campus',
            'title': 'Broken pipe',
            'description': 'Pipe is leaking',
            'mediaUrls': ['complaint-3/leak.jpg'],
          },
        },
      ],
    }, apiBaseUrl: 'http://localhost:8080/api/v1');

    expect(
      page.posts.first.update?.mediaUrls.single,
      'http://localhost:8080/api/v1/posts/media/post-1/photo.jpg',
    );
    expect(
      page.posts.last.complaint?.mediaUrls.single,
      'http://localhost:8080/api/v1/complaints/media/complaint-3/leak.jpg',
    );
  });
}
