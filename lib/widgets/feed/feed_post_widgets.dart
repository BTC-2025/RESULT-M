import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/feed_post_model.dart';
import '../../core/theme/app_theme.dart';

// ─── Unified Post Shell ───────────────────────────────────────────────────────
class FeedPostShell extends StatelessWidget {
  final FeedPost post;
  final Widget content;
  final Color accentColor;
  final Widget? badge;
  final Widget? customFooter;

  const FeedPostShell({
    super.key,
    required this.post,
    required this.content,
    required this.accentColor,
    this.badge,
    this.customFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/public/${post.authorName}?name=${Uri.encodeComponent(post.authorName)}'),
                  child: _OrgAvatar(name: post.authorName, color: accentColor, imageUrl: post.authorAvatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.authorName,
                              style: TextStyle(color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.isOrganization) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified, color: context.colors.blue, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeAgo(post.createdAt),
                        style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (badge != null) badge!,
              ],
            ),
          ),

          // Content
          content,

          // Footer
          customFooter ?? _EngagementRow(post: post),
        ],
      ),
    );
  }
}

// ─── Live Score Post ──────────────────────────────────────────────────────────
class LiveScorePost extends StatelessWidget {
  final FeedPost post;
  const LiveScorePost({super.key, required this.post});

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
          Text(data.eventTitle, style: TextStyle(
            color: context.colors.inkMuted, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 0.8,
          )),
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
                    Text(data.teamA, style: TextStyle(color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(data.scoreA, style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.colors.bg,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Text(
                    data.status ?? 'VS',
                    style: TextStyle(
                      color: data.isLive ? context.colors.liveRed : context.colors.inkMuted,
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
                      Text(data.teamB!, style: TextStyle(color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(data.scoreB ?? '—', style: TextStyle(color: context.colors.inkMuted, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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
      badge: data.isLive ? const LiveBadge() : null,
      content: content,
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
  const ResultPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final data = post.result!;
    final color = _domainColor(context, data.domainType);

    Widget? badge;
    if (data.badge != null) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: context.colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: context.colors.orange.withValues(alpha: 0.4)),
        ),
        child: Text(data.badge!, style: TextStyle(
          color: context.colors.orange, fontSize: 9,
          fontWeight: FontWeight.w900, letterSpacing: 1,
        )),
      );
    }

    final content = Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
                      errorBuilder: (ctx, _, __) => Icon(_domainIcon(data.domainType), color: color, size: 24),
                    ),
                  )
                : Icon(_domainIcon(data.domainType), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: TextStyle(color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w800, height: 1.3)),
                const SizedBox(height: 5),
                Text(data.subtitle, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.inkFaint, size: 20),
        ],
      ),
    );

    return FeedPostShell(
      post: post,
      accentColor: color,
      badge: badge,
      content: content,
    );
  }

  Color _domainColor(BuildContext context, String dt) {
    switch (dt) {
      case 'ACADEMIC':
      case 'ACADEMIC_HUB': return context.colors.purple;
      case 'SCHOOL_HUB':   return context.colors.teal;
      case 'SPORT':        return context.colors.green;
      case 'ELECTION':     return context.colors.blue;
      case 'FINANCE':      return context.colors.amber;
      case 'LAW':          return context.colors.pink;
      default:             return context.colors.orange;
    }
  }

  IconData _domainIcon(String dt) {
    switch (dt) {
      case 'ACADEMIC':
      case 'ACADEMIC_HUB': return Icons.school;
      case 'SCHOOL_HUB':   return Icons.backpack;
      case 'SPORT':        return Icons.sports_cricket;
      case 'ELECTION':     return Icons.how_to_vote;
      case 'FINANCE':      return Icons.trending_up;
      case 'LAW':          return Icons.gavel;
      default:             return Icons.article;
    }
  }
}

// ─── Poll Post ────────────────────────────────────────────────────────────────
class PollPost extends StatelessWidget {
  final FeedPost post;
  final ValueChanged<String> onVote;

