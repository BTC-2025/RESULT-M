import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class ResultsHubScreen extends ConsumerStatefulWidget {
  const ResultsHubScreen({super.key});

  @override
  ConsumerState<ResultsHubScreen> createState() => _ResultsHubScreenState();
}

class _ResultsHubScreenState extends ConsumerState<ResultsHubScreen> {
  int _selectedCategory = 0;

  static const _categories = [
    _Category('All',          null,            Icons.apps_rounded,          Color(0xFFFF6B35)),
    _Category('Academic',     'academic',      Icons.school_rounded,        Color(0xFF8B5CF6)),
    _Category('Sports',       'sports',        Icons.sports_cricket_rounded, Color(0xFF10B981)),
    _Category('Finance',      'finance',       Icons.trending_up_rounded,   Color(0xFFF59E0B)),
    _Category('Politics',     'politics',      Icons.how_to_vote_rounded,   Color(0xFF3B82F6)),
    _Category('Government',   'government',    Icons.account_balance_rounded,Color(0xFF6366F1)),
    _Category('Law',          'law',           Icons.gavel_rounded,         Color(0xFF14B8A6)),
    _Category('Entertainment','entertainment', Icons.movie_rounded,         Color(0xFFEC4899)),
    _Category('Tech',         'tech',          Icons.computer_rounded,      Color(0xFF06B6D4)),
    _Category('Healthcare',   'healthcare',    Icons.local_hospital_rounded, Color(0xFFEF4444)),
    _Category('Business',     'business',      Icons.work_rounded,          Color(0xFFF97316)),
    _Category('Hyper-Local',  'hyperlocal',    Icons.location_city_rounded, Color(0xFF84CC16)),
  ];

