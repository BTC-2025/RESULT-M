import 'package:flutter/material.dart';
import '../models/vote_box_model.dart';
import 'dart:async';
import '../core/theme/app_theme.dart';

class VoteBoxCard extends StatefulWidget {
  final VoteBoxModel voteBox;
  final VoidCallback onTap;

  const VoteBoxCard({
    super.key,
    required this.voteBox,
    required this.onTap,
  });

  @override
  State<VoteBoxCard> createState() => _VoteBoxCardState();
}

class _VoteBoxCardState extends State<VoteBoxCard> {
  Timer? _timer;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _checkExpiration();
    if (!_isExpired && widget.voteBox.endsAt != null) {
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _checkExpiration();
      });
    }
  }

  @override
  void didUpdateWidget(covariant VoteBoxCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voteBox.endsAt != widget.voteBox.endsAt) {
      _checkExpiration();
    }
  }

  void _checkExpiration() {
    if (widget.voteBox.endsAt != null) {
      final expired = DateTime.now().isAfter(widget.voteBox.endsAt!);
      if (expired != _isExpired) {
        setState(() {
          _isExpired = expired;
        });
        if (expired) {
          _timer?.cancel();
        }
      }
    } else {
      if (_isExpired) setState(() => _isExpired = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getTimeRemaining() {
    if (widget.voteBox.endsAt == null) return 'No expiry';
    if (_isExpired) return 'Closed';

    final diff = widget.voteBox.endsAt!.difference(DateTime.now());
    if (diff.inDays > 0) return 'Closes in ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'Closes in ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'Closes in ${diff.inMinutes}m';
  }

  IconData _getVisibilityIcon() {
    switch (widget.voteBox.visibility) {
      case 'PASSWORD_PROTECTED':
        return Icons.lock;
      case 'PRIVATE':
        return Icons.visibility_off;
      case 'PUBLIC':
      default:
        return Icons.public;
    }
  }

  Color _getVisibilityColor() {
    switch (widget.voteBox.visibility) {
      case 'PASSWORD_PROTECTED':
        return context.colors.yellow;
      case 'PRIVATE':
        return context.colors.red;
      case 'PUBLIC':
      default:
        return context.colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadingColor = _isExpired ? context.colors.inkMuted : context.colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: leadingColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: leadingColor.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Icon(Icons.how_to_vote, color: leadingColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppChip(
                          label: widget.voteBox.visibility.replaceAll('_', ' '),
                          color: _getVisibilityColor(),
                          icon: _getVisibilityIcon(),
                        ),
                        AppChip(
                          label: _getTimeRemaining(),
                          color: _isExpired ? context.colors.red : context.colors.blue,
                          icon: _isExpired ? Icons.lock_clock : Icons.timer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.voteBox.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: context.colors.ink,
                  height: 1.2,
                ),
              ),
              if (widget.voteBox.description != null && widget.voteBox.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.voteBox.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.inkMuted,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xs),
                child: LinearProgressIndicator(
                  value: widget.voteBox.totalVotes == 0 ? 0 : 1,
                  minHeight: 7,
                  backgroundColor: context.colors.surfaceAlt,
                  color: leadingColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups_2_outlined, size: 16, color: context.colors.inkMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.voteBox.totalVotes} votes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: context.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  if (widget.voteBox.hasVoted)
                    AppChip(
                      label: 'You voted',
                      color: context.colors.green,
                      icon: Icons.check_circle,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

