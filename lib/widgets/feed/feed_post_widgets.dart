import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/share_links.dart';
import '../../models/feed_post_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/time_formatter.dart';

// ─── Unified Post Shell ───────────────────────────────────────────────────────
class FeedPostShell extends StatelessWidget {
  final FeedPost post;
  final Widget content;
  final Color accentColor;
  final Widget? badge;
  final Widget? customFooter;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const FeedPostShell({
    super.key,
    required this.post,
    required this.content,
    required this.accentColor,
    this.badge,
    this.customFooter,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (post.creatorId != null) {
                    context.push('/profile/public/${post.creatorId}?name=${Uri.encodeComponent(post.authorName)}');
                  } else {
                    // Fallback to name-based profile or handle error
                    context.push('/profile/public/${post.authorName}?name=${Uri.encodeComponent(post.authorName)}');
                  }
                },
                child: _OrgAvatar(
                  name: post.authorName,
                  color: accentColor,
                  imageUrl: post.authorAvatarUrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: TextStyle(
                              color: context.colors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.isOrganization) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: context.colors.blue,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (badge != null) ...[
                          badge!,
                          const SizedBox(width: 7),
                        ],
                        Flexible(
                          child: Text(
                            '• ${TimeFormatter.timeAgo(post.createdAt)}',
                            style: TextStyle(
                              color: context.colors.inkMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPostMenu(context),
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: context.colors.inkMuted,
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          content,

          const SizedBox(height: 6),
          customFooter ??
              _EngagementRow(
                post: post,
                onLike: onLike,
                onComment: onComment,
                onShare: onShare,
                onSave: onSave,
              ),
        ],
      ),
    );
  }

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.share_outlined,
                color: context.colors.inkMuted,
              ),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                SharePlus.instance.share(
                  ShareParams(text: ShareLinks.post(post.id)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.link_rounded, color: context.colors.inkMuted),
              title: const Text('Copy link'),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: ShareLinks.post(post.id)),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: context.colors.liveRed),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Live Score Post ──────────────────────────────────────────────────────────
