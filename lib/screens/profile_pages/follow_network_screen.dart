import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_network_provider.dart';
import '../../services/user_service.dart';

class FollowNetworkScreen extends ConsumerStatefulWidget {
  final String userId;
  final String initialTab; // 'followers' or 'following'

  const FollowNetworkScreen({
    super.key,
    required this.userId,
    this.initialTab = 'followers',
  });

  @override
  ConsumerState<FollowNetworkScreen> createState() => _FollowNetworkScreenState();
}

class _FollowNetworkScreenState extends ConsumerState<FollowNetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.ink, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Network',
          style: TextStyle(
            color: context.colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.ink,
          indicatorWeight: 2,
          labelColor: context.colors.ink,
          unselectedLabelColor: context.colors.inkMuted,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FollowersList(userId: widget.userId),
          _FollowingList(userId: widget.userId),
        ],
      ),
    );
  }
}

class _FollowersList extends ConsumerWidget {
  final String userId;
  const _FollowersList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(followersProvider(userId));
    final authState = ref.watch(authProvider);
    final isSelf = authState.userId == userId;

    return asyncData.when(
      loading: () => Center(child: CircularProgressIndicator(color: context.colors.ink)),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (users) {
        if (users == null || users.isEmpty) {
          return Center(
            child: Text(
              'No followers yet.',
              style: TextStyle(color: context.colors.inkMuted, fontSize: 16),
            ),
          );
        }
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.border),
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserRow(
              user: user,
              isSelf: isSelf,
              isFollowersTab: true,
              networkOwnerId: userId,
            );
          },
        );
      },
    );
  }
}

class _FollowingList extends ConsumerWidget {
  final String userId;
  const _FollowingList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(followingProvider(userId));
    final authState = ref.watch(authProvider);
    final isSelf = authState.userId == userId;

    return asyncData.when(
      loading: () => Center(child: CircularProgressIndicator(color: context.colors.ink)),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (users) {
        if (users == null || users.isEmpty) {
          return Center(
            child: Text(
              'Not following anyone yet.',
              style: TextStyle(color: context.colors.inkMuted, fontSize: 16),
            ),
          );
        }
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.border),
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserRow(
              user: user,
              isSelf: isSelf,
              isFollowersTab: false,
              networkOwnerId: userId,
            );
          },
        );
      },
    );
  }
}

class _UserRow extends ConsumerWidget {
  final dynamic user;
  final bool isSelf;
  final bool isFollowersTab;
  final String networkOwnerId;

  const _UserRow({
    required this.user,
    required this.isSelf,
    required this.isFollowersTab,
    required this.networkOwnerId,
  });

  Widget _buildAvatar(BuildContext context) {
    final base64String = user['profilePictureBase64'];
    final name = user['name'] ?? '?';

    if (base64String != null && base64String.isNotEmpty) {
      try {
        final bytes = base64Decode(base64String.split(',').last);
        return CircleAvatar(
          radius: 24,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback
      }
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: context.colors.surfaceAlt,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: context.colors.inkMuted,
        ),
      ),
    );
  }

  Future<void> _handleRemoveFollower(BuildContext context, WidgetRef ref) async {
    final userService = UserService();
    try {
      await userService.removeFollower(user['id']?.toString() ?? '');
      ref.invalidate(followersProvider(networkOwnerId));
      ref.invalidate(followingProvider(networkOwnerId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${user['name'] ?? 'user'} from followers'),
            backgroundColor: context.colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove follower: $e'),
            backgroundColor: context.colors.liveRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleUnfollow(BuildContext context, WidgetRef ref) async {
    final userService = UserService();
    try {
      await userService.unfollowUser(user['id']?.toString() ?? '');
      ref.invalidate(followersProvider(networkOwnerId));
      ref.invalidate(followingProvider(networkOwnerId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unfollowed ${user['name'] ?? 'user'}'),
            backgroundColor: context.colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unfollow: $e'),
            backgroundColor: context.colors.liveRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleBlockUser(BuildContext context, WidgetRef ref) async {
    final userService = UserService();
    try {
      await userService.blockUser(user['id']?.toString() ?? '');
      ref.invalidate(followersProvider(networkOwnerId));
      ref.invalidate(followingProvider(networkOwnerId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blocked ${user['name'] ?? 'user'}'),
            backgroundColor: context.colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to block user: $e'),
            backgroundColor: context.colors.liveRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    final name = user['name'] ?? 'Unknown User';
    final orgType = user['organizationType'] as String?;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: context.colors.border.withValues(alpha: 0.5)),
                  left: BorderSide(color: context.colors.border.withValues(alpha: 0.5)),
                  right: BorderSide(color: context.colors.border.withValues(alpha: 0.5)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.inkMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildAvatar(context),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: context.colors.ink,
                              ),
                            ),
                            if (orgType != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                orgType,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.inkMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: context.colors.border.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  if (isFollowersTab) ...[
                    _buildActionTile(
                      context,
                      icon: Icons.person_remove_outlined,
                      title: 'Remove Follower',
                      titleColor: context.colors.liveRed,
                      onTap: () {
                        Navigator.of(context).pop();
                        _handleRemoveFollower(context, ref);
                      },
                    ),
                  ] else ...[
                    _buildActionTile(
                      context,
                      icon: Icons.remove_circle_outline,
                      title: 'Unfollow',
                      titleColor: context.colors.liveRed,
                      onTap: () {
                        Navigator.of(context).pop();
                        _handleUnfollow(context, ref);
                      },
                    ),
                  ],
                  _buildActionTile(
                    context,
                    icon: Icons.block_flipped,
                    title: 'Block User',
                    titleColor: context.colors.liveRed,
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleBlockUser(context, ref);
                    },
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.close,
                    title: 'Cancel',
                    titleColor: context.colors.inkMuted,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user['name'] ?? 'Unknown User';
    final orgType = user['organizationType'];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(context),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: context.colors.ink,
        ),
      ),
      subtitle: orgType != null
          ? Text(
              orgType,
              style: TextStyle(fontSize: 13, color: context.colors.inkMuted),
            )
          : null,
      onTap: () {
        context.push('/profile/public/${user['id']}');
      },
      trailing: isSelf
          ? IconButton(
              icon: Icon(Icons.more_vert, color: context.colors.inkMuted),
              onPressed: () => _showActionSheet(context, ref),
            )
          : null,
    );
  }
}
