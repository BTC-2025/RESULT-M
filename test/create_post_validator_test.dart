import 'package:flutter_test/flutter_test.dart';
import 'package:result_publishing_app/features/home/application/create_post_validator.dart';
import 'package:result_publishing_app/features/home/domain/create_post_tab.dart';

void main() {
  const validator = CreatePostValidator();

  test('update can be posted with text or media', () {
    expect(
      validator.canPost(
        const CreatePostDraft(tab: CreatePostTab.update, updateText: 'Hello'),
      ),
      isTrue,
    );
    expect(
      validator.canPost(
        const CreatePostDraft(tab: CreatePostTab.update, mediaCount: 1),
      ),
      isTrue,
    );
    expect(
      validator.canPost(const CreatePostDraft(tab: CreatePostTab.update)),
      isFalse,
    );
  });

  test('complaint requires title, description, and category', () {
    expect(
      validator.canPost(
        const CreatePostDraft(
          tab: CreatePostTab.complaint,
          complaintTitle: 'Road damaged',
          complaintDescription: 'Large pothole near the bus stop',
          complaintCategory: 'Infrastructure',
        ),
      ),
      isTrue,
    );
    expect(
      validator.canPost(
        const CreatePostDraft(
          tab: CreatePostTab.complaint,
          complaintTitle: 'Road damaged',
          complaintCategory: 'Infrastructure',
        ),
      ),
      isFalse,
    );
  });

  test('poll requires a question and at least two options', () {
    expect(
      validator.canPost(
        const CreatePostDraft(
          tab: CreatePostTab.poll,
          pollQuestion: 'Which feature first?',
          pollOptions: ['Live results', 'Complaints'],
        ),
      ),
      isTrue,
    );
    expect(
      validator.canPost(
        const CreatePostDraft(
          tab: CreatePostTab.poll,
          pollQuestion: 'Which feature first?',
          pollOptions: ['Live results', ''],
        ),
      ),
      isFalse,
    );
  });
}
