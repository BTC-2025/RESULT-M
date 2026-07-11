import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/public_profile_provider.dart';
import '../providers/auth_provider.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(publicProfileProvider(widget.userId));
    final postsState = ref.watch(userPostsProvider(widget.userId));
    final authState = ref.watch(authProvider);
    final isSelf = authState.userId == widget.userId;

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
          widget.userName,
          style: TextStyle(
            color: context.colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.ink)),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (profileData) {
          if (profileData == null) {
            return Center(child: Text('Profile not found.', style: TextStyle(color: context.colors.inkMuted)));
          }

          final isFollowing = profileData['isFollowing'] == true;
          final followerCount = profileData['followerCount'] ?? 0;
          final followingCount = profileData['followingCount'] ?? 0;
          final postCount = profileData['postCount'] ?? 0;
          final bio = profileData['bio'] as String?;
          final website = profileData['website'] as String?;
          
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!postsState.isLoading &&
                  postsState.hasMore &&
                  scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                ref.read(userPostsProvider(widget.userId).notifier).loadMore();
              }
              return false;
            },
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            _buildAvatar(profileData['profilePictureBase64']),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn('Posts', postCount),
                                  GestureDetector(
                                    onTap: () => context.push('/profile/network/${widget.userId}?initialTab=followers'),
                                    child: _buildStatColumn('Followers', followerCount),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/profile/network/${widget.userId}?initialTab=following'),
                                    child: _buildStatColumn('Following', followingCount),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileData['name'] ?? widget.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: context.colors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (profileData['organizationType'] != null)
                              Text(
                                profileData['organizationType'],
                                style: TextStyle(
                                  color: context.colors.inkMuted,
                                  fontSize: 13,
                                ),
                              ),
                            if (bio != null && bio.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                bio,
                                style: TextStyle(
                                  color: context.colors.ink,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            if (website != null && website.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.link, size: 14, color: context.colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    website.replaceFirst(RegExp(r'^https?://'), ''),
                                    style: TextStyle(
                                      color: context.colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: isSelf
                                  ? [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => context.push('/profile/personal_details'),
                                          child: Container(
                                            height: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: context.colors.surfaceAlt,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Edit Profile',
                                              style: TextStyle(
                                                color: context.colors.ink,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: context.colors.surfaceAlt,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Share Profile',
                                            style: TextStyle(
                                              color: context.colors.ink,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      Expanded(
                                        child: _FollowButton(
                                          userId: widget.userId,
                                          initialIsFollowing: isFollowing,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            final name = profileData['name'] ?? widget.userName;
                                            context.push('/chat/${widget.userId}?name=${Uri.encodeComponent(name)}');
                                          },
                                          child: Container(
                                            height: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: context.colors.surfaceAlt,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Message',
                                              style: TextStyle(
                                                color: context.colors.ink,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: context.colors.ink,
                      indicatorWeight: 1,
                      labelColor: context.colors.ink,
                      unselectedLabelColor: context.colors.inkMuted,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on)),
                        Tab(icon: Icon(Icons.view_list_outlined)),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsGrid(postsState),
                _buildPostsList(postsState),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildAvatar(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      try {
        final bytes = base64Decode(base64String.split(',').last);
        return CircleAvatar(
          radius: 40,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback below
      }
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: context.colors.surfaceAlt,
      child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: context.colors.inkMuted,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.colors.ink,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: context.colors.ink.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid(UserPostsState postsState) {
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.colors.ink));
    }
    if (postsState.error != null && postsState.posts.isEmpty) {
      return Center(child: Text('Error loading posts: ${postsState.error}'));
    }

    final posts = postsState.posts;
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: context.colors.inkMuted),
            const SizedBox(height: 16),
            Text('No Posts Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.ink)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length + (postsState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return Center(child: CircularProgressIndicator(color: context.colors.ink));
        }
        final post = posts[index] as Map<String, dynamic>;
        final postId = post['id']?.toString() ?? '';
        final type = post['type']?.toString() ?? '';
        return GestureDetector(
          onTap: () => context.push('/post/details/$postId'),
          child: Container(
            color: context.colors.surfaceAlt,
            child: Center(
              child: Icon(
                type == 'POLL' ? Icons.poll :
                type == 'COMPLAINT' ? Icons.report_problem :
                Icons.article,
                color: context.colors.inkMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsList(UserPostsState postsState) {
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.colors.ink));
    }
    if (postsState.error != null && postsState.posts.isEmpty) {
      return Center(child: Text('Error loading posts: ${postsState.error}'));
    }

    final posts = postsState.posts;
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_list_outlined, size: 64, color: context.colors.inkMuted),
            const SizedBox(height: 16),
            Text('No posts yet', style: TextStyle(fontSize: 16, color: context.colors.inkMuted)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: posts.length + (postsState.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator(color: context.colors.ink)),
          );
        }
        final post = posts[index] as Map<String, dynamic>;
        final postId = post['id']?.toString() ?? '';
        final type = post['type']?.toString() ?? '';
        final authorName = post['authorName']?.toString() ?? '';
        final text = (post['payload'] as Map<String, dynamic>?)?['text']?.toString() ?? type;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: context.colors.surfaceAlt,
            child: Icon(
              type == 'POLL' ? Icons.poll :
              type == 'COMPLAINT' ? Icons.report_problem :
              Icons.article_outlined,
              color: context.colors.inkMuted, size: 18,
            ),
          ),
          title: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: context.colors.ink, fontWeight: FontWeight.w600)),
          subtitle: Text(authorName, style: TextStyle(fontSize: 12, color: context.colors.inkMuted)),
          onTap: () => context.push('/post/details/$postId'),
        );
      },
    );
  }
}

class _FollowButton extends ConsumerWidget {
  final String userId;
  final bool initialIsFollowing;

  const _FollowButton({
    required this.userId,
    required this.initialIsFollowing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Override the initial state to sync with backend data on first load
    final followState = ref.watch(followControllerProvider(userId));
    final controller = ref.read(followControllerProvider(userId).notifier);

    // This is a quick hack to sync the state without complex provider dependencies.
    // In a real app we might pass the initial state into the provider or use a `ref.listen`.
    final isFollowing = followState || initialIsFollowing; 

    return GestureDetector(
      onTap: () {
        controller.setFollowing(isFollowing); // Ensure sync before toggle
        controller.toggleFollow();
      },
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFollowing ? context.colors.surfaceAlt : context.colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            color: isFollowing ? context.colors.ink : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colors.bg,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
