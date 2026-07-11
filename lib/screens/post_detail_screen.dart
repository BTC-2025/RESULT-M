import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../core/auth/auth_guard.dart';
import '../core/theme/app_theme.dart' hide AppChip;
import '../core/utils/share_links.dart';
import '../core/utils/time_formatter.dart';
import '../features/home/data/home_feed_repository.dart';
import '../models/feed_post_model.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed/feed_post_widgets.dart';

enum _CommentSort { relevant, newest, liked }

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  _CommentSort _sort = _CommentSort.relevant;
  List<PostCommentDto> _comments = const [];
  PostCommentDto? _replyingTo;
  final Set<String> _updatingCommentLikes = <String>{};
  bool _liked = false;
  bool _bookmarked = false;
  bool _loadingComments = false;
  bool _submittingComment = false;
  bool _updatingInteraction = false;
  String? _commentError;
  String? _interactionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feed = ref.read(feedProvider);
      if (!feed.isLoading && !_hasPost(feed)) {
        ref.read(feedProvider.notifier).refresh();
      }
      _loadInteractionsAndComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final post = _findPost(feed);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.ink,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Post',
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.colors.border),
        ),
      ),
      body: post == null
          ? _PostUnavailable(
              isLoading: feed.isLoading,
              onRetry: () => ref.read(feedProvider.notifier).refresh(),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: context.colors.purple,
                    onRefresh: () => ref.read(feedProvider.notifier).refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 18),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: _FullPostCard(post: post),
                        ),
                        const SizedBox(height: 8),
                        _PostActionPanel(
                          post: post,
                          liked: _liked,
                          bookmarked: _bookmarked,
                          disabled: _updatingInteraction,
                          onLike: _toggleLike,
                          onBookmark: _toggleBookmark,
                          onUpvote: () => _voteComplaint('UP'),
                          onDownvote: () => _voteComplaint('DOWN'),
                          onShare: () => _sharePost(post),
                        ),
                        if (_interactionError != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _InlineError(message: _interactionError!),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _CommentsHeader(
                            sort: _sort,
                            count: post.commentCount,
                            onChanged: (sort) => setState(() => _sort = sort),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_loadingComments)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: _CommentsLoading(),
                          )
                        else if (_commentError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _InlineError(message: _commentError!),
                          )
                        else if (_comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _CommentsEmpty(sort: _sort),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildCommentThreads(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _CommentInputBar(
                  controller: _commentController,
                  submitting: _submittingComment,
                  replyingTo: _replyingTo?.creatorName,
                  onCancelReply: () => setState(() => _replyingTo = null),
                  onSubmit: _submitComment,
                ),
              ],
            ),
    );
  }

  FeedPost? _findPost(FeedState feed) {
    for (final post in feed.posts) {
      if (post.id == widget.postId) return post;
    }
    return null;
  }

  bool _hasPost(FeedState feed) => _findPost(feed) != null;

  Future<void> _loadInteractionsAndComments() async {
    final post = _findPost(ref.read(feedProvider));
    if (post?.postType == FeedPostType.complaint) {
      await _loadComplaintComments(post!.complaint!.complaintId);
      return;
    }

    setState(() {
      _loadingComments = true;
      _commentError = null;
      _interactionError = null;
    });
    try {
      final notifier = ref.read(feedProvider.notifier);
      final results = await Future.wait([
        notifier.fetchPostInteractions(widget.postId),
        notifier.fetchPostComments(widget.postId),
      ]);
      final interaction = results[0] as PostInteractionSnapshot;
      final comments = results[1] as List<PostCommentDto>;
      if (!mounted) return;
      setState(() {
        _liked = interaction.liked;
        _bookmarked = interaction.bookmarked;
        _comments = comments;
        _loadingComments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingComments = false;
        _commentError = error.toString();
      });
    }
  }

  Future<void> _loadComplaintComments(String complaintId) async {
    setState(() {
      _loadingComments = true;
      _commentError = null;
      _interactionError = null;
    });
    try {
      final comments = await ref
          .read(feedProvider.notifier)
          .fetchComplaintComments(complaintId);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingComments = false;
        _commentError = error.toString();
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_isComplaintPost) return;
    if (_updatingInteraction) return;
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'like this post',
    );
    if (!allowed) return;
    setState(() {
      _updatingInteraction = true;
      _interactionError = null;
    });
    try {
      final notifier = ref.read(feedProvider.notifier);
      final snapshot = _liked
          ? await notifier.unlikePost(widget.postId)
          : await notifier.likePost(widget.postId);
      if (!mounted) return;
      setState(() {
        _liked = snapshot.liked;
        _bookmarked = snapshot.bookmarked;
        _updatingInteraction = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _updatingInteraction = false;
        _interactionError = error.toString();
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_updatingInteraction) return;
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'save this post',
    );
    if (!allowed) return;
    setState(() {
      _updatingInteraction = true;
      _interactionError = null;
    });
    try {
      final notifier = ref.read(feedProvider.notifier);
      final snapshot = await notifier.bookmarkPost(widget.postId);
      if (!mounted) return;
      setState(() {
        _liked = snapshot.liked;
        _bookmarked = snapshot.bookmarked;
        _updatingInteraction = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _updatingInteraction = false;
        _interactionError = error.toString();
      });
    }
  }

  Future<void> _voteComplaint(String voteType) async {
    if (_updatingInteraction) return;
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'vote on this complaint',
    );
    if (!allowed) return;
    setState(() {
      _updatingInteraction = true;
      _interactionError = null;
    });
    try {
      await ref
          .read(feedProvider.notifier)
          .voteComplaint(widget.postId, voteType);
      if (!mounted) return;
      setState(() => _updatingInteraction = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _updatingInteraction = false;
        _interactionError = error.toString();
      });
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _submittingComment) return;
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: _replyingTo == null ? 'comment' : 'reply',
    );
    if (!allowed) return;
    setState(() {
      _submittingComment = true;
      _commentError = null;
    });
    try {
      final post = _findPost(ref.read(feedProvider));
      final comment = post?.postType == FeedPostType.complaint
          ? await ref
                .read(feedProvider.notifier)
                .addComplaintComment(
                  complaintId: post!.complaint!.complaintId,
                  content: content,
                  parentCommentId: _replyingTo?.id,
                )
          : await ref
                .read(feedProvider.notifier)
                .addPostComment(
                  postId: widget.postId,
                  content: content,
                  parentCommentId: _replyingTo?.id,
                );
      if (!mounted) return;
      final parentId = _replyingTo?.id;
      _commentController.clear();
      FocusScope.of(context).unfocus();
      setState(() {
        _comments = [
          comment,
          for (final existing in _comments)
            existing.id == parentId
                ? existing.copyWith(replyCount: existing.replyCount + 1)
                : existing,
        ];
        _replyingTo = null;
        _submittingComment = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submittingComment = false;
        _commentError = error.toString();
      });
    }
  }

  void _sharePost(FeedPost post) {
    SharePlus.instance.share(ShareParams(text: ShareLinks.post(post.id)));
  }

  Future<void> _toggleCommentLike(PostCommentDto comment) async {
    if (!_updatingCommentLikes.add(comment.id)) return;
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'like this comment',
    );
    if (!allowed) {
      _updatingCommentLikes.remove(comment.id);
      return;
    }
    try {
      final notifier = ref.read(feedProvider.notifier);
      final updated = _isComplaintPost
          ? (comment.liked
                ? await notifier.unlikeComplaintComment(comment.id)
                : await notifier.likeComplaintComment(comment.id))
          : (comment.liked
                ? await notifier.unlikePostComment(comment.id)
                : await notifier.likePostComment(comment.id));
      if (!mounted) return;
      setState(() {
        _comments = _comments
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _commentError = error.toString());
    } finally {
      _updatingCommentLikes.remove(comment.id);
    }
  }

  void _startReply(PostCommentDto comment) {
    setState(() {
      _replyingTo = comment;
      _commentError = null;
    });
  }

  List<Widget> _buildCommentThreads() {
    final rootComments = <PostCommentDto>[];
    final commentsByParentId = <String, List<PostCommentDto>>{};

    for (final c in _comments) {
      if (c.parentCommentId == null || c.parentCommentId!.isEmpty) {
        rootComments.add(c);
      } else {
        commentsByParentId.putIfAbsent(c.parentCommentId!, () => []).add(c);
      }
    }

    // Sort root comments
    switch (_sort) {
      case _CommentSort.newest:
        rootComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _CommentSort.liked:
        rootComments.sort((a, b) {
          final byLikes = b.likeCount.compareTo(a.likeCount);
          return byLikes == 0 ? b.createdAt.compareTo(a.createdAt) : byLikes;
        });
        break;
      case _CommentSort.relevant:
        rootComments.sort((a, b) {
          final byLikes = b.likeCount.compareTo(a.likeCount);
          return byLikes == 0 ? b.createdAt.compareTo(a.createdAt) : byLikes;
        });
        break;
    }

    final widgets = <Widget>[];
    for (int i = 0; i < rootComments.length; i++) {
      final root = rootComments[i];
      widgets.add(
        _CommentThreadWidget(
          comment: root,
          depth: 0,
          commentsByParentId: commentsByParentId,
          onLike: (c) => _toggleCommentLike(c),
          onReply: (c) => _startReply(c),
        ),
      );
      if (i < rootComments.length - 1) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(Divider(color: context.colors.border, height: 1));
        widgets.add(const SizedBox(height: 16));
      }
    }
    return widgets;
  }

  bool get _isComplaintPost {
    return _findPost(ref.read(feedProvider))?.postType ==
        FeedPostType.complaint;
  }
}

