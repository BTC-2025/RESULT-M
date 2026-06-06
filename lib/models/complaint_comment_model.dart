class ComplaintCommentModel {
  final String id;
  final String content;
  final String creatorName;
  final DateTime createdAt;

  ComplaintCommentModel({
    required this.id,
    required this.content,
    required this.creatorName,
    required this.createdAt,
  });

  factory ComplaintCommentModel.fromJson(Map<String, dynamic> json) {
    return ComplaintCommentModel(
      id: json['id'],
      content: json['content'],
      creatorName: json['creatorName'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