class LiveScorePost extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const LiveScorePost({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.liveScore!;
    final isElection = data.domainType == 'ELECTION';
    final accentColor = isElection ? context.colors.blue : context.colors.green;

    final content = Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.12),
            context.colors.surfaceAlt,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            data.eventTitle,
            style: TextStyle(
              color: context.colors.inkMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (data.logoUrlA != null)
                      ClipOval(
                        child: Image.network(
                          data.logoUrlA!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Text(
                            isElection ? '🏛️' : _teamEmoji(data.teamA),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      )
                    else
                      Text(
                        isElection ? '🏛️' : _teamEmoji(data.teamA),
                        style: const TextStyle(fontSize: 28),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      data.teamA,
                      style: TextStyle(
                        color: context.colors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.scoreA,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.bg,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Text(
                    data.status ?? 'VS',
                    style: TextStyle(
                      color: data.isLive
                          ? context.colors.liveRed
                          : context.colors.inkMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              if (data.teamB != null)
                Expanded(
                  child: Column(
                    children: [
                      if (data.logoUrlB != null)
                        ClipOval(
                          child: Image.network(
                            data.logoUrlB!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, _, __) => Text(
                              isElection ? '🏛️' : _teamEmoji(data.teamB!),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        )
                      else
                        Text(
                          isElection ? '🏛️' : _teamEmoji(data.teamB!),
                          style: const TextStyle(fontSize: 28),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        data.teamB!,
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.scoreB ?? '—',
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return FeedPostShell(
      post: post,
      accentColor: accentColor,
      badge: AppChip(label: 'LIVE', color: context.colors.teal),
      content: content,
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onSave: onSave,
    );
  }

  String _teamEmoji(String name) {
    final n = name.toUpperCase();
    if (n.contains('MI') || n.contains('MUMBAI')) return '🔵';
    if (n.contains('CSK') || n.contains('CHENNAI')) return '🟡';
    if (n.contains('RCB')) return '🔴';
    if (n.contains('F1') || n.contains('RACE')) return '🏎️';
    return '⚡';
  }
}

// ─── Result Post ──────────────────────────────────────────────────────────────
class ResultPost extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onOpenDetail;

  const ResultPost({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.result!;
    final color = _domainColor(context, data.domainType);

    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: data.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: Image.network(
                      data.logoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Icon(
                        _domainIcon(data.domainType),
                        color: color,
                        size: 24,
                      ),
                    ),
                  )
                : Icon(_domainIcon(data.domainType), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onOpenDetail,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.inkFaint, size: 20),
        ],
      ),
    );

    return FeedPostShell(
      post: post,
      accentColor: color,
      badge: AppChip(label: 'UPDATE', color: context.colors.teal),
      content: content,
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onSave: onSave,
    );
  }

  Color _domainColor(BuildContext context, String dt) {
    switch (dt) {
      case 'ACADEMIC':
      case 'ACADEMIC_HUB':
        return context.colors.purple;
      case 'SCHOOL_HUB':
        return context.colors.teal;
      case 'SPORT':
        return context.colors.green;
      case 'ELECTION':
        return context.colors.blue;
      case 'FINANCE':
        return context.colors.amber;
      case 'LAW':
        return context.colors.pink;
      default:
        return context.colors.orange;
    }
  }

  IconData _domainIcon(String dt) {
    switch (dt) {
      case 'ACADEMIC':
      case 'ACADEMIC_HUB':
        return Icons.school;
      case 'SCHOOL_HUB':
        return Icons.backpack;
      case 'SPORT':
        return Icons.sports_cricket;
      case 'ELECTION':
        return Icons.how_to_vote;
      case 'FINANCE':
        return Icons.trending_up;
      case 'LAW':
        return Icons.gavel;
      default:
        return Icons.article;
    }
  }
}

// ─── Poll Post ────────────────────────────────────────────────────────────────
class UpdatePost extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onOpenDetail;

  const UpdatePost({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.update!;
    final isMediaPost = data.mediaUrls.isNotEmpty && data.text.trim().isEmpty;
    final hasLongText = data.text.trim().length > 180;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.text.trim().isNotEmpty) ...[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onOpenDetail,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.text,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 15,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasLongText) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: context.colors.purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (data.mediaUrls.isNotEmpty) ...[
          FeedMediaGallery(mediaUrls: data.mediaUrls),
          const SizedBox(height: 12),
        ],
        if (data.locationName != null || data.category != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (data.locationName != null)
                AppChip(
                  label: data.locationName!,
                  icon: Icons.location_on_rounded,
                  color: context.colors.teal,
                ),
              if (data.category != null)
                AppChip(
                  label: data.category!,
                  icon: Icons.sell_rounded,
                  color: context.colors.purple,
                ),
            ],
          ),
      ],
    );

    return FeedPostShell(
      post: post,
      accentColor: isMediaPost ? context.colors.purple : context.colors.teal,
      badge: AppChip(
        label: isMediaPost ? 'IMAGE' : 'UPDATE',
        color: isMediaPost ? context.colors.purple : context.colors.teal,
      ),
      content: content,
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onSave: onSave,
    );
  }
}

class PollPost extends StatelessWidget {
  final FeedPost post;
  final ValueChanged<String> onVote;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onOpenDetail;

  const PollPost({
    super.key,
    required this.post,
    required this.onVote,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.poll!;
    final total = data.totalVotes == 0 ? 1 : data.totalVotes;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onOpenDetail,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Text(
              data.question,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.32,
              ),
            ),
          ),
        ),
        // Options
        ...data.options.map((option) {
          final pct = (option.voteCount / total * 100).round();
          final isVoted = data.userVotedOptionId == option.id;

          return GestureDetector(
            onTap: data.hasVoted || data.isExpired
                ? null
                : () => onVote(option.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isVoted
                      ? context.colors.purple
                      : context.colors.border,
                  width: isVoted ? 1.5 : 1,
                ),
                color: context.colors.surfaceAlt.withValues(alpha: 0.55),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Stack(
                  children: [
                    if (data.hasVoted)
                      FractionallySizedBox(
                        widthFactor: pct / 100,
                        child: Container(
                          color: isVoted
                              ? context.colors.teal.withValues(alpha: 0.22)
                              : context.colors.purple.withValues(alpha: 0.10),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.text,
                              style: TextStyle(
                                color: isVoted
                                    ? context.colors.ink
                                    : context.colors.inkMuted,
                                fontSize: 13,
                                fontWeight: isVoted
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (data.hasVoted)
                            Text(
                              '$pct%',
                              style: TextStyle(
                                color: isVoted
                                    ? context.colors.purple
                                    : context.colors.inkFaint,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          else
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.colors.inkFaint,
                                  width: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        // Votes count + expiry
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: context.colors.inkFaint,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                '${_formatCount(data.totalVotes)} votes',
                style: TextStyle(
                  color: context.colors.inkFaint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (data.endsAt != null && !data.isExpired) ...[
                Text(' · ', style: TextStyle(color: context.colors.inkFaint)),
                Text(
                  TimeFormatter.timeUntil(data.endsAt!),
                  style: TextStyle(
                    color: context.colors.inkFaint,
                    fontSize: 11,
                  ),
                ),
              ],
              if (data.isExpired)
                Text(
                  ' · Closed',
                  style: TextStyle(
                    color: context.colors.liveRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return FeedPostShell(
      post: post,
      accentColor: context.colors.purple,
      badge: AppChip(label: 'POLL', color: context.colors.purple),
      content: content,
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onSave: onSave,
    );
  }
}

// ─── Complaint Post ───────────────────────────────────────────────────────────
class ComplaintPost extends StatelessWidget {
  final FeedPost post;
  final ValueChanged<String> onVote;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onOpenDetail;

  const ComplaintPost({
    super.key,
    required this.post,
    required this.onVote,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.complaint!;
    final color = _statusColor(context, data.status);
    final hasLongDescription = data.description.trim().length > 170;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onOpenDetail,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.32,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                data.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.inkMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (hasLongDescription) ...[
                const SizedBox(height: 6),
                Text(
                  'Read more',
                  style: TextStyle(
                    color: context.colors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (data.locationName != null) ...[
          const SizedBox(height: 10),
          AppChip(
            label: data.locationName!,
            icon: Icons.location_on_rounded,
            color: context.colors.teal,
          ),
        ],
        if (data.mediaUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          FeedMediaGallery(mediaUrls: data.mediaUrls.take(2).toList()),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            _StatusPill(label: _statusLabel(data.status), color: color),
            const SizedBox(width: 8),
            AppChip(label: data.category, color: context.colors.amber),
          ],
        ),
      ],
    );

    final customFooter = Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                _VoteIcon(
                  icon: Icons.arrow_upward_rounded,
                  active: data.userVote == 'UP',
                  activeColor: context.colors.teal,
                  onTap: () => onVote('UP'),
                ),
                _VoteCount(
                  count: data.upvotes,
                  color: data.userVote == 'UP'
                      ? context.colors.teal
                      : context.colors.inkMuted,
                ),
                Container(
                  width: 1,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: context.colors.border,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.35),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: _VoteCount(
                    key: ValueKey('down-${data.downvotes}'),
                    count: data.downvotes,
                    color: data.userVote == 'DOWN'
                        ? context.colors.liveRed
                        : context.colors.inkMuted,
                  ),
                ),
                _VoteIcon(
                  icon: Icons.arrow_downward_rounded,
                  active: data.userVote == 'DOWN',
                  activeColor: context.colors.liveRed,
                  onTap: () => onVote('DOWN'),
                ),
              ],
            ),
          ),
          const Spacer(),
          _ActionIcon(
            icon: Icons.mode_comment_outlined,
            count: post.commentCount,
            compact: true,
            onTap: onComment,
          ),
          _ActionIcon(
            icon: Icons.ios_share_rounded,
            compact: true,
            onTap:
                onShare ??
                () => SharePlus.instance.share(
                  ShareParams(text: ShareLinks.post(post.id)),
                ),
          ),
          _ActionIcon(
            icon: Icons.bookmark_border_rounded,
            compact: true,
            onTap: onSave,
          ),
        ],
      ),
    );

    return FeedPostShell(
      post: post,
      accentColor: context.colors.amber,
      badge: AppChip(label: 'COMPLAINT', color: context.colors.liveRed),
      content: content,
      customFooter: customFooter,
    );
  }

  Color _statusColor(BuildContext context, String s) {
    switch (s) {
      case 'RESOLVED':
        return context.colors.green;
      case 'UNDER_REVIEW':
        return context.colors.blue;
      default:
        return context.colors.amber;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'RESOLVED':
        return 'RESOLVED';
      case 'UNDER_REVIEW':
        return 'UNDER REVIEW';
      default:
        return 'OPEN';
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VoteIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteIcon({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.14)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: active ? activeColor : context.colors.inkMuted,
        ),
      ),
    );
  }
}

class _VoteCount extends StatelessWidget {
  final int count;
  final Color color;

  const _VoteCount({super.key, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        _formatCount(count),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Reusable Components ──────────────────────────────────────────────────────

class FeedMediaGallery extends StatelessWidget {
  final List<String> mediaUrls;
  final double singleHeight;
  final double maxSingleHeight;

  const FeedMediaGallery({
    super.key,
    required this.mediaUrls,
    this.singleHeight = 200,
    this.maxSingleHeight = 520,
  });

  @override
  Widget build(BuildContext context) {
    final items = mediaUrls.where((url) => url.trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    if (items.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: _SingleMediaFrame(
          path: items.first,
          minHeight: singleHeight,
          maxHeight: maxSingleHeight,
        ),
      );
    }

    return GridView.builder(
      itemCount: items.length > 4 ? 4 : items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final remaining = items.length - 4;
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _MediaTile(path: items[index]),
              if (index == 3 && remaining > 0)
                Container(
                  color: Colors.black.withValues(alpha: 0.46),
                  alignment: Alignment.center,
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SingleMediaFrame extends StatelessWidget {
  final String path;
  final double minHeight;
  final double maxHeight;

  const _SingleMediaFrame({
    required this.path,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        final lower = minHeight.clamp(180.0, maxHeight);
        final upper = maxHeight.clamp(lower, 620.0);

        if (_isVideo(path)) {
          return SizedBox(
            width: double.infinity,
            height: lower.toDouble(),
            child: _MediaTile(path: path),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: lower.toDouble(),
            maxHeight: upper.toDouble(),
          ),
          child: _AspectAwareImage(
            path: path,
            width: width,
            minHeight: lower.toDouble(),
            maxHeight: upper.toDouble(),
          ),
        );
      },
    );
  }

  bool _isVideo(String value) {
    final lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');
  }
}

class _AspectAwareImage extends StatelessWidget {
  final String path;
  final double width;
  final double minHeight;
  final double maxHeight;

  const _AspectAwareImage({
    required this.path,
    required this.width,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (_isRemote(path)) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null && !wasSynchronouslyLoaded) {
            return SizedBox(height: minHeight, child: _placeholder(context));
          }
          return child;
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(height: minHeight, child: _placeholder(context));
        },
        errorBuilder: (_, __, ___) =>
            SizedBox(height: minHeight, child: _placeholder(context)),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          SizedBox(height: minHeight, child: _placeholder(context)),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      color: context.colors.surfaceAlt,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_rounded,
        color: context.colors.inkMuted,
        size: 28,
      ),
    );
  }

  bool _isRemote(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }
}

class _MediaTile extends StatelessWidget {
  final String path;
  const _MediaTile({required this.path});

  @override
  Widget build(BuildContext context) {
    if (_isVideo(path)) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _placeholder(context, icon: Icons.videocam_rounded),
          Center(
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black.withValues(alpha: 0.45),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      );
    }

    if (_isRemote(path)) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(
    BuildContext context, {
    IconData icon = Icons.image_rounded,
  }) {
    return Container(
      color: context.colors.surfaceAlt,
      alignment: Alignment.center,
      child: Icon(icon, color: context.colors.inkMuted, size: 28),
    );
  }

  bool _isRemote(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  bool _isVideo(String value) {
    final lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const _EngagementRow({
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ActionIcon(
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                activeColor: context.colors.liveRed,
                isActive: post.isLiked,
                count: post.likeCount,
                onTap: onLike,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ActionIcon(
                icon: Icons.mode_comment_outlined,
                count: post.commentCount,
                onTap: onComment,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _ActionIcon(
                icon: Icons.ios_share_rounded,
                onTap:
                    onShare ??
                    () => SharePlus.instance.share(
                      ShareParams(text: ShareLinks.post(post.id)),
                    ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _ActionIcon(
                icon: post.isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                activeColor: context.colors.purple,
                isActive: post.isSaved,
                onTap: onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;
  final bool compact;
  final bool isActive;
  final Color? activeColor;

  const _ActionIcon({
    required this.icon,
    this.count,
    this.onTap,
    this.compact = false,
    this.isActive = false,
    this.activeColor,
  });

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: widget.compact ? 34 : 36,
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 9 : 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: widget.isActive
            ? (widget.activeColor?.withValues(alpha: 0.12) ??
                  context.colors.surfaceAlt.withValues(alpha: 0.56))
            : context.colors.surfaceAlt.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Icon(
              widget.icon,
              color: widget.isActive
                  ? (widget.activeColor ?? context.colors.inkMuted)
                  : context.colors.inkMuted,
              size: 18,
            ),
          ),
          if (widget.count != null) ...[
            const SizedBox(width: 5),
            Text(
              _formatCount(widget.count!),
              style: TextStyle(
                color: widget.isActive
                    ? (widget.activeColor ?? context.colors.inkMuted)
                    : context.colors.inkMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(right: widget.compact ? 6 : 8),
      child: InkWell(
        onTap: () {
          _controller.forward(from: 0);
          widget.onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: child,
      ),
    );
  }
}

class _OrgAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final String? imageUrl;
  const _OrgAvatar({required this.name, required this.color, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Center(
                child: Text(
                  _avatarLetter,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                _avatarLetter,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }

  String get _avatarLetter {
    if (name.toLowerCase() == 'anonymous') return '?';
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}



String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