class _FullPostCard extends StatelessWidget {
  final FeedPost post;

  const _FullPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(context, post);
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withValues(alpha: 0.16),
                backgroundImage: post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty
                    ? null
                    : NetworkImage(post.authorAvatarUrl!),
                child: post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty
                    ? Text(
                        post.authorName.trim().isEmpty
                            ? '?'
                            : post.authorName.trim()[0].toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        Text(
                          post.authorName.trim().isEmpty ? 'Member' : post.authorName,
                          style: TextStyle(
                            color: context.colors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (post.isOrganization)
                          Icon(
                            Icons.verified,
                            color: context.colors.blue,
                            size: 16,
                          ),
                        Text(
                          '@user${post.authorName.hashCode.abs().toString().substring(0, 5)}',
                          style: TextStyle(
                            color: context.colors.inkMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '·',
                          style: TextStyle(
                            color: context.colors.inkMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          TimeFormatter.timeAgo(post.createdAt),
                          style: TextStyle(
                            color: context.colors.inkMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PostTypePill(post: post, color: accent),
            ],
          ),
          const SizedBox(height: 12),
          _FullPostContent(post: post),
        ],
      ),
    );
  }

  Color _accentFor(BuildContext context, FeedPost post) {
    switch (post.postType) {
      case FeedPostType.complaint:
        return context.colors.liveRed;
      case FeedPostType.poll:
        return context.colors.purple;
      case FeedPostType.result:
        return context.colors.blue;
      case FeedPostType.liveScore:
        return context.colors.teal;
      case FeedPostType.update:
        return post.update?.mediaUrls.isNotEmpty == true
            ? context.colors.purple
            : context.colors.teal;
    }
  }
}

class _FullPostContent extends StatelessWidget {
  final FeedPost post;

