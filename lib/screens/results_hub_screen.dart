import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/workspace_provider.dart';
import '../services/sports_api_service.dart';

class ResultsHubScreen extends ConsumerStatefulWidget {
  const ResultsHubScreen({super.key});

  @override
  ConsumerState<ResultsHubScreen> createState() => _ResultsHubScreenState();
}

class _ResultsHubScreenState extends ConsumerState<ResultsHubScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(globalAnalyticsProvider);
    final allWorkspacesAsync = ref.watch(publicWorkspacesProvider(null));
    final liveFootballAsync = ref.watch(liveFootballProvider);
    final liveCricketAsync = ref.watch(currentCricketMatchesProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: RefreshIndicator(
        color: context.colors.purple,
        onRefresh: () async {
          ref.invalidate(liveFootballProvider);
          ref.invalidate(currentCricketMatchesProvider);
          ref.invalidate(globalAnalyticsProvider);
          ref.invalidate(publicWorkspacesProvider(null));
          // Optional: give it a slight delay so the spinner shows briefly
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _buildFeaturedCarousel(liveCricketAsync, liveFootballAsync, allWorkspacesAsync),
            _buildSectionHeader('Live Now', Icons.sensors, context.colors.liveRed, actionText: 'View All Live'),
            _buildLiveNow(liveFootballAsync, liveCricketAsync),
            _buildSectionHeader('Browse Categories', Icons.category_rounded, context.colors.blue),
            _buildCategories(),
            _buildSectionHeader('Trending Results', Icons.local_fire_department_rounded, context.colors.orange),
            _buildTrending(allWorkspacesAsync),
            _buildSectionHeader('Recent Publications', Icons.history_rounded, context.colors.purple),
            _buildRecentPublications(allWorkspacesAsync),
            _buildSectionHeader('Quick Access', Icons.bolt_rounded, context.colors.amber),
            _buildQuickAccess(),
            _buildSectionHeader('Featured Publishers', Icons.verified_rounded, context.colors.green),
            _buildOrganizations(allWorkspacesAsync),
            _buildSectionHeader('Popular Datasets', Icons.dataset_rounded, context.colors.blue),
            _buildPopularDatasets(allWorkspacesAsync),
            _buildSectionHeader('Platform Overview', Icons.analytics_rounded, context.colors.teal),
            _buildStatistics(analyticsAsync),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: context.colors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: _isScrolled ? 4 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.corporate_fare_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('ResultHub', style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded, color: context.colors.ink),
                    onPressed: () => context.push('/notifications'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GestureDetector(
            onTap: () => context.go('/explore'),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
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
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: context.colors.inkMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Search results, organizations, datasets...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.inkFaint,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: context.colors.bg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Text('⌘ K', style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, {String? actionText}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(
              color: context.colors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            )),
            const Spacer(),
            if (actionText != null)
              Text(actionText, style: TextStyle(
                color: context.colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(AsyncValue<List<CricketMatch>> cricketAsync, AsyncValue<List<FootballMatch>> footballAsync, AsyncValue<List<dynamic>> workspacesAsync) {
    List<Widget> cards = [];

    // Add Dynamic Workspaces
    workspacesAsync.whenData((workspaces) {
      final featured = workspaces.take(2).toList();
      for (int i = 0; i < featured.length; i++) {
        final ws = featured[i] as Map<String, dynamic>;
        final name = ws['name'] ?? ws['title'] ?? 'Dataset';
        final domain = ws['domainType'] ?? ws['category'] ?? 'GENERAL';
        final id = ws['id']?.toString() ?? '';
        final slug = ws['slug']?.toString() ?? id;
        
        cards.add(
          _FeaturedCard(
            title: name,
            publisher: 'Featured Publisher',
            tag: _formatDomain(domain).toUpperCase(),
            tagColor: i == 0 ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
            gradient: i == 0 ? const [Color(0xFF1A3A5C), Color(0xFF2D5E8E)] : const [Color(0xFF1E3A5F), Color(0xFF1B4F8A)],
            onTap: () => context.push('/workspace/$slug'),
          ),
        );
        cards.add(const SizedBox(width: 16));
      }
    });

    if (cards.isEmpty) {
      cards = [
        _FeaturedCard(
          title: 'Welcome to ResultHub',
          publisher: 'Platform Administrator',
          tag: 'SYSTEM',
          tagColor: const Color(0xFF8B5CF6),
          gradient: const [Color(0xFF1A3A5C), Color(0xFF2D5E8E)],
        ),
        const SizedBox(width: 16),
      ];
    }

    // Add Real Cricket Live
    cricketAsync.whenData((matches) {
      final live = matches.where((m) => m.matchStarted && !m.matchEnded).toList();
      if (live.isNotEmpty) {
        final match = live.first;
        cards.add(
          _FeaturedCard(
            title: match.name,
            publisher: match.matchType.toUpperCase(),
            tag: 'CRICKET',
            tagColor: const Color(0xFF10B981),
            gradient: const [Color(0xFF022C22), Color(0xFF064E3B), Color(0xFF042F2E)],
            logo1: match.teamAImg,
            logo2: match.teamBImg,
            bgWatermark: match.teamAImg,
            onTap: () => context.push('/results/sports/cricket/live/${match.id}', extra: match),
          ),
        );
        cards.add(const SizedBox(width: 16));
      }
    });

    // Add Real Football Live
    footballAsync.whenData((matches) {
      final live = matches.where((m) => m.isLive).toList();
      if (live.isNotEmpty) {
        final match = live.first;
        cards.add(
          _FeaturedCard(
            title: '${match.teamHome} vs ${match.teamAway}',
            publisher: match.round.isNotEmpty ? '${match.leagueName} • ${match.round}' : match.leagueName,
            tag: 'FOOTBALL',
            tagColor: const Color(0xFF3B82F6),
            gradient: const [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF172554)],
            logo1: match.teamHomeLogo,
            logo2: match.teamAwayLogo,
            bgWatermark: match.leagueLogo,
            onTap: () => context.push('/results/sports/football/live/${match.id}', extra: match),
          ),
        );
      }
    });

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          children: cards,
        ),
      ),
    );
  }

  Widget _buildLiveNow(AsyncValue<List<FootballMatch>> footballAsync, AsyncValue<List<CricketMatch>> cricketAsync) {
    final List<Widget> liveCards = [];

    // Add Live Cricket Matches (matchStarted && !matchEnded)
    cricketAsync.whenData((matches) {
      final live = matches.where((m) => m.matchStarted && !m.matchEnded).toList();
      for (final match in live) {
        final s1 = match.score1;
        final s2 = match.score2;
        final scoreStr = s1 != null
            ? (s2 != null ? '${s1.runs}/${s1.wickets} – ${s2.runs}/${s2.wickets}' : '${s1.runs}/${s1.wickets}')
            : 'Live';

        liveCards.add(
          _LiveNowCard(
            title: '${match.teamA} vs ${match.teamB}',
            subtitle: match.name,
            value: scoreStr,
            trend: match.status,
            category: 'Cricket',
            icon: Icons.sports_cricket_rounded,
            onTap: () => context.push('/results/sports/cricket/live/${match.id}', extra: match),
          ),
        );
        liveCards.add(const SizedBox(width: 12));
      }
    });

    // Add Live Football Matches
    footballAsync.whenData((matches) {
      for (final match in matches) {
        liveCards.add(
          _LiveNowCard(
            title: '${match.teamHome} vs ${match.teamAway}',
            subtitle: match.round.isNotEmpty ? '${match.leagueName} • ${match.round}' : match.leagueName,
            value: '${match.scoreHome ?? 0} - ${match.scoreAway ?? 0}',
            trend: "${match.displayStatus} • Live",
            category: 'Football',
            icon: Icons.sports_soccer_rounded,
            onTap: () => context.push('/results/sports/football/live/${match.id}', extra: match),
          ),
        );
        liveCards.add(const SizedBox(width: 12));
      }
    });

    // If no live sports, show some static placeholders or fallback
    if (liveCards.isEmpty) {
      liveCards.add(
        _LiveNowCard(
          title: 'Nifty 50 Index',
          subtitle: 'NSE India • Market Open',
          value: '24,852.30',
          trend: '+1.2% ▲',
          category: 'Market',
          icon: Icons.trending_up_rounded,
          onTap: () => context.push('/results/finance'),
        ),
      );
      liveCards.add(const SizedBox(width: 12));
      liveCards.add(
        _LiveNowCard(
          title: 'Lok Sabha By-Poll',
          subtitle: 'Tamil Nadu • Counting in Progress',
          value: '234 / 543',
          trend: 'Seats Declared',
          category: 'Election',
          icon: Icons.how_to_vote_rounded,
          onTap: () => context.push('/results/politics'),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          children: liveCards,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.school_rounded, 'label': 'Academic', 'color': const Color(0xFF8B5CF6), 'path': '/domain/ACADEMIC?title=Academic'},
      {'icon': Icons.account_balance_rounded, 'label': 'Government', 'color': const Color(0xFF6366F1), 'path': '/domain/GOVERNMENT?title=Government'},
      {'icon': Icons.sports_cricket_rounded, 'label': 'Sports', 'color': const Color(0xFF10B981), 'path': '/domain/SPORT?title=Sports'},
      {'icon': Icons.how_to_vote_rounded, 'label': 'Politics', 'color': const Color(0xFF3B82F6), 'path': '/domain/POLITICS?title=Politics'},
      {'icon': Icons.trending_up_rounded, 'label': 'Finance', 'color': const Color(0xFFF59E0B), 'path': '/domain/FINANCE?title=Finance'},
      {'icon': Icons.movie_rounded, 'label': 'Entertainment', 'color': const Color(0xFFEC4899), 'path': '/domain/ENTERTAINMENT?title=Entertainment'},
      {'icon': Icons.computer_rounded, 'label': 'Technology', 'color': const Color(0xFF06B6D4), 'path': '/domain/TECH?title=Technology'},
      {'icon': Icons.gavel_rounded, 'label': 'Law', 'color': const Color(0xFF64748B), 'path': '/domain/LAW?title=Law'},
      {'icon': Icons.local_hospital_rounded, 'label': 'Healthcare', 'color': const Color(0xFFEF4444), 'path': '/domain/HEALTHCARE?title=Healthcare'},
      {'icon': Icons.business_rounded, 'label': 'Business', 'color': const Color(0xFFF97316), 'path': '/domain/BUSINESS?title=Business'},
      {'icon': Icons.location_city_rounded, 'label': 'Hyper Local', 'color': const Color(0xFF84CC16), 'path': '/domain/HYPERLOCAL?title=Hyper Local'},
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final cat = categories[i];
            final color = cat['color'] as Color;
            return GestureDetector(
              onTap: () => context.push(cat['path'] as String),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Icon(cat['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(cat['label'] as String, style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrending(AsyncValue<List<dynamic>> workspacesAsync) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: workspacesAsync.when(
        loading: () => SliverToBoxAdapter(child: _buildSkeletonList(5, height: 72)),
        error: (_, __) => _buildFallbackTrending(),
        data: (workspaces) {
          if (workspaces.isEmpty) return _buildFallbackTrending();
          
          final trending = workspaces.take(5).toList();
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final ws = trending[i] as Map<String, dynamic>;
                final name = ws['name'] ?? ws['title'] ?? 'Dataset';
                final domain = ws['domainType'] ?? ws['category'] ?? 'GENERAL';
                final id = ws['id']?.toString() ?? '';
                final slug = ws['slug']?.toString() ?? id;
                
                return GestureDetector(
                  onTap: () => context.push('/workspace/$slug'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Text('${i + 1}', style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        )),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
                                color: context.colors.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              )),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(_formatDomain(domain), style: TextStyle(
                                    color: context.colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  )),
                                  Text(' • Trending', style: TextStyle(
                                    color: context.colors.inkFaint,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: context.colors.inkFaint),
                      ],
                    ),
                  ),
                );
              },
              childCount: trending.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackTrending() {
    final trending = [
      {'rank': '1', 'title': 'UPSC Civil Services Final Merit List 2026', 'category': 'Government', 'views': '2.1M views', 'path': '/results/government'},
      {'rank': '2', 'title': 'Tamil Nadu State Board Class 12 Results', 'category': 'Academic', 'views': '1.8M views', 'path': '/results/academic'},
      {'rank': '3', 'title': 'NVIDIA RTX 5090 Benchmark Scores', 'category': 'Technology', 'views': '980K views', 'path': '/results/tech'},
      {'rank': '4', 'title': 'Supreme Court Electoral Bonds Verdict', 'category': 'Law', 'views': '850K views', 'path': '/results/law'},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final item = trending[i];
          return GestureDetector(
            onTap: () => context.push(item['path']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Text(item['rank']!, style: TextStyle(
                    color: context.colors.inkMuted,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        )),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(item['category']!, style: TextStyle(
                              color: context.colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                            Text(' • ${item['views']}', style: TextStyle(
                              color: context.colors.inkFaint,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.colors.inkFaint),
                ],
              ),
            ),
          );
        },
        childCount: trending.length,
      ),
    );
  }

  Widget _buildRecentPublications(AsyncValue<List<dynamic>> workspacesAsync) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: workspacesAsync.when(
          loading: () => _buildSkeletonList(4, height: 60),
          error: (_, __) => _buildFallbackRecentPublications(),
          data: (workspaces) {
            if (workspaces.isEmpty) return _buildFallbackRecentPublications();
            final items = workspaces.take(5).toList();
            return Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final ws = entry.value as Map<String, dynamic>;
                final name = ws['name'] ?? ws['title'] ?? 'Unknown';
                final domain = ws['domainType'] ?? ws['category'] ?? 'GENERAL';
                final updatedAt = ws['updatedAt'] ?? ws['createdAt'] ?? ws['publishedAt'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: context.colors.purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.bg, width: 2),
                            ),
                          ),
                          if (i != items.length - 1)
                            Container(width: 2, height: 50, color: context.colors.border),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_formatDomain(domain), style: TextStyle(
                                  color: context.colors.inkMuted,
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                )),
                                const Spacer(),
                                Text(
                                  _timeAgo(updatedAt),
                                  style: TextStyle(color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(name, style: TextStyle(
                              color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w800,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackRecentPublications() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'No recent publications available.',
        style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
      ),
    );
  }

  Widget _buildQuickAccess() {
    final accessLinks = [
      {'title': 'Exam Results', 'icon': Icons.school_rounded, 'color': const Color(0xFF8B5CF6), 'path': '/results/academic'},
      {'title': 'Recruitment', 'icon': Icons.work_rounded, 'color': const Color(0xFF14B8A6), 'path': '/results/government'},
      {'title': 'Sports Scores', 'icon': Icons.sports_cricket_rounded, 'color': const Color(0xFF10B981), 'path': '/results/sports'},
      {'title': 'Election Live', 'icon': Icons.how_to_vote_rounded, 'color': const Color(0xFF3B82F6), 'path': '/results/politics'},
      {'title': 'Court Orders', 'icon': Icons.gavel_rounded, 'color': const Color(0xFF64748B), 'path': '/results/law'},
      {'title': 'Market Reports', 'icon': Icons.trending_up_rounded, 'color': const Color(0xFFF59E0B), 'path': '/results/finance'},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final link = accessLinks[i];
            final color = link['color'] as Color;
            return GestureDetector(
              onTap: () => context.push(link['path'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Icon(link['icon'] as IconData, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(link['title'] as String, style: TextStyle(
                        color: context.colors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: accessLinks.length,
        ),
      ),
    );
  }

  Widget _buildOrganizations(AsyncValue<List<dynamic>> workspacesAsync) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: workspacesAsync.when(
          loading: () => _buildSkeletonRow(5, width: 140, height: 160),
          error: (_, __) => _buildFallbackOrganizations(),
          data: (workspaces) {
            if (workspaces.isEmpty) return _buildFallbackOrganizations();
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: workspaces.length.clamp(0, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final ws = workspaces[i] as Map<String, dynamic>;
                final name = ws['name'] ?? ws['title'] ?? 'Unknown';
                final domain = ws['domainType'] ?? ws['category'] ?? 'GENERAL';
                final id = ws['id']?.toString() ?? '';
                final slug = ws['slug']?.toString() ?? id;
                return GestureDetector(
                  onTap: () => context.push('/workspace/$slug'),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: context.colors.blue.withValues(alpha: 0.1),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(color: context.colors.blue, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const Spacer(),
                        Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(
                          color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w800,
                        )),
                        const SizedBox(height: 4),
                        Text(_formatDomain(domain), style: TextStyle(
                          color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackOrganizations() {
    final orgs = [
      {'name': 'TNPSC', 'datasets': '86 Datasets', 'cat': 'Government'},
      {'name': 'Election Comm.', 'datasets': '45 Datasets', 'cat': 'Politics'},
      {'name': 'Supreme Court', 'datasets': '1,420 Datasets', 'cat': 'Law'},
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: orgs.length,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (context, i) {
        final org = orgs[i];
        return Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: context.colors.blue.withValues(alpha: 0.1),
                child: Text(org['name']![0], style: TextStyle(color: context.colors.blue, fontWeight: FontWeight.w900)),
              ),
              const Spacer(),
              Text(org['name']!, style: TextStyle(color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(org['cat']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(org['datasets']!, style: TextStyle(color: context.colors.orange, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularDatasets(AsyncValue<List<dynamic>> workspacesAsync) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: workspacesAsync.when(
        loading: () => SliverToBoxAdapter(child: _buildSkeletonGrid(4)),
        error: (_, __) => _buildFallbackPopularDatasets(),
        data: (workspaces) {
          if (workspaces.isEmpty) return _buildFallbackPopularDatasets();
          final items = workspaces.take(4).toList();
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final ws = items[i] as Map<String, dynamic>;
                final name = ws['name'] ?? ws['title'] ?? 'Dataset';
                final domain = ws['domainType'] ?? ws['category'] ?? 'GENERAL';
                final id = ws['id']?.toString() ?? '';
                final slug = ws['slug']?.toString() ?? id;
                return GestureDetector(
                  onTap: () => context.push('/workspace/$slug'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDomain(domain), style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                        )),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(name, style: TextStyle(
                            color: context.colors.ink,
                            fontSize: 13, fontWeight: FontWeight.w800, height: 1.2,
                          )),
                        ),
                        Text('Published', style: TextStyle(
                          color: context.colors.blue, fontSize: 11, fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackPopularDatasets() {
    final datasets = [
      {'title': 'State Board Class 12th Results 2026', 'records': '12.4M records', 'org': 'State Board'},
      {'title': 'Railway Recruitment Board Group D', 'records': '5.2M records', 'org': 'RRB India'},
      {'title': 'General Elections Constituency Wise', 'records': '1.1M records', 'org': 'Election Commission'},
    ];
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final ds = datasets[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ds['org']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(ds['title']!, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w800, height: 1.2)),
                ),
                Text(ds['records']!, style: TextStyle(color: context.colors.blue, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        },
        childCount: datasets.length,
      ),
    );
  }

  Widget _buildStatistics(AsyncValue<Map<String, dynamic>> analyticsAsync) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: analyticsAsync.when(
        loading: () => SliverToBoxAdapter(child: _buildSkeletonGrid(4)),
        error: (_, __) => _buildFallbackStatistics(),
        data: (data) {
          final stats = [
            {'label': 'Organizations', 'val': _formatNumber(data['totalOrganizations'] ?? data['totalWorkspaces'] ?? 1245)},
            {'label': 'Total Results', 'val': _formatNumber(data['totalResults'] ?? data['totalRecords'] ?? 45000000, suffix: '+')},
            {'label': 'Live Events', 'val': _formatNumber(data['liveEvents'] ?? data['activeDatasets'] ?? 12)},
            {'label': 'Published Datasets', 'val': _formatNumber(data['publishedDatasets'] ?? data['totalDatasets'] ?? 12500)},
          ];
          return _buildStatsGrid(stats);
        },
      ),
    );
  }

  Widget _buildFallbackStatistics() {
    final stats = [
      {'label': 'Organizations', 'val': '1,245'},
      {'label': 'Total Results', 'val': '45M+'},
      {'label': 'Live Events', 'val': '12'},
      {'label': 'Published Datasets', 'val': '12,500'},
    ];
    return _buildStatsGrid(stats);
  }

  Widget _buildStatsGrid(List<Map<String, String>> stats) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stats[i]['val']!, style: TextStyle(
                  color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900,
                )),
                const SizedBox(height: 4),
                Text(stats[i]['label']!, style: TextStyle(
                  color: context.colors.inkMuted, fontSize: 12, fontWeight: FontWeight.w600,
                )),
              ],
            ),
          );
        },
        childCount: stats.length,
      ),
    );
  }

  // ─── Skeleton Loaders ────────────────────────────────────────────────────────

  Widget _buildSkeletonList(int count, {double height = 48}) {
    return Column(
      children: List.generate(count, (i) => Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
      )),
    );
  }

  Widget _buildSkeletonRow(int count, {required double width, required double height}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid(int count) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDomain(String domain) {
    final map = {
      'EDUCATION': 'Academic', 'ACADEMIC': 'Academic',
      'SPORTS': 'Sports', 'SPORT': 'Sports',
      'POLITICS': 'Politics', 'ELECTION': 'Election',
      'FINANCE': 'Finance', 'MARKET': 'Finance',
      'GOVERNMENT': 'Government', 'GOV': 'Government',
      'LAW': 'Law', 'COURT': 'Law',
      'HEALTHCARE': 'Healthcare', 'HEALTH': 'Healthcare',
      'ENTERTAINMENT': 'Entertainment',
      'TECH': 'Technology', 'TECHNOLOGY': 'Technology',
      'BUSINESS': 'Business',
      'HYPERLOCAL': 'Hyper Local',
    };
    return map[domain.toUpperCase()] ?? domain;
  }

  String _formatNumber(dynamic raw, {String suffix = ''}) {
    if (raw == null) return 'N/A';
    final n = (raw is int) ? raw : int.tryParse(raw.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M$suffix';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}K$suffix';
    return '$n$suffix';
  }

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Recently';
    }
  }
}

// ─── Featured Card ────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final String title, publisher, tag;
  final Color tagColor;
  final List<Color> gradient;
  final String? logo1, logo2;
  final String? bgWatermark;
  final VoidCallback? onTap;

  const _FeaturedCard({
    required this.title,
    required this.publisher,
    required this.tag,
    required this.tagColor,
    required this.gradient,
    this.logo1,
    this.logo2,
    this.bgWatermark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (bgWatermark != null && bgWatermark!.isNotEmpty)
            Positioned(
              right: -30,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Image.network(
                  bgWatermark!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.3),
                  border: Border.all(color: tagColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag, style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                )),
              ),
              const Spacer(),
              const LiveBadge(),
            ],
          ),
          const Spacer(),
          if (logo1 != null && logo2 != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: logo1!.isNotEmpty ? NetworkImage(logo1!) : null,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('VS', style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    )),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: logo2!.isNotEmpty ? NetworkImage(logo2!) : null,
                  ),
                ],
              ),
            ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(publisher, style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Live Now Card ────────────────────────────────────────────────────────────
class _LiveNowCard extends StatelessWidget {
  final String title, subtitle, value, category;
  final String? trend;
  final IconData icon;
  final VoidCallback? onTap;

  const _LiveNowCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.category,
    this.trend,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.liveRed.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: context.colors.liveRed.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.colors.liveRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: context.colors.liveRed, size: 16),
                ),
                const SizedBox(width: 8),
                Text(category, style: TextStyle(
                  color: context.colors.inkMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.liveRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(title, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.inkFaint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(value, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(trend!, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
