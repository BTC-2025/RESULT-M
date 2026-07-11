import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/home/data/home_feed_repository.dart';
import '../../../../../models/feed_post_model.dart';
import '../../../../../providers/feed_provider.dart';

class ExpandedPostArea extends ConsumerStatefulWidget {
  final FeedPost post;
  const ExpandedPostArea({super.key, required this.post});

  @override
  ConsumerState<ExpandedPostArea> createState() => _ExpandedPostAreaState();
}

class _ExpandedPostAreaState extends ConsumerState<ExpandedPostArea> {
  final _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isFocused = false;
  bool _isLoadingComments = false;
  List<PostCommentDto> _comments = [];
  PostCommentDto? _replyingTo;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await ref
          .read(feedProvider.notifier)
          .fetchPostComments(widget.post.id);
      if (mounted) setState(() => _comments = comments);
    } catch (e) {
      // Handle error gracefully
    } finally {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final parentId = _replyingTo?.id;

    _commentController.clear();
    setState(() {
      _isFocused = false;
      _replyingTo = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final newComment = await ref
          .read(feedProvider.notifier)
          .addPostComment(
            postId: widget.post.id,
            content: text,
            parentCommentId: parentId,
          );
      if (mounted) {
        setState(() => _comments.insert(0, newComment));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    }
  }

  void _onReplyTap(PostCommentDto comment) {
    setState(() => _replyingTo = comment);
    _commentFocusNode.requestFocus();
  }

  void _clearReply() {
    setState(() => _replyingTo = null);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentCount = widget.post.commentCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                color: context.colors.purple,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Discussion',
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                commentCount == 1 ? '1 comment' : '$commentCount comments',
                style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            CommentPreview(
              post: widget.post,
              comments: _comments,
              onReplyTap: _onReplyTap,
            ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (value) => setState(() => _isFocused = value),
            child: CommentComposerBar(
              controller: _commentController,
              focusNode: _commentFocusNode,
              focused: _isFocused,
              replyingTo: _replyingTo,
              onClearReply: _clearReply,
              onChanged: () => setState(() {}),
              onSubmit: _postComment,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentPreview extends StatelessWidget {
  final FeedPost post;
  final List<PostCommentDto> comments;
  final Function(PostCommentDto) onReplyTap;

  const CommentPreview({
    super.key,
    required this.post,
    required this.comments,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      final author = post.authorName.trim().isEmpty ? 'this post' : post.authorName;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.purple.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: context.colors.purple,
                    size: 18,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: context.colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start the conversation',
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reply to $author. Be the first to share your thoughts!',
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final rootComments = <PostCommentDto>[];
    final commentsByParentId = <String, List<PostCommentDto>>{};

    for (final c in comments) {
      if (c.parentCommentId == null || c.parentCommentId!.isEmpty) {
        rootComments.add(c);
      } else {
        commentsByParentId.putIfAbsent(c.parentCommentId!, () => []).add(c);
      }
    }

    return Column(
      children: rootComments
          .take(15) // Limit root comments for performance if needed
          .map(
            (c) => CommentThreadNode(
              comment: c,
              depth: 0,
              commentsByParentId: commentsByParentId,
              onReplyTap: onReplyTap,
            ),
          )
          .toList(),
    );
  }
}

class CommentThreadNode extends StatelessWidget {
  final PostCommentDto comment;
  final int depth;
  final Map<String, List<PostCommentDto>> commentsByParentId;
  final Function(PostCommentDto) onReplyTap;

  const CommentThreadNode({
    super.key,
    required this.comment,
    required this.depth,
    required this.commentsByParentId,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final children = commentsByParentId[comment.id] ?? [];
    
    // Sort replies oldest first so they read top to bottom naturally
    children.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Indentation for nested replies
    final currentDepth = depth > 4 ? 4 : depth;
    final paddingLeft = currentDepth * 18.0;

    final initial = comment.creatorName.trim().isEmpty 
        ? '?' 
        : comment.creatorName.trim()[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0, left: paddingLeft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.purple.withValues(alpha: 0.13),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: context.colors.purple,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
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
                            comment.creatorName.trim().isEmpty
                                ? 'Member'
                                : comment.creatorName,
                            style: TextStyle(
                              color: context.colors.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '@user${comment.creatorName.hashCode.abs().toString().substring(0, 5)}',
                          style: TextStyle(
                            color: context.colors.inkMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.content,
                      style: TextStyle(
                        color: context.colors.ink,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildActionIcon(
                          context: context,
                          icon: Icons.chat_bubble_outline_rounded,
                          color: context.colors.blue,
                          onTap: () => onReplyTap(comment),
                        ),
                        const SizedBox(width: 24),
                        _buildActionIcon(
                          context: context,
                          icon: comment.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          count: comment.likeCount > 0 ? comment.likeCount : null,
                          color: context.colors.liveRed,
                          isActive: comment.liked,
                          onTap: () {}, // Like action for inline comment
                        ),
                        const SizedBox(width: 24),
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
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: context.colors.border,
                    width: 2.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: 12.0, top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children.map(
                  (child) => CommentThreadNode(
                    comment: child,
                    depth: depth + 1,
                    commentsByParentId: commentsByParentId,
                    onReplyTap: onReplyTap,
                  ),
                ).toList(),
              ),
            ),
          ],
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
            size: 16,
            color: isActive ? color : context.colors.inkMuted,
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isActive ? color : context.colors.inkMuted,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CommentComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final PostCommentDto? replyingTo;
  final VoidCallback onClearReply;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const CommentComposerBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.replyingTo,
    required this.onClearReply,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (replyingTo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
            child: Row(
              children: [
                Icon(Icons.reply_rounded, size: 14, color: context.colors.inkMuted),
                const SizedBox(width: 4),
                Text(
                  'Replying to ',
                  style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
                ),
                Flexible(
                  child: Text(
                    '@${replyingTo!.creatorName}',
                    style: TextStyle(
                      color: context.colors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClearReply,
                  child: Icon(Icons.close_rounded, size: 14, color: context.colors.inkMuted),
                ),
              ],
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
          decoration: BoxDecoration(
            color: context.colors.bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: focused ? context.colors.purple : context.colors.border,
              width: focused ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: context.colors.surfaceAlt,
                child: Icon(
                  Icons.person_rounded,
                  color: context.colors.inkMuted,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (_) => onChanged(),
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(color: context.colors.ink, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: replyingTo != null 
                        ? 'Write a reply...' 
                        : 'Add a thoughtful comment...',
                    hintStyle: TextStyle(color: context.colors.inkFaint),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: hasText ? onSubmit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: hasText
                        ? context.colors.purple
                        : context.colors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: hasText ? Colors.white : context.colors.inkFaint,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