  const _FullPostContent({required this.post});

  @override
  Widget build(BuildContext context) {
    switch (post.postType) {
      case FeedPostType.update:
        final update = post.update;
        if (update == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (update.text.trim().isNotEmpty)
              Text(
                update.text,
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (update.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 14),
              FeedMediaGallery(mediaUrls: update.mediaUrls, singleHeight: 280),
            ],
            if (update.locationName != null || update.category != null) ...[
              const SizedBox(height: 14),
              _MetaChips(
                location: update.locationName,
                category: update.category,
              ),
            ],
          ],
        );
      case FeedPostType.complaint:
        final complaint = post.complaint;
        if (complaint == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.title,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (complaint.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 14),
              FeedMediaGallery(
                mediaUrls: complaint.mediaUrls,
                singleHeight: 260,
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip(
                  label: complaint.status.replaceAll('_', ' '),
                  color: context.colors.amber,
                ),
                AppChip(
                  label: complaint.category,
                  color: context.colors.purple,
                ),
                if (complaint.locationName != null)
                  AppChip(
                    label: complaint.locationName!,
                    icon: Icons.location_on_rounded,
                    color: context.colors.teal,
                  ),
              ],
            ),
          ],
        );
      case FeedPostType.poll:
        final poll = post.poll;
        if (poll == null) return const SizedBox.shrink();
        final total = poll.totalVotes == 0 ? 1 : poll.totalVotes;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.question,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            for (final option in poll.options) ...[
              _PollDetailOption(
                option: option,
                percentage: (option.voteCount / total * 100).round(),
                selected: poll.userVotedOptionId == option.id,
                showResults: poll.hasVoted,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '${poll.totalVotes} votes',
              style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
            ),
          ],
        );
      case FeedPostType.result:
        final result = post.result;
        if (result == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.title,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.subtitle,
              style: TextStyle(
                color: context.colors.inkMuted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        );
      case FeedPostType.liveScore:
        return Text(
          'Live result details are available from the Results workspace.',
          style: TextStyle(color: context.colors.inkMuted, height: 1.4),
        );
    }
  }
}

