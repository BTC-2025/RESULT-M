import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {
      'name': 'Rahul Sharma',
      'time': '2h ago',
      'text': 'This is really helpful, thanks for sharing the update!',
      'avatar': 'R',
    },
    {
      'name': 'Anita Desai',
      'time': '5h ago',
      'text': 'I completely agree. The transparency here is great.',
      'avatar': 'A',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'name': 'You',
        'time': 'just now',
        'text': _commentController.text.trim(),
        'avatar': 'Y',
      });
    });
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Post Discussion',
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.colors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Original Post Mock Placeholder
                // In a real app, you would fetch the FeedPost by widget.postId and render it here
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: context.colors.orange.withValues(alpha: 0.2),
                            child: Text('P', style: TextStyle(color: context.colors.orange, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Original Publisher', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
                              Text('1 day ago', style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This is the detailed view of the post. You can read the full context here before engaging in the discussion below.',
                        style: TextStyle(color: context.colors.ink, height: 1.5),
                      ),
                    ],
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Comments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),

                // Comments List
                ..._comments.map((comment) => _buildCommentTile(comment)),
              ],
            ),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: context.colors.ink),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: context.colors.inkMuted),
                      filled: true,
                      fillColor: context.colors.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _postComment,
                  child: CircleAvatar(
                    backgroundColor: context.colors.orange,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Map<String, String> comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.surfaceAlt,
            child: Text(comment['avatar']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(comment['time']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['text']!,
                  style: TextStyle(color: context.colors.ink, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 14, color: context.colors.inkFaint),
                    const SizedBox(width: 4),
                    Text('Like', style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    Text('Reply', style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
