import '../domain/create_post_tab.dart';

class CreatePostDraft {
  final CreatePostTab tab;
  final String updateText;
  final int mediaCount;
  final String complaintTitle;
  final String complaintDescription;
  final String complaintCategory;
  final String pollQuestion;
  final List<String> pollOptions;

  const CreatePostDraft({
    required this.tab,
    this.updateText = '',
    this.mediaCount = 0,
    this.complaintTitle = '',
    this.complaintDescription = '',
    this.complaintCategory = '',
    this.pollQuestion = '',
    this.pollOptions = const [],
  });
}

class CreatePostValidator {
  const CreatePostValidator();

  bool canPost(CreatePostDraft draft) {
    switch (draft.tab) {
      case CreatePostTab.update:
        return draft.updateText.trim().isNotEmpty || draft.mediaCount > 0;
      case CreatePostTab.complaint:
        return draft.complaintTitle.trim().isNotEmpty &&
            draft.complaintDescription.trim().isNotEmpty &&
            draft.complaintCategory.trim().isNotEmpty;
      case CreatePostTab.poll:
        return draft.pollQuestion.trim().isNotEmpty &&
            draft.pollOptions
                    .where((option) => option.trim().isNotEmpty)
                    .length >=
                2;
    }
  }
}
