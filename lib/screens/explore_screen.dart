import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'dart:async';

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

  final List<String> _filters = ['All', 'Live', 'Workspaces', 'Datasets', 'VoteBoxes'];

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

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final results = await api.globalSearch(query);
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
          // ─── App Bar + Search ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: context.colors.bg,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search, color: context.colors.inkFaint, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: context.colors.ink, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search workspaces, datasets, votes...',
                        hintStyle: TextStyle(color: context.colors.inkFaint, fontSize: 13),
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
                      icon: Icon(Icons.close, color: context.colors.inkFaint, size: 16),
                      onPressed: () { 
                        _searchCtrl.clear(); 
                        _onSearchChanged('');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(57),
              child: Column(
                children: [
                  Container(height: 1, color: context.colors.border),
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: _filters.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final selected = i == _activeFilter;
                        return GestureDetector(
                          onTap: () => setState(() => _activeFilter = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected ? context.colors.orange : context.colors.surface,
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              border: Border.all(color: selected ? context.colors.orange : context.colors.border),
                            ),
                            child: Text(_filters[i], style: TextStyle(
                              color: selected ? Colors.white : context.colors.inkMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
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

    if (_searchResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: context.colors.inkFaint),
              const SizedBox(height: 16),
              Text('No results found', style: TextStyle(color: context.colors.inkMuted)),
            ],
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final result = _searchResults[i];
        final type = result['type']?.toString();
        
        IconData iconData = Icons.article;
        Color color = context.colors.blue;
        if (type == 'WORKSPACE') {
          iconData = Icons.workspaces;
          color = context.colors.orange;
        } else if (type == 'DATASET') {
          iconData = Icons.dataset;
          color = context.colors.purple;
        } else if (type == 'VOTEBOX') {
          iconData = Icons.how_to_vote;
          color = context.colors.green;
        }

        return InkWell(
          onTap: () {
            if (type == 'WORKSPACE') {
              context.push('/workspace/${result['id']}?name=${Uri.encodeComponent(result['title'] ?? 'Workspace')}');
            } else if (type == 'DATASET') {
              context.push('/dataset/${result['id']}/search?name=${Uri.encodeComponent(result['title'] ?? 'Dataset')}&domainType=${Uri.encodeComponent(result['domainType'] ?? '')}');
            } else if (type == 'VOTEBOX') {
              context.push('/votes/${result['id']}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Center(child: Icon(iconData, color: color, size: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result['title']?.toString() ?? 'Result', style: TextStyle(
                        color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w700,
                      )),
                      const SizedBox(height: 3),
                      Text(result['description']?.toString() ?? type ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(
                        color: context.colors.inkMuted, fontSize: 12,
                      )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.inkFaint, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscover() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text('Browse by Category', style: TextStyle(
              color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
            )),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryCard(emoji: '🏏', label: 'Sport',  color: context.colors.green),
                SizedBox(width: 10),
                _CategoryCard(emoji: '📖', label: 'Exams',  color: context.colors.purple),
                SizedBox(width: 10),
                _CategoryCard(emoji: '🗳️', label: 'Elections', color: context.colors.blue),
                SizedBox(width: 10),
                _CategoryCard(emoji: '📣', label: 'Complaints', color: context.colors.amber),
                SizedBox(width: 10),
                _CategoryCard(emoji: '🗳️', label: 'Polls',  color: context.colors.purple),
                SizedBox(width: 10),
                _CategoryCard(emoji: '💹', label: 'Finance', color: context.colors.amber),
                SizedBox(width: 10),
                _CategoryCard(emoji: '⚖️', label: 'Law',    color: context.colors.teal),
                SizedBox(width: 10),
                _CategoryCard(emoji: '💻', label: 'Tech',   color: context.colors.teal),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text('Discover', style: TextStyle(
              color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
            )),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: [
              _GridCard(
                emoji: '🏏',
                title: 'IPL 2025\nLive Scores',
                subtitle: 'Match 47 LIVE',
                color: context.colors.green,
                isLive: true,
                route: '/results',
              ),
              _GridCard(
                emoji: '📖',
                title: 'Anna Univ\nResults',
                subtitle: 'Nov/Dec 2024 Out',
                color: context.colors.purple,
                badge: 'NEW',
                route: '/results',
              ),
              _GridCard(
                emoji: '🗳️',
                title: 'TN Election\n2025',
                subtitle: 'Live Counting',
                color: context.colors.blue,
                isLive: true,
                route: '/results',
              ),
              _GridCard(
                emoji: '📣',
                title: 'Top\nComplaints',
                subtitle: '1.2K posts today',
                color: context.colors.amber,
                route: '/complaints',
              ),
              _GridCard(
                emoji: '🗳️',
                title: 'Trending\nPolls',
                subtitle: '48 active now',
                color: context.colors.purple,
                route: '/votes',
              ),
              _GridCard(
                emoji: '🏎️',
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
class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _CategoryCard({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w800,
            )),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLive;
  final String? badge;
  final String? route;

  const _GridCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLive = false,
    this.badge,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrlForTitle(title);
    final icon = _iconForTitle(title);

    return GestureDetector(
      onTap: route != null ? () => context.push(route!) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            border: Border.all(color: context.colors.border),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: color.withValues(alpha: 0.18));
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Icon(icon, color: color, size: 19),
                      ),
                      const Spacer(),
                      if (isLive) const LiveBadge(),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Text(badge!, style: TextStyle(
                            color: color, fontSize: 8,
                            fontWeight: FontWeight.w900, letterSpacing: 0.8,
                          )),
                        ),
                    ]),
                    const Spacer(),
                    Text(title, style: const TextStyle(
                      color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w900, height: 1.25,
                    )),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    )),
                  ],
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
          const SizedBox(width: 4),
          Text('LIVE', style: TextStyle(
            color: context.colors.liveRed, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0,
          )),
        ],
      ),
    );
  }
}