class _PostActionPanel extends StatelessWidget {
  final FeedPost post;
  final bool liked;
  final bool bookmarked;
  final bool disabled;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onShare;

  const _PostActionPanel({
    required this.post,
    required this.liked,
    required this.bookmarked,
    required this.disabled,
    required this.onLike,
    required this.onBookmark,
    required this.onUpvote,
    required this.onDownvote,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final complaint = post.complaint;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.border),
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionIcon(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            count: post.commentCount > 0 ? post.commentCount : null,
            color: context.colors.blue,
            onTap: () {},
          ),
          _buildActionIcon(
            context: context,
            icon: Icons.repeat_rounded,
            color: context.colors.teal,
            onTap: () {},
          ),
          if (complaint != null) ...[
            _buildActionIcon(
              context: context,
              icon: Icons.arrow_upward_rounded,
              count: complaint.upvotes > 0 ? complaint.upvotes : null,
              color: context.colors.teal,
              onTap: disabled ? null : onUpvote,
            ),
            _buildActionIcon(
              context: context,
              icon: Icons.arrow_downward_rounded,
              count: complaint.downvotes > 0 ? complaint.downvotes : null,
              color: context.colors.liveRed,
              onTap: disabled ? null : onDownvote,
            ),
          ] else
            _buildActionIcon(
              context: context,
              icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              count: post.likeCount > 0 ? post.likeCount : null,
              color: context.colors.liveRed,
              isActive: liked,
              onTap: disabled ? null : onLike,
            ),
          _buildActionIcon(
            context: context,
            icon: bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: context.colors.purple,
            isActive: bookmarked,
            onTap: disabled ? null : onBookmark,
          ),
          _buildActionIcon(
            context: context,
            icon: Icons.ios_share_rounded,
            color: context.colors.inkMuted,
            onTap: onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required IconData icon,
    int? count,
    required Color color,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? color : context.colors.inkMuted,
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: isActive ? color : context.colors.inkMuted,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  final _CommentSort sort;
  final int count;
  final ValueChanged<_CommentSort> onChanged;

  const _CommentsHeader({
    required this.sort,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Comments',
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SortChip(
                label: 'Relevant',
                selected: sort == _CommentSort.relevant,
                onTap: () => onChanged(_CommentSort.relevant),
              ),
              _SortChip(
                label: 'Newest',
                selected: sort == _CommentSort.newest,
                onTap: () => onChanged(_CommentSort.newest),
              ),
              _SortChip(
                label: 'Most liked',
                selected: sort == _CommentSort.liked,
                onTap: () => onChanged(_CommentSort.liked),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentsLoading extends StatelessWidget {
  const _CommentsLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: context.colors.purple,
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.liveRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: context.colors.liveRed.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: context.colors.liveRed,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _readableError(message),
              style: TextStyle(
                color: context.colors.liveRed,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsEmpty extends StatelessWidget {
  final _CommentSort sort;

  const _CommentsEmpty({required this.sort});

  @override
  Widget build(BuildContext context) {
    final label = switch (sort) {
      _CommentSort.relevant => 'Relevant comments',
      _CommentSort.newest => 'Newest comments',
      _CommentSort.liked => 'Most liked comments',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.forum_outlined, color: context.colors.inkMuted, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No comments yet. Be the first to add a useful reply.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.inkMuted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentThreadWidget extends StatelessWidget {
  final PostCommentDto comment;
  final int depth;
  final Map<String, List<PostCommentDto>> commentsByParentId;
  final Function(PostCommentDto) onLike;
  final Function(PostCommentDto) onReply;

  const _CommentThreadWidget({
    required this.comment,
    required this.depth,
    required this.commentsByParentId,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final children = commentsByParentId[comment.id] ?? [];
    
    // Sort replies oldest first so they read top to bottom naturally
    children.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final initial = _firstInitial(comment.creatorName);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.colors.purple.withValues(alpha: 0.13),
              child: Text(
                initial,
                style: TextStyle(
                  color: context.colors.purple,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.creatorName.trim().isEmpty
                            ? 'Member'
                            : comment.creatorName,
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '@user${comment.creatorName.hashCode.abs().toString().substring(0, 5)}',
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        TimeFormatter.timeAgo(comment.createdAt),
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionIcon(
                        context: context,
                        icon: Icons.chat_bubble_outline_rounded,
                        count: comment.replyCount > 0 ? comment.replyCount : null,
                        color: context.colors.blue,
                        onTap: () => onReply(comment),
                      ),
                      _buildActionIcon(
                        context: context,
                        icon: Icons.repeat_rounded,
                        color: context.colors.teal,
                        onTap: () {}, // Repost placeholder
                      ),
                      _buildActionIcon(
                        context: context,
                        icon: comment.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        count: comment.likeCount > 0 ? comment.likeCount : null,
                        color: context.colors.liveRed,
                        isActive: comment.liked,
                        onTap: () => onLike(comment),
                      ),
                      _buildActionIcon(
                        context: context,
                        icon: Icons.ios_share_rounded,
                        color: context.colors.inkMuted,
                        onTap: () {}, // Share placeholder
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (children.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 18.0), // Indent to align exactly under center of avatar (radius 18)
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: context.colors.borderBold.withValues(alpha: 0.35),
                    width: 2.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: 14.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _CommentThreadWidget(
                    comment: child,
                    depth: depth + 1,
                    commentsByParentId: commentsByParentId,
                    onLike: onLike,
                    onReply: onReply,
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required IconData icon,
    int? count,
    required Color color,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? color : context.colors.inkMuted,
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isActive ? color : context.colors.inkMuted,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final String? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;

  const _CommentInputBar({
    required this.controller,
    required this.submitting,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to $replyingTo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCancelReply,
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.colors.inkMuted,
                      size: 18,
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 30,
                      height: 30,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.surfaceAlt,
                  child: Icon(
                    Icons.person_rounded,
                    color: context.colors.inkMuted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(color: context.colors.ink, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? 'Post your reply...'
                          : 'Write a reply...',
                      hintStyle: TextStyle(color: context.colors.inkFaint),
                      filled: true,
                      fillColor: context.colors.bg,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: submitting ? null : onSubmit,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: submitting
                        ? context.colors.inkFaint
                        : context.colors.purple,
                    child: submitting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostUnavailable extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const _PostUnavailable({required this.isLoading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              CircularProgressIndicator(color: context.colors.purple)
            else ...[
              Icon(
                Icons.article_outlined,
                color: context.colors.inkMuted,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                'Post not loaded',
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Refresh the feed and open the post again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PollDetailOption extends StatelessWidget {
  final PollOption option;
  final int percentage;
  final bool selected;
  final bool showResults;

  const _PollDetailOption({
    required this.option,
    required this.percentage,
    required this.selected,
    required this.showResults,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? context.colors.purple : context.colors.border,
          ),
        ),
        child: Stack(
          children: [
            if (showResults)
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 50,
                  color: selected
                      ? context.colors.teal.withValues(alpha: 0.22)
                      : context.colors.purple.withValues(alpha: 0.10),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        color: context.colors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (showResults)
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: selected
                            ? context.colors.teal
                            : context.colors.inkMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChips extends StatelessWidget {
  final String? location;
  final String? category;

  const _MetaChips({this.location, this.category});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (location != null)
          AppChip(
            label: location!,
            icon: Icons.location_on_rounded,
            color: context.colors.teal,
          ),
        if (category != null)
          AppChip(
            label: category!,
            icon: Icons.sell_rounded,
            color: context.colors.purple,
          ),
      ],
    );
  }
}

class _PostTypePill extends StatelessWidget {
  final FeedPost post;
  final Color color;

  const _PostTypePill({required this.post, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppChip(label: _label, color: color);
  }

  String get _label {
    switch (post.postType) {
      case FeedPostType.update:
        return post.update?.mediaUrls.isNotEmpty == true ? 'IMAGE' : 'UPDATE';
      case FeedPostType.complaint:
        return 'COMPLAINT';
      case FeedPostType.poll:
        return 'POLL';
      case FeedPostType.result:
        return 'RESULT';
      case FeedPostType.liveScore:
        return 'LIVE';
    }
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? context.colors.purple : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? context.colors.ink : context.colors.inkMuted,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}



String _readableError(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'Something went wrong. Please try again.';
  if (trimmed.contains('401') || trimmed.contains('403')) {
    return 'Please sign in to use this action.';
  }
  if (trimmed.length > 140) {
    return '${trimmed.substring(0, 140)}...';
  }
  return trimmed;
}

String _firstInitial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, 1).toUpperCase();
}

