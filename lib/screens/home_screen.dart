import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_guard.dart';
import '../core/theme/app_theme.dart';
import '../features/home/domain/create_post_tab.dart';
import '../features/home/presentation/widgets/post_composer_sheet.dart';
import '../features/home/presentation/widgets/feed/feed_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialExpandedPostId;
  const HomeScreen({super.key, this.initialExpandedPostId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialExpandedPostId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.push('/post/details/${widget.initialExpandedPostId}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _showComposer,
        backgroundColor: context.colors.purple,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: const FeedListView(),
    );
  }

  Future<void> _showComposer() async {
    final allowed = await AuthGuard.requireLoginForAction(
      context,
      ref,
      actionName: 'create a post',
    );
    if (!allowed || !mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ComposerActionSheet(
        onSelect: (tab) {
          Navigator.pop(context);
          if (tab == null) {
            this.context.push('/create-organization');
            return;
          }
          _showCreatePostSheet(tab);
        },
      ),
    );
  }

  void _showCreatePostSheet(CreatePostTab initialTab) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostSheet(initialTab: initialTab),
    );
  }
}

