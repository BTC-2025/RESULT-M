enum NotificationType { resultPublished, complaint, pollResult, comment, follower, message }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String linkedId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.linkedId,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      linkedId: linkedId,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationType parsedType = NotificationType.resultPublished;
    switch (json['type']) {
      case 'RESULT_PUBLISHED': parsedType = NotificationType.resultPublished; break;
      case 'COMPLAINT': parsedType = NotificationType.complaint; break;
      case 'POLL_RESULT': parsedType = NotificationType.pollResult; break;
      case 'COMMENT': parsedType = NotificationType.comment; break;
      case 'FOLLOWER': parsedType = NotificationType.follower; break;
      case 'MESSAGE': parsedType = NotificationType.message; break;
    }

    return AppNotification(
      id: json['id'] ?? '',
      type: parsedType,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['read'] ?? json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      linkedId: json['linkedId'] ?? '',
    );
  }
}
