class VoteOptionModel {
  final String id;
  final String optionText;
  final int? voteCount;

  VoteOptionModel({
    required this.id,
    required this.optionText,
    this.voteCount,
  });

  factory VoteOptionModel.fromJson(Map<String, dynamic> json) {
    return VoteOptionModel(
      id: json['id'],
      optionText: json['optionText'],
      voteCount: json['voteCount'],
    );
  }
}

class VoteBoxModel {
  final String id;
  final String title;
  final String? description;
  final String visibility;
  final bool allowAnonymous;
  final DateTime? endsAt;
  final String? linkedWorkspaceId;
  final bool hideResultsUntilEnd;
  final int totalVotes;
  final DateTime createdAt;
  final List<VoteOptionModel> options;
  final bool hasVoted;
  final String? selectedOptionId;

  VoteBoxModel({
    required this.id,
    required this.title,
    this.description,
    required this.visibility,
    required this.allowAnonymous,
    this.endsAt,
    this.linkedWorkspaceId,
    required this.hideResultsUntilEnd,
    required this.totalVotes,
    required this.createdAt,
    required this.options,
    required this.hasVoted,
    this.selectedOptionId,
  });

  factory VoteBoxModel.fromJson(Map<String, dynamic> json) {
    return VoteBoxModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      visibility: json['visibility'],
      allowAnonymous: json['allowAnonymous'] ?? false,
      endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : null,
      linkedWorkspaceId: json['linkedWorkspaceId'],
      hideResultsUntilEnd: json['hideResultsUntilEnd'] ?? false,
      totalVotes: json['totalVotes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      options: (json['options'] as List?)?.map((o) => VoteOptionModel.fromJson(o)).toList() ?? [],
      hasVoted: json['hasVoted'] ?? false,
      selectedOptionId: json['selectedOptionId'],
    );
  }

  VoteBoxModel copyWith({
    int? totalVotes,
    bool? hasVoted,
    String? selectedOptionId,
    List<VoteOptionModel>? options,
  }) {
    return VoteBoxModel(
      id: id,
      title: title,
      description: description,
      visibility: visibility,
      allowAnonymous: allowAnonymous,
      endsAt: endsAt,
      linkedWorkspaceId: linkedWorkspaceId,
      hideResultsUntilEnd: hideResultsUntilEnd,
      createdAt: createdAt,
      totalVotes: totalVotes ?? this.totalVotes,
      hasVoted: hasVoted ?? this.hasVoted,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      options: options ?? this.options,
    );
  }
}

class VoteResultsModel {
  final String optionId;
  final String optionText;
  final int voteCount;
  final double percentage;

  VoteResultsModel({
    required this.optionId,
    required this.optionText,
    required this.voteCount,
    required this.percentage,
  });

  factory VoteResultsModel.fromJson(Map<String, dynamic> json) {
    return VoteResultsModel(
      optionId: json['optionId'],
      optionText: json['optionText'],
      voteCount: json['voteCount'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}