  void _onCategoryTap(int index) {
    setState(() => _selectedCategory = index);
    final cat = _categories[index];
    if (cat.key == null) return; // "All" — stay on hub
    context.push('/results/${cat.key}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: context.colors.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Results Hub', style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                )),
                Text('Global Data Publishing Platform', style: TextStyle(
                  color: context.colors.inkFaint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search_rounded, color: context.colors.inkMuted),
                onPressed: () => context.go('/explore'),
              ),
              IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: context.colors.inkMuted),
                onPressed: () => context.push('/notifications'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ─── Category Grid ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CATEGORIES', style: TextStyle(
                    color: context.colors.inkFaint,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      return GestureDetector(
                        onTap: () => _onCategoryTap(i),
                        child: _CategoryTile(category: cat),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ─── Live Now Section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Row(
                children: [
                  _LiveBadge(),
                  const SizedBox(width: 10),
                  Text('Live Now', style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  )),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _LiveCard(
                    title: 'IPL 2026 • Match 45',
                    subtitle: 'CSK vs MI • 18.2 Overs',
                    tag: 'CRICKET',
                    tagColor: const Color(0xFF10B981),
                    score: '168/4',
                    extra: 'RRR: 8.4',
                    color: const Color(0xFF10B981),
                    icon: Icons.sports_cricket_rounded,
                    onTap: () => context.push('/results/sports/cricket/live/1'),
                  ),
                  const SizedBox(width: 12),
                  _LiveCard(
                    title: 'Lok Sabha By-Poll',
                    subtitle: 'Tamil Nadu • 14 Constituencies',
                    tag: 'LIVE VOTES',
                    tagColor: const Color(0xFF3B82F6),
                    score: '234 / 543',
                    extra: 'Seats Declared',
                    color: const Color(0xFF3B82F6),
                    icon: Icons.how_to_vote_rounded,
                    onTap: () => context.push('/results/politics/election/live/1'),
                  ),
                  const SizedBox(width: 12),
                  _LiveCard(
                    title: 'Nifty 50 • Today',
                    subtitle: 'NSE India • Jun 6, 2026',
                    tag: 'MARKET',
                    tagColor: const Color(0xFFF59E0B),
                    score: '24,852.30',
                    extra: '+1.2% ▲',
                    color: const Color(0xFFF59E0B),
                    icon: Icons.trending_up_rounded,
                    onTap: () => context.push('/results/finance/markets/1'),
                  ),
                ],
              ),
            ),
          ),

          // ─── Trending Results ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trending Results', style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  )),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: Text('See All', style: TextStyle(
                      color: context.colors.orange,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                ],
              ),
            ),
          ),

          SliverList.separated(
            itemCount: _trendingItems.length,
            separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              final item = _trendingItems[i];
              return _TrendingTile(item: item);
            },
          ),

          // ─── Quick Access ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Text('Quick Access', style: TextStyle(
                color: context.colors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              )),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _QuickAccessCard(
                    icon: Icons.school_rounded,
                    color: const Color(0xFF8B5CF6),
                    title: 'University Results',
                    subtitle: 'Search by Register No. or Name',
                    onTap: () => context.push('/results/academic'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAccessCard(
                    icon: Icons.work_rounded,
                    color: const Color(0xFF10B981),
                    title: 'Government Jobs & Recruitment',
                    subtitle: 'TNPSC, SSC, UPSC and more',
                    onTap: () => context.push('/results/government'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAccessCard(
                    icon: Icons.location_city_rounded,
                    color: const Color(0xFF84CC16),
                    title: 'Hyper-Local Events',
                    subtitle: 'Local cricket, school sports & more',
                    onTap: () => context.push('/results/hyperlocal'),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ─── Static trending sample data (replaced with real API later) ──────────────
final _trendingItems = [
  _TrendingItem('📖', 'Tamil Nadu 12th Board Results 2026', 'State Board Exams', '2.1M views', const Color(0xFF8B5CF6)),
  _TrendingItem('🏏', 'IPL 2026 Points Table', 'Cricket League', '1.8M views', const Color(0xFF10B981)),
  _TrendingItem('🏛️', 'TNPSC Group 2 Final Selection List', 'Government Recruitment', '980K views', const Color(0xFF6366F1)),
  _TrendingItem('🎬', 'National Film Awards 2026 Winners', 'Entertainment', '750K views', const Color(0xFFEC4899)),
  _TrendingItem('📈', 'Budget 2026 Key Highlights', 'Finance & Economy', '620K views', const Color(0xFFF59E0B)),
];

class _TrendingItem {
  final String emoji, title, subtitle, views;
  final Color color;
  const _TrendingItem(this.emoji, this.title, this.subtitle, this.views, this.color);
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _Category {
  final String label;
  final String? key;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.key, this.icon, this.color);
}

class _CategoryTile extends StatelessWidget {
  final _Category category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: category.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, color: category.color, size: 26),
          const SizedBox(height: 6),
          Text(
            category.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _anim,
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 5),
          const Text('LIVE', style: TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          )),
        ],
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  final String title, subtitle, tag, score, extra;
  final Color tagColor, color;
  final IconData icon;
  final VoidCallback onTap;

  const _LiveCard({
    required this.title, required this.subtitle, required this.tag,
    required this.tagColor, required this.score, required this.extra,
    required this.color, required this.icon, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.18), context.colors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: TextStyle(
                    color: tagColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(
              color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w900, height: 1.3,
            )),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(
              color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w600,
            )),
            const Spacer(),
            Text(score, style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.w900,
            )),
            Text(extra, style: TextStyle(
              color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700,
            )),
          ],
        ),
      ),
    );
  }
}

class _TrendingTile extends StatelessWidget {
  final _TrendingItem item;
  const _TrendingTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
                    color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(item.subtitle, style: TextStyle(
                        color: context.colors.inkMuted, fontSize: 12,
                      )),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: BoxDecoration(
                        color: context.colors.inkFaint, shape: BoxShape.circle,
                      )),
                      const SizedBox(width: 8),
                      Text(item.views, style: TextStyle(
                        color: context.colors.inkFaint, fontSize: 12,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.inkFaint, size: 18),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon, required this.color,
    required this.title, required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w800,
                  )),
                  Text(subtitle, style: TextStyle(
                    color: context.colors.inkMuted, fontSize: 12,
                  )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: context.colors.inkFaint, size: 14),
          ],
        ),
      ),
    );
  }
}
