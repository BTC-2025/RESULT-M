import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:convert';


class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _activeFilter = 0;
  Timer? _debounce;

  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  bool _hasSearched = false;

  final List<String> _filters = ['All', 'People', 'Live', 'Workspaces', 'Datasets', 'VoteBoxes'];
  
  // Mock Data for Premium UI
  final List<String> _recentSearches = ['Anna Univ Results', 'CSK match', 'Local roads'];
  final List<Map<String, dynamic>> _trendingSearches = [
    {'label': 'TN Elections', 'icon': Icons.how_to_vote_rounded, 'color': Colors.blue},
    {'label': 'IPL 2025 Live', 'icon': Icons.sports_cricket_rounded, 'color': Colors.green},
    {'label': 'Anna Univ Results', 'icon': Icons.school_rounded, 'color': Colors.purple},
    {'label': 'Stock Market', 'icon': Icons.trending_up_rounded, 'color': Colors.amber},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _executeQuickSearch(String query) {
    _searchCtrl.text = query;
    _onSearchChanged(query);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final api = ref.read(apiServiceProvider);
      
      List<dynamic> results = [];
      if (_activeFilter == 0) { // All
        results = await api.globalSearch(query);
        final users = await api.searchUsers(query);
        results.addAll(users.map((u) => {
          'id': u['id'],
          'type': 'USER',
          'title': u['name'],
          'description': u['bio'] ?? 'No bio yet',
          'profilePictureBase64': u['profilePictureBase64'],
          'isFollowing': u['isFollowing'] ?? false,
        }));
      } else if (_activeFilter == 1) { // People
        final users = await api.searchUsers(query);
        results = users.map((u) => {
          'id': u['id'],
          'type': 'USER',
          'title': u['name'],
          'description': u['bio'] ?? 'No bio yet',
          'profilePictureBase64': u['profilePictureBase64'],
          'isFollowing': u['isFollowing'] ?? false,
        }).toList();
      } else { // Live, Workspaces, Datasets, VoteBoxes
        results = await api.globalSearch(query);
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Glassmorphism App Bar + Search ─────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 16,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(
                  color: context.colors.bg.withValues(alpha: 0.8),
                ),
              ),
            ),
            title: Container(
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search, color: context.colors.inkFaint, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search workspaces, datasets, votes...',
                        hintStyle: TextStyle(color: context.colors.inkFaint, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close, color: context.colors.inkFaint, size: 18),
                      onPressed: () { 
                        _searchCtrl.clear(); 
                        _onSearchChanged('');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Column(
                children: [
                  Container(height: 1, color: context.colors.border.withValues(alpha: 0.3)),
                  SizedBox(
                    height: 59,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _filters.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final selected = i == _activeFilter;
                        return GestureDetector(
                          onTap: () => setState(() => _activeFilter = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutQuart,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: selected 
                                ? LinearGradient(colors: [context.colors.orange, context.colors.orange.withValues(alpha: 0.8)]) 
                                : null,
                              color: selected ? null : context.colors.surface,
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              border: Border.all(color: selected ? Colors.transparent : context.colors.border),
                              boxShadow: selected ? [
                                BoxShadow(
                                  color: context.colors.orange.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : [],
                            ),
                            child: Text(_filters[i], style: TextStyle(
                              color: selected ? Colors.white : context.colors.inkMuted,
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            )),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_searchCtrl.text.isNotEmpty || _hasSearched)
            _buildSearchResults()
          else
            _buildDiscover(),

          const SliverToBoxAdapter(child: SizedBox(height: 128)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredResults = _searchResults.where((result) {
      if (_activeFilter == 0) return true; // All
      final type = result['type']?.toString();
      if (_activeFilter == 1) return type == 'USER'; // People
      if (_activeFilter == 2) return result['isLive'] == true; // Live
      if (_activeFilter == 3) return type == 'WORKSPACE';
      if (_activeFilter == 4) return type == 'DATASET';
      if (_activeFilter == 5) return type == 'VOTEBOX';
      return true;
    }).toList();

    if (filteredResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.search_off_rounded, size: 48, color: context.colors.inkMuted),
              ),
              const SizedBox(height: 24),
              Text('No results found', style: TextStyle(
                color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 8),
              Text("We couldn't find anything matching your query.\nTry using different keywords.", 
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.inkMuted, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, i) {
        final result = filteredResults[i];
        final type = result['type']?.toString();
        
        IconData iconData = Icons.article_rounded;
        Color color = context.colors.blue;
        if (type == 'WORKSPACE') {
          iconData = Icons.workspaces_rounded;
          color = context.colors.orange;
        } else if (type == 'DATASET') {
          iconData = Icons.dataset_rounded;
          color = context.colors.purple;
        } else if (type == 'VOTEBOX') {
          iconData = Icons.how_to_vote_rounded;
          color = context.colors.green;
        } else if (type == 'USER') {
          iconData = Icons.person_rounded;
          color = context.colors.blue;
        }

        // Staggered Entrance Animation
        return TweenAnimationBuilder<double>(
          key: ValueKey(result['id']),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (type == 'WORKSPACE') {
                    context.push('/workspace/${result['id']}?name=${Uri.encodeComponent(result['title'] ?? 'Workspace')}');
                  } else if (type == 'DATASET') {
                    context.push('/dataset/${result['id']}/search?name=${Uri.encodeComponent(result['title'] ?? 'Dataset')}&domainType=${Uri.encodeComponent(result['domainType'] ?? '')}');
                  } else if (type == 'VOTEBOX') {
                    context.push('/votes/${result['id']}');
                  } else if (type == 'USER') {
                    context.push('/profile/public/${result['id']}');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      if (type == 'USER')
                        _buildUserAvatar(context, result['profilePictureBase64'], result['title'] ?? '')
                      else
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Center(child: Icon(iconData, color: color, size: 22)),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result['title']?.toString() ?? 'Result', style: TextStyle(
                              color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w800,
                            )),
                            const SizedBox(height: 4),
                            Text(result['description']?.toString() ?? type ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(
                              color: context.colors.inkMuted, fontSize: 13, height: 1.3,
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint, size: 20),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, indent: 80, endIndent: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(BuildContext context, String? base64String, String name) {
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
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: context.colors.inkMuted,
        ),
      ),
    );
  }

  Widget _buildDiscover() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Recent & Trending Searches ──────────────────────────────────
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text('Recent', style: TextStyle(
                    color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
                  )),
                  const Spacer(),
                  Text('Clear', style: TextStyle(
                    color: context.colors.purple, fontSize: 13, fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentSearches.length,
                separatorBuilder: (context, idx) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () => _executeQuickSearch(_recentSearches[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 16, color: context.colors.inkMuted),
                          const SizedBox(width: 8),
                          Text(_recentSearches[i], style: TextStyle(
                            color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: context.colors.orange, size: 20),
                const SizedBox(width: 8),
                Text('Trending Now', style: TextStyle(
                  color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              children: _trendingSearches.map((item) {
              return GestureDetector(
                onTap: () => _executeQuickSearch(item['label']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(color: (item['color'] as Color).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item['icon'] as IconData, size: 16, color: item['color'] as Color),
                      const SizedBox(width: 6),
                      Text(item['label'] as String, style: TextStyle(
                        color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
            ),
          ),

          // ─── Browse Categories ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
            child: Text('Browse by Category', style: TextStyle(
              color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
            )),
          ),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryCard(icon: Icons.sports_cricket_rounded, label: 'Sport',  color: context.colors.green, route: '/results/sports'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.menu_book_rounded, label: 'Exams',  color: context.colors.purple, route: '/results/academic'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.how_to_vote_rounded, label: 'Elections', color: context.colors.blue, route: '/results/politics'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.campaign_rounded, label: 'Complaints', color: context.colors.amber, route: '/complaints'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.poll_rounded, label: 'Polls',  color: context.colors.purple, route: '/votes'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.trending_up_rounded, label: 'Finance', color: context.colors.amber, route: '/results/finance'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.gavel_rounded, label: 'Law',    color: context.colors.teal, route: '/results/law'),
                const SizedBox(width: 12),
                _CategoryCard(icon: Icons.computer_rounded, label: 'Tech',   color: context.colors.teal, route: '/results/tech'),
              ],
            ),
          ),

          // ─── Discover Grid ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
            child: Text('Discover Events', style: TextStyle(
              color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
            )),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
            children: [
              _GridCard(
                title: 'IPL 2025\nLive Scores',
                subtitle: 'Match 47 LIVE',
                color: context.colors.green,
                isLive: true,
                route: '/results',
              ),
              _GridCard(
                title: 'Anna Univ\nResults',
                subtitle: 'Nov/Dec 2024 Out',
                color: context.colors.purple,
                badge: 'NEW',
                route: '/results',
              ),
              _GridCard(
                title: 'TN Election\n2025',
                subtitle: 'Live Counting',
                color: context.colors.blue,
                isLive: true,
                route: '/results',
              ),
              _GridCard(
                title: 'Top\nComplaints',
                subtitle: '1.2K posts today',
                color: context.colors.amber,
                route: '/complaints',
              ),
              _GridCard(
                title: 'Trending\nPolls',
                subtitle: '48 active now',
                color: context.colors.purple,
                route: '/votes',
              ),
              _GridCard(
                title: 'F1 Monaco\nGrand Prix',
                subtitle: 'Lap 52 of 78',
                color: context.colors.orange,
                isLive: true,
                route: '/results',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _CategoryCard({required this.icon, required this.label, required this.color, required this.route});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.push(widget.route);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0.15),
                widget.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 28, color: widget.color),
              ),
              const SizedBox(height: 10),
              Text(widget.label, style: TextStyle(
                color: widget.color.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w900,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool isLive;
  final String? badge;
  final String? route;

  const _GridCard({
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLive = false,
    this.badge,
    this.route,
  });

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrlForTitle(widget.title);
    final icon = _iconForTitle(widget.title);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (widget.route != null) context.push(widget.route!);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.18),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: widget.color.withValues(alpha: 0.18));
                  },
                ),
                // Premium Gradient Overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                            ],
                          ),
                          child: Icon(icon, color: widget.color, size: 20),
                        ),
                        const Spacer(),
                        if (widget.isLive) const LiveBadge(),
                        if (widget.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              boxShadow: [
                                BoxShadow(color: widget.color.withValues(alpha: 0.3), blurRadius: 6),
                              ],
                            ),
                            child: Text(widget.badge!, style: TextStyle(
                              color: widget.color, fontSize: 9,
                              fontWeight: FontWeight.w900, letterSpacing: 1.0,
                            )),
                          ),
                      ]),
                      const Spacer(),
                      Text(widget.title, style: const TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w900, height: 1.25,
                        letterSpacing: -0.3,
                      )),
                      const SizedBox(height: 6),
                      Text(widget.subtitle, style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _imageUrlForTitle(String value) {
    final key = value.toLowerCase();
    if (key.contains('ipl')) {
      return 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&w=900&q=80';
    }
    if (key.contains('anna')) {
      return 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=900&q=80';
    }
    if (key.contains('election')) {
      return 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?auto=format&fit=crop&w=900&q=80';
    }
    if (key.contains('complaint')) {
      return 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=900&q=80';
    }
    if (key.contains('poll')) {
      return 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=900&q=80';
    }
    return 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=900&q=80';
  }

  IconData _iconForTitle(String value) {
    final key = value.toLowerCase();
    if (key.contains('ipl')) return Icons.sports_cricket;
    if (key.contains('anna')) return Icons.school;
    if (key.contains('election')) return Icons.how_to_vote;
    if (key.contains('complaint')) return Icons.campaign;
    if (key.contains('poll')) return Icons.poll;
    return Icons.sports_motorsports;
  }
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.liveRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: context.colors.liveRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: context.colors.liveRed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('LIVE', style: TextStyle(
            color: context.colors.liveRed, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0,
          )),
        ],
      ),
    );
  }
}
