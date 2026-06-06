import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';
import '../models/feed_post_model.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed/live_story_row.dart';
import '../widgets/feed/feed_post_widgets.dart';
import 'academic/university_hub_screen.dart';
import 'academic/school_hub_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: context.colors.orange,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
          // ─── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: context.colors.bg.withValues(alpha: 0.7),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colors.orange,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(Icons.leaderboard, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('ResultHub', style: TextStyle(
                  color:      context.colors.ink,
                  fontSize:   20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                )),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: context.colors.inkMuted),
                onPressed: () => context.push('/notifications'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: context.colors.surfaceAlt,
                    child: Icon(Icons.person, color: context.colors.inkMuted, size: 16),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: context.colors.border.withValues(alpha: 0.5)),
            ),
          ),

          // ─── Content ─────────────────────────────────────────────────────────
          if (feed.isLoading && feed.posts.isEmpty)
            const SliverFillRemaining(child: _FeedSkeleton())
          else if (feed.error != null)
            SliverFillRemaining(child: _FeedError(onRetry: () => ref.read(feedProvider.notifier).refresh()))
          else
            SliverMainAxisGroup(slivers: [
              // Live story circles
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: [
                          const LiveBadge(),
                          const SizedBox(width: 8),
                          Text('Live Now', style: TextStyle(
                            color: context.colors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          )),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.go('/results'),
                            style: TextButton.styleFrom(
                              foregroundColor: context.colors.orange,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('See all', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                            )),
                          ),
                        ],
                      ),
                    ),
                    LiveStoryRow(
                      stories: feed.stories,
                      onTap: (story) => _onStoryTap(context, story),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                  ],
                ),
              ),

              // Feed posts
              SliverList.separated(
                itemCount: feed.posts.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 2),
                itemBuilder: (ctx, i) => _buildPost(ctx, feed.posts[i], ref),
              ),

              // Load more / end indicator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: feed.hasMore
                        ? CircularProgressIndicator(color: context.colors.orange, strokeWidth: 2)
                        : Text('You\'re all caught up 🎉', style: TextStyle(
                            color: context.colors.inkFaint, fontSize: 13,
                          )),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPost(BuildContext context, FeedPost post, WidgetRef ref) {
    final child = switch (post.postType) {
      FeedPostType.liveScore => LiveScorePost(post: post),
      FeedPostType.result => ResultPost(post: post),
      FeedPostType.poll => PollPost(
          post: post,
          onVote: (optionId) =>
              ref.read(feedProvider.notifier).votePoll(post.id, optionId),
        ),
      FeedPostType.complaint => ComplaintPost(
          post: post,
          onVote: (voteType) =>
              ref.read(feedProvider.notifier).voteComplaint(post.id, voteType),
        ),
    };

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _openPost(context, post),
      child: child,
    );
  }

  void _openPost(BuildContext context, FeedPost post) {
    final liveWorkspaceId = post.liveScore?.workspaceId;
    final result = post.result;

    if (post.poll != null) {
      context.push('/votes/${post.poll!.voteBoxId}');
      return;
    }
    if (post.complaint != null) {
      context.push('/complaints/${post.complaint!.complaintId}');
      return;
    }
    if (result?.datasetId != null) {
      if (result!.domainType == 'ACADEMIC_HUB') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UniversityHubScreen()),
        );
        return;
      }
      if (result.domainType == 'SCHOOL_HUB') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SchoolHubScreen()),
        );
        return;
      }
      
      if (result.isPublic) {
        context.push(
          '/dataset/public/${result.datasetId}'
          '?name=${Uri.encodeComponent(result.title)}'
          '&domainType=${Uri.encodeComponent(result.domainType)}',
        );
      } else {
        context.push(
          '/dataset/${result.datasetId}/search'
          '?name=${Uri.encodeComponent(result.title)}'
          '&domainType=${Uri.encodeComponent(result.domainType)}',
        );
      }
      return;
    }
    
    if (post.liveScore != null) {
      context.push(
        '/dataset/public/${post.liveScore!.workspaceId}'
        '?name=${Uri.encodeComponent(post.liveScore!.eventTitle)}'
        '&domainType=${Uri.encodeComponent(post.liveScore!.domainType)}',
      );
      return;
    }
    if (result?.workspaceId != null) {
      context.push(
        '/workspace/${result!.workspaceId}'
        '?name=${Uri.encodeComponent(result.title)}',
      );
      return;
    }
    if (liveWorkspaceId != null) {
      context.push('/workspace/$liveWorkspaceId');
      return;
    }
  }

  void _onStoryTap(BuildContext context, LiveStory story) {
    if (story.workspaceId != null) {
      context.push('/workspace/${story.workspaceId}');
    } else {
      context.go('/results');
    }
  }
}

// ─── Loading Skeleton ─────────────────────────────────────────────────────────
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _FeedError extends StatelessWidget {
  final VoidCallback onRetry;
  const _FeedError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: context.colors.inkFaint, size: 52),
          const SizedBox(height: 16),
          Text('Couldn\'t load feed', style: TextStyle(
            color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 8),
          Text('Check your connection and try again.', style: TextStyle(
            color: context.colors.inkMuted, fontSize: 14,
          )),
          const SizedBox(height: 24),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

