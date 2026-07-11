/// Unified feed post model — discriminated union via [postType]
class FeedPost {
  final String id;
  final FeedPostType postType;
  final String? creatorId;
  final String authorName;
  final String? authorAvatarUrl;
  final bool isOrganization;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;

  // ── Type-specific payloads ──
  final LiveScorePayload? liveScore;
  final ResultPayload? result;
  final UpdatePayload? update;
  final PollPayload? poll;
  final ComplaintPayload? complaint;

  const FeedPost({
    required this.id,
    required this.postType,
    this.creatorId,
    required this.authorName,
    required this.createdAt,
    this.authorAvatarUrl,
    this.isOrganization = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.liveScore,
    this.result,
    this.update,
    this.poll,
    this.complaint,
  });
}

enum FeedPostType { liveScore, result, update, poll, complaint }

// ─── Live Score (Sport / Election) ───────────────────────────────────────────
class LiveScorePayload {
  final String domainType; // 'SPORT' | 'ELECTION' | etc.
  final String eventTitle;
  final String teamA;
  final String? teamB;
  final String scoreA;
  final String? scoreB;
  final String? logoUrlA;
  final String? logoUrlB;
  final String? status; // 'LIVE', 'HT', 'FT', 'Innings 2'
  final bool isLive;
  final String? workspaceId;

  const LiveScorePayload({
    required this.domainType,
    required this.eventTitle,
    required this.teamA,
    required this.scoreA,
    this.teamB,
    this.scoreB,
    this.logoUrlA,
    this.logoUrlB,
    this.status,
    this.isLive = false,
    this.workspaceId,
  });
}

// ─── Result (Exam / Government) ──────────────────────────────────────────────
class ResultPayload {
  final String domainType;
  final String title;
  final String subtitle;
  final String? logoUrl;
  final String? badge; // 'NEW', 'UPDATED'
  final String? workspaceId;
  final String? datasetId;
  final bool isPublic;

  const ResultPayload({
    required this.domainType,
    required this.title,
    required this.subtitle,
    this.logoUrl,
    this.badge,
    this.workspaceId,
    this.datasetId,
    this.isPublic = false,
  });
}

// ─── Poll (Voting Hub) ────────────────────────────────────────────────────────
class UpdatePayload {
  final String text;
  final List<String> mediaUrls;
  final String? locationName;
  final String? category;
  final bool hasVideo;

  const UpdatePayload({
    required this.text,
    this.mediaUrls = const [],
    this.locationName,
    this.category,
    this.hasVideo = false,
  });
}

class PollPayload {
  final String voteBoxId;
  final String question;
  final List<PollOption> options;
  final int totalVotes;
  final bool hasVoted;
  final String? userVotedOptionId;
  final DateTime? endsAt;
  final bool isExpired;

  const PollPayload({
    required this.voteBoxId,
    required this.question,
    required this.options,
    required this.totalVotes,
    this.hasVoted = false,
    this.userVotedOptionId,
    this.endsAt,
    this.isExpired = false,
  });

  PollPayload copyWithVote(String optionId) {
    final updated = options
        .map(
          (o) => PollOption(
            id: o.id,
            text: o.text,
            voteCount: o.id == optionId ? o.voteCount + 1 : o.voteCount,
          ),
        )
        .toList();
    return PollPayload(
      voteBoxId: voteBoxId,
      question: question,
      options: updated,
      totalVotes: totalVotes + 1,
      hasVoted: true,
      userVotedOptionId: optionId,
      endsAt: endsAt,
      isExpired: isExpired,
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.text,
    required this.voteCount,
  });
}

// ─── Complaint ────────────────────────────────────────────────────────────────
class ComplaintPayload {
  final String complaintId;
  final String category;
  final String title;
  final String description;
  final String status;
  final int upvotes;
  final int downvotes;
  final List<String> mediaUrls;
  final String? locationName;
  final String? userVote; // 'UP' | 'DOWN' | null

  const ComplaintPayload({
    required this.complaintId,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    required this.upvotes,
    required this.downvotes,
    this.mediaUrls = const [],
    this.locationName,
    this.userVote,
  });

  ComplaintPayload copyWithVote(String voteType) {
    final normalized = voteType.toUpperCase();
    final current = userVote?.toUpperCase();
    final togglingOff = current == normalized;
    final nextUserVote = togglingOff ? null : normalized;
    final upDelta = switch ((current, normalized, togglingOff)) {
      ('UP', 'UP', true) => -1,
      ('DOWN', 'UP', false) => 1,
      (null, 'UP', false) => 1,
      ('UP', 'DOWN', false) => -1,
      _ => 0,
    };
    final downDelta = switch ((current, normalized, togglingOff)) {
      ('DOWN', 'DOWN', true) => -1,
      ('UP', 'DOWN', false) => 1,
      (null, 'DOWN', false) => 1,
      ('DOWN', 'UP', false) => -1,
      _ => 0,
    };
    return ComplaintPayload(
      complaintId: complaintId,
      category: category,
      title: title,
      description: description,
      status: status,
      upvotes: (upvotes + upDelta).clamp(0, 1 << 30),
      downvotes: (downvotes + downDelta).clamp(0, 1 << 30),
      mediaUrls: mediaUrls,
      locationName: locationName,
      userVote: nextUserVote,
    );
  }
}

// ─── Live Story Circle (top of home feed) ────────────────────────────────────
class LiveStory {
  final String id;
  final String label;
  final String? emoji;
  final String? imageUrl;
  final bool isLive;
  final String? workspaceId;
  final String domainType;
  final dynamic payload;

  const LiveStory({
    required this.id,
    required this.label,
    required this.domainType,
    this.emoji,
    this.imageUrl,
    this.isLive = false,
    this.workspaceId,
    this.payload,
  });
}
