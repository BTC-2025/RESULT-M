import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_guard.dart';
import '../core/theme/app_theme.dart';
import '../features/home/data/home_feed_repository.dart';
import '../models/feed_post_model.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  List<FeedPost> _items = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSaved());
  }

  Future<void> _loadSaved() async {
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'view saved posts',
    );
    if (!allowed) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _isLoading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await ref
          .read(homeFeedRepositoryProvider)
          .fetchSavedPosts();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeSaved(FeedPost post) async {
    final oldItems = _items;
    setState(
      () => _items = _items.where((item) => item.id != post.id).toList(),
    );
    try {
      final repository = ref.read(homeFeedRepositoryProvider);
      if (post.postType == FeedPostType.complaint) {
        await repository.removeComplaintBookmark(
          post.complaint?.complaintId ?? post.id,
        );
      } else {
        await repository.removeBookmark(post.id);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _items = oldItems);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to remove saved item: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: const Text(
          'Saved',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.ink,
        elevation: 0,
      ),
      body: RefreshIndicator(onRefresh: _loadSaved, child: _body()),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 48, color: context.colors.liveRed),
          const SizedBox(height: 14),
          Text(
            'Unable to load saved items',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.inkMuted),
          ),
        ],
      );
    }
    if (_items.isEmpty) return _emptyState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = _items[index];
        return Dismissible(
          key: ValueKey(post.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: context.colors.liveRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.delete_outline, color: context.colors.liveRed),
          ),
          onDismissed: (_) => _removeSaved(post),
          child: _SavedPostTile(
            post: post,
            onTap: () => context.push('/post/details/${post.id}'),
            onRemove: () => _removeSaved(post),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 140),
        Icon(
          Icons.bookmark_border_rounded,
          size: 64,
          color: context.colors.inkFaint,
        ),
        const SizedBox(height: 18),
        Text(
          'No saved posts',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Saved posts, polls, results, and complaints will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.inkMuted),
        ),
      ],
    );
  }
}

class _SavedPostTile extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedPostTile({
    required this.post,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title = switch (post.postType) {
      FeedPostType.update => post.update?.text.trim(),
      FeedPostType.complaint => post.complaint?.title.trim(),
      FeedPostType.poll => post.poll?.question.trim(),
      FeedPostType.result => post.result?.title.trim(),
      FeedPostType.liveScore => post.liveScore?.eventTitle.trim(),
    };
    final subtitle = switch (post.postType) {
      FeedPostType.complaint => post.complaint?.description.trim(),
      FeedPostType.result => post.result?.subtitle.trim(),
      FeedPostType.poll => '${post.poll?.totalVotes ?? 0} votes',
      FeedPostType.update => post.update?.category ?? post.update?.locationName,
      FeedPostType.liveScore => post.liveScore?.status,
    };

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor(context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon(), color: _typeColor(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(),
                      style: TextStyle(
                        color: _typeColor(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title?.isNotEmpty == true ? title! : 'Saved item',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.bookmark_remove_rounded,
                  color: context.colors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label() => switch (post.postType) {
    FeedPostType.update => 'POST',
    FeedPostType.complaint => 'COMPLAINT',
    FeedPostType.poll => 'POLL',
    FeedPostType.result => 'RESULT',
    FeedPostType.liveScore => 'LIVE',
  };

  IconData _typeIcon() => switch (post.postType) {
    FeedPostType.update => Icons.article_rounded,
    FeedPostType.complaint => Icons.campaign_rounded,
    FeedPostType.poll => Icons.poll_rounded,
    FeedPostType.result => Icons.emoji_events_rounded,
    FeedPostType.liveScore => Icons.sensors_rounded,
  };

  Color _typeColor(BuildContext context) => switch (post.postType) {
    FeedPostType.update => context.colors.teal,
    FeedPostType.complaint => context.colors.liveRed,
    FeedPostType.poll => context.colors.purple,
    FeedPostType.result => context.colors.blue,
    FeedPostType.liveScore => context.colors.green,
  };
}
