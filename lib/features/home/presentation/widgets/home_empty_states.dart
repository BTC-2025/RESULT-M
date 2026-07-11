import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/home_feed_tab.dart';

class FeedAppear extends StatelessWidget {
  final Widget child;

  const FeedAppear({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: ((value - 0.95) / 0.05).clamp(0.0, 1.0),
        child: Transform.scale(scale: value, child: child),
      ),
      child: child,
    );
  }
}

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 190,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: context.colors.border),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.045),
                    offset: const Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
        ),
      ),
    );
  }
}

class NoPostsState extends StatelessWidget {
  final HomeFeedTab tab;
  final VoidCallback onAction;

  const NoPostsState({
    super.key,
    required this.tab,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isPolls = tab == HomeFeedTab.polls;
    final isComplaints = tab == HomeFeedTab.complaints;
    final message = isPolls
        ? 'No active polls right now'
        : isComplaints
            ? 'No complaints yet. Raise yours.'
            : 'No posts here yet';
    final button = isPolls
        ? 'Create a Poll'
        : isComplaints
            ? 'Post a Complaint'
            : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, color: context.colors.inkFaint, size: 52),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.inkMuted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (button != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.purple,
                ),
                child: Text(button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FollowingEmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const FollowingEmptyState({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              color: context.colors.purple,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Follow publishers to see their updates',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore result publishers, communities, and live workspaces.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onExplore,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.purple,
              ),
              child: const Text('Explore Results'),
            ),
          ],
        ),
      ),
    );
  }
}
