class ComplaintModel {
  final String id;
  final String? creatorId;
  final String category;
  final String title;
  final String description;
  final List<String> mediaUrls;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String status;
  final bool isAnonymous;
  final int flagCount;
  final int upvotes;
  final int downvotes;
  final int netScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? hasUserVoted; // "UP", "DOWN", or null
  final int commentCount;

  ComplaintModel({
    required this.id,
    this.creatorId,
    required this.category,
    required this.title,
    required this.description,
    required this.mediaUrls,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.status,
    required this.isAnonymous,
    required this.flagCount,
    required this.upvotes,
    required this.downvotes,
    required this.netScore,
    required this.createdAt,
    required this.updatedAt,
    this.hasUserVoted,
    required this.commentCount,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      creatorId: json['creatorId'],
      category: json['category'],
      title: json['title'],
      description: json['description'],
      mediaUrls: json['mediaUrls'] != null ? List<String>.from(json['mediaUrls']) : [],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationName: json['locationName'],
      status: json['status'] ?? 'OPEN',
      isAnonymous: json['isAnonymous'] ?? false,
      flagCount: json['flagCount'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      netScore: json['netScore'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      hasUserVoted: json['hasUserVoted'],
      commentCount: json['commentCount'] ?? 0,
    );
  }

  // Helper method to create a copy with modifications (useful for optimistic updates)
  ComplaintModel copyWith({
    String? status,
    int? flagCount,
    int? upvotes,
    int? downvotes,
    int? netScore,
    String? hasUserVoted,
    bool clearHasUserVoted = false,
  }) {
    return ComplaintModel(
      id: id,
      creatorId: creatorId,
      category: category,
      title: title,
      description: description,
      mediaUrls: mediaUrls,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      status: status ?? this.status,
      isAnonymous: isAnonymous,
      flagCount: flagCount ?? this.flagCount,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      netScore: netScore ?? this.netScore,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hasUserVoted: clearHasUserVoted ? null : (hasUserVoted ?? this.hasUserVoted),
      commentCount: commentCount,
    );
  }
}
