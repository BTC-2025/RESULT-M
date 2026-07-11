import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../models/feed_post_model.dart';
import '../../../../../providers/feed_provider.dart';
import '../../../application/home_feed_policy.dart';
import '../../../application/home_preferences_provider.dart';
import '../../../application/live_stories_provider.dart';
import '../../../domain/home_feed_tab.dart';
import '../home_app_bar.dart';
import '../home_empty_states.dart';
import '../home_tabs_header.dart';
import '../live_now_section.dart';
import '../../../../../widgets/feed/feed_post_widgets.dart' hide AppChip;
import '../../../../../core/auth/auth_guard.dart';
import 'post_comments.dart';

class FeedListView extends ConsumerStatefulWidget {
  const FeedListView({super.key});

  @override
  ConsumerState<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends ConsumerState<FeedListView> {
  static const _feedPolicy = HomeFeedPolicy();
  HomeFeedTab _tab = HomeFeedTab.forYou;
  bool _requestedInitialFeed = false;
  String? _expandedPostId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialFeed());
  }

  void _loadInitialFeed() {
    if (!mounted || _requestedInitialFeed) return;
    final feed = ref.read(feedProvider);
    if (feed.isLoading) return;
    _requestedInitialFeed = true;
    ref.read(feedProvider.notifier).refresh();
  }

  void _toggleExpand(String postId) {
    setState(() {
      _expandedPostId = _expandedPostId == postId ? null : postId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final interestTags = ref
        .watch(homeInterestTagsProvider)
        .maybeWhen(data: (tags) => tags, orElse: () => const <String>{});
    final posts = _feedPolicy.postsForTab(
      feed.posts,
      _tab,
      interestTags: interestTags,
    );
    final allStories = ref.watch(liveStoriesProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!feed.isLoading &&
            feed.hasMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 500) {
          ref.read(feedProvider.notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        color: context.colors.purple,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          key: PageStorageKey('home-${_tab.name}'),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            HomeSliverAppBar(onProfileTap: () => context.go('/profile')),
            if (feed.isLoading && feed.posts.isEmpty)
              const SliverFillRemaining(child: FeedSkeleton())
            else ...[
              SliverToBoxAdapter(
                child: allStories.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          LiveNowHeader(onSeeAll: () => context.go('/results')),
                          StoriesStrip(
                            stories: allStories,
                            onTap: _onStoryTap,
                          ),
                        ],
                      ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeTabsHeaderDelegate(
                  selected: _tab,
                  topPadding: MediaQuery.paddingOf(context).top,
                  onSelected: (tab) => setState(() => _tab = tab),
                ),
              ),
              if (_tab == HomeFeedTab.following)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: FollowingEmptyState(
                    onExplore: () => context.go('/results'),
                  ),
                )
              else if (posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoPostsState(
                    tab: _tab,
                    onAction: () {
                      if (_tab == HomeFeedTab.polls) {
                        context.push('/votes/new');
                      } else if (_tab == HomeFeedTab.complaints) {
                        context.push('/complaints/new');
                      }
                    },
                  ),
                )
              else
                SliverList.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return FeedAppear(
                      key: ValueKey(post.id),
                      child: ExpandablePost(
                        post: post,
                        expanded: _expandedPostId == post.id,
                        child: _buildPost(post),
                      ),
                    );
                  },
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
                  child: Center(
                    child: feed.hasMore
                        ? const CircularProgressIndicator()
                        : Text(
                            "You're all caught up",
                            style: TextStyle(
                              color: context.colors.inkFaint,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPost(FeedPost post) {
    switch (post.postType) {
      case FeedPostType.liveScore:
        return const SizedBox.shrink();
      case FeedPostType.result:
        return ResultPost(
          post: post,
          onLike: () => _likePost(post.id),
          onComment: () => _toggleExpand(post.id),
          onOpenDetail: () => context.push('/post/details/${post.id}'),
          onSave: () => _savePost(post.id),
        );
      case FeedPostType.update:
        return UpdatePost(
          post: post,
          onLike: () => _likePost(post.id),
          onComment: () => _toggleExpand(post.id),
          onOpenDetail: () => context.push('/post/details/${post.id}'),
          onSave: () => _savePost(post.id),
        );
      case FeedPostType.poll:
        return PollPost(
          post: post,
          onVote: (optionId) => _votePoll(post.id, optionId),
          onLike: () => _likePost(post.id),
          onComment: () => _toggleExpand(post.id),
          onOpenDetail: () => context.push('/post/details/${post.id}'),
          onSave: () => _savePost(post.id),
        );
      case FeedPostType.complaint:
        return ComplaintPost(
          post: post,
          onVote: (voteType) => _voteComplaint(post.id, voteType),
          onComment: () => _toggleExpand(post.id),
          onOpenDetail: () => context.push('/post/details/${post.id}'),
          onSave: () => _savePost(post.id),
        );
    }
  }

  void _onStoryTap(LiveStory story) {
    if (story.domainType == 'FOOTBALL' && story.id.startsWith('foot_')) {
      final id = story.id.replaceFirst('foot_', '');
      context.push('/results/sports/football/live/$id', extra: story.payload);
    } else if (story.domainType == 'CRICKET' && story.id.startsWith('cric_')) {
      final id = story.id.replaceFirst('cric_', '');
      context.push('/results/sports/cricket/live/$id', extra: story.payload);
    } else if (story.workspaceId != null) {
      context.push('/workspace/${story.workspaceId}');
    } else {
      context.go('/results');
    }
  }

  Future<void> _likePost(String postId) async {
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'like this post',
    );
    if (!allowed) return;
    try {
      await ref.read(feedProvider.notifier).likePost(postId);
    } catch (error) {
      _showActionError(error);
    }
  }

  Future<void> _savePost(String postId) async {
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'save this post',
    );
    if (!allowed) return;
    try {
      final snapshot = await ref
          .read(feedProvider.notifier)
          .bookmarkPost(postId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snapshot.bookmarked ? 'Saved' : 'Removed from saved'),
        ),
      );
    } catch (error) {
      _showActionError(error);
    }
  }

  Future<void> _votePoll(String postId, String optionId) async {
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'vote in this poll',
    );
    if (!allowed) return;
    try {
      await ref.read(feedProvider.notifier).votePoll(postId, optionId);
    } catch (error) {
      _showActionError(error);
    }
  }

  Future<void> _voteComplaint(String postId, String voteType) async {
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'vote on this complaint',
    );
    if (!allowed) return;
    try {
      await ref.read(feedProvider.notifier).voteComplaint(postId, voteType);
    } catch (error) {
      _showActionError(error);
    }
  }

  void _showActionError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_readableActionError(error))));
  }

  String _readableActionError(Object error) {
    final message = error.toString();
    if (message.contains('401') || message.contains('403')) {
      return 'This action needs a valid session. Please try again.';
    }
    if (message.contains('SocketException') || message.contains('connection')) {
      return 'Backend is not reachable.';
    }
    return 'Action failed. Please try again.';
  }
}

class ExpandablePost extends StatelessWidget {
  final FeedPost post;
  final Widget child;
  final bool expanded;

  const ExpandablePost({
    super.key,
    required this.post,
    required this.child,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        child,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: expanded
              ? ExpandedPostArea(key: ValueKey(post.id), post: post)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
