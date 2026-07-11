import 'package:flutter_test/flutter_test.dart';
import 'package:result_publishing_app/core/network/api_client.dart';
import 'package:result_publishing_app/core/storage/secure_storage.dart';
import 'package:result_publishing_app/features/home/data/home_feed_repository.dart';
import 'package:result_publishing_app/services/api_service.dart';

void main() {
  final api = ApiService(ApiClient(SecureStorage()));

  test('empty API repository starts with no feed data until endpoint is wired', () {
    final repository = ApiHomeFeedRepository(api);

    final snapshot = repository.initialSnapshot();

    expect(snapshot.posts, isEmpty);
    expect(snapshot.stories, isEmpty);
    expect(snapshot.hasMore, isFalse);
  });
}
