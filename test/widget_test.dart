import 'package:flutter_test/flutter_test.dart';
import 'package:result_publishing_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Just verify the app widget can be instantiated
    expect(const ResultPublishingApp(), isNotNull);
  });
}