  const PollPost({super.key, required this.post, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final data  = post.poll!;
    final total = data.totalVotes == 0 ? 1 : data.totalVotes;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Text(data.question, style: TextStyle(
            color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w800, height: 1.3,
          )),
        ),
        // Options
        ...data.options.map((option) {
          final pct = (option.voteCount / total * 100).round();
          final isVoted = data.userVotedOptionId == option.id;

          return GestureDetector(
            onTap: data.hasVoted || data.isExpired ? null : () => onVote(option.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: isVoted ? context.colors.purple : context.colors.border,
                  width: isVoted ? 1.5 : 1,
                ),
                color: context.colors.bg,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm - 1),
                child: Stack(
                  children: [
                    if (data.hasVoted)
                      FractionallySizedBox(
                        widthFactor: pct / 100,
                        child: Container(
                          color: isVoted ? context.colors.purple.withValues(alpha: 0.2) : context.colors.surfaceAlt,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(option.text, style: TextStyle(
                              color: isVoted ? context.colors.ink : context.colors.inkMuted,
                              fontSize: 13,
                              fontWeight: isVoted ? FontWeight.w800 : FontWeight.w600,
                            )),
                          ),
                          if (data.hasVoted)
                            Text('$pct%', style: TextStyle(
                              color: isVoted ? context.colors.purple : context.colors.inkFaint,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            )),
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
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: Row(
            children: [
              Text(
                '${_formatCount(data.totalVotes)} votes',
                style: TextStyle(color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              if (data.endsAt != null && !data.isExpired) ...[
                Text(' · ', style: TextStyle(color: context.colors.inkFaint)),
                Text(
                  _timeUntil(data.endsAt!),
                  style: TextStyle(color: context.colors.inkFaint, fontSize: 11),
                ),
              ],
              if (data.isExpired)
                Text(' · Closed', style: TextStyle(color: context.colors.liveRed, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );

    return FeedPostShell(
      post: post,
      accentColor: context.colors.purple,
      badge: AppChip(label: 'POLL', icon: Icons.poll, color: context.colors.purple),
      content: content,
    );
  }
}

// ─── Complaint Post ───────────────────────────────────────────────────────────
class ComplaintPost extends StatelessWidget {
  final FeedPost post;
  final ValueChanged<String> onVote;

  const ComplaintPost({super.key, required this.post, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final data  = post.complaint!;
    final color = _statusColor(context, data.status);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: TextStyle(
                color: context.colors.ink, fontSize: 16,
                fontWeight: FontWeight.w800, height: 1.3,
              )),
              const SizedBox(height: 6),
              Text(
                data.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.inkMuted, fontSize: 13, height: 1.5,
                ),
              ),
              if (data.locationName != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.location_on, color: context.colors.inkFaint, size: 13),
                  const SizedBox(width: 4),
                  Text(data.locationName!, style: TextStyle(
                    color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w600,
                  )),
                ]),
              ],
            ],
          ),
        ),
      ],
    );

    final customFooter = Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          _VoteButton(
            icon: Icons.arrow_upward_rounded,
            count: data.upvotes,
            active: data.userVote == 'UP',
            activeColor: context.colors.green,
            onTap: () => onVote('UP'),
          ),
          const SizedBox(width: 10),
          _VoteButton(
            icon: Icons.arrow_downward_rounded,
            count: data.downvotes,
            active: data.userVote == 'DOWN',
            activeColor: context.colors.liveRed,
            onTap: () => onVote('DOWN'),
          ),
          const Spacer(),
          Row(children: [
            Icon(Icons.chat_bubble_outline, color: context.colors.inkFaint, size: 16),
            const SizedBox(width: 5),
            Text(post.commentCount.toString(), style: TextStyle(
              color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w700,
            )),
          ]),
          const SizedBox(width: 14),
          Icon(Icons.share_outlined, color: context.colors.inkFaint, size: 18),
        ],
      ),
    );

    final badge = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(_statusLabel(data.status), style: TextStyle(
            color: color, fontSize: 9,
            fontWeight: FontWeight.w900, letterSpacing: 0.8,
          )),
        ),
        const SizedBox(height: 4),
        AppChip(label: data.category, color: context.colors.amber),
      ],
    );

    return FeedPostShell(
      post: post,
      accentColor: context.colors.amber,
      badge: badge,
      content: content,
      customFooter: customFooter,
    );
  }

  Color _statusColor(BuildContext context, String s) {
    switch (s) {
      case 'RESOLVED':     return context.colors.green;
      case 'UNDER_REVIEW': return context.colors.blue;
      default:             return context.colors.amber;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'RESOLVED':     return 'RESOLVED';
      case 'UNDER_REVIEW': return 'UNDER REVIEW';
      default:             return 'OPEN';
    }
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.count,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.15) : context.colors.bg,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: active ? activeColor.withValues(alpha: 0.3) : context.colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? activeColor : context.colors.inkMuted),
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(
                color: active ? activeColor : context.colors.inkMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Components ──────────────────────────────────────────────────────


class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const AppChip({super.key, required this.label, this.icon, required this.color});

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
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  final FeedPost post;
  const _EngagementRow({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: context.colors.inkFaint, size: 18),
          const SizedBox(width: 5),
          Text(_formatCount(post.likeCount), style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.push('/post/details/${post.id}'),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: context.colors.inkFaint, size: 16),
                const SizedBox(width: 5),
                Text(post.commentCount.toString(), style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Spacer(),
          Icon(Icons.share_outlined, color: context.colors.inkFaint, size: 18),
          const SizedBox(width: 14),
          Icon(Icons.bookmark_border, color: context.colors.inkFaint, size: 18),
        ],
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1)  return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24)   return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String _timeUntil(DateTime dt) {
  final diff = dt.difference(DateTime.now());
  if (diff.isNegative) return 'Closed';
  if (diff.inHours >= 24) return '${diff.inDays}d left';
  if (diff.inHours >= 1)  return '${diff.inHours}h left';
  return '${diff.inMinutes}m left';
}

String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
