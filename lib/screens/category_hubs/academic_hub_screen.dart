import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AcademicHubScreen extends StatefulWidget {
  const AcademicHubScreen({super.key});

  @override
  State<AcademicHubScreen> createState() => _AcademicHubScreenState();
}

class _AcademicHubScreenState extends State<AcademicHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedExamType = 0;

  static const _examTypes = [
    'All', 'University', 'School Board', 'Entrance', 'Government', 'Global',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF8B5CF6),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
              title: const Text('Academic Hub', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(
                    children: [
                      _StatChip('12M+', 'Students'),
                      const SizedBox(width: 12),
                      _StatChip('8,500+', 'Exams'),
                      const SizedBox(width: 12),
                      _StatChip('2,300+', 'Institutions'),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Search Results'),
                Tab(text: 'Institutions'),
                Tab(text: 'Trending'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _SearchTab(),
            _InstitutionsTab(),
            _TrendingTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Search ─────────────────────────────────────────────────────────
class _SearchTab extends StatelessWidget {
  final _examTypes = const [
    _ExamCategory('University Exams', Icons.account_balance_rounded, Color(0xFF8B5CF6),
        'Anna University, VIT, SRM, and more', '/results/academic/university'),
    _ExamCategory('School Board', Icons.school_rounded, Color(0xFF6366F1),
        'State Board, CBSE, ICSE Results', '/results/academic/school'),
    _ExamCategory('Entrance Exams', Icons.quiz_rounded, Color(0xFF7C3AED),
        'JEE, NEET, CLAT, CAT, GATE', '/results/academic/entrance'),
    _ExamCategory('Government Exams', Icons.gavel_rounded, Color(0xFF5B21B6),
        'TNPSC, UPSC, SSC, RRB, Banking', '/results/academic/govt-exams'),
    _ExamCategory('Global Tests', Icons.language_rounded, Color(0xFF4C1D95),
        'GRE, GMAT, IELTS, TOEFL, SAT', '/results/academic/global'),
    _ExamCategory('Research & Funding', Icons.biotech_rounded, Color(0xFF2E1065),
        'University rankings, grants, patents', '/results/academic/research'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: context.colors.border),
            ),
            child: TextField(
              style: TextStyle(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: 'Search institution or exam...',
                hintStyle: TextStyle(color: context.colors.inkFaint),
                prefixIcon: Icon(Icons.search_rounded, color: context.colors.inkMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('EXAM CATEGORIES', style: TextStyle(
            color: context.colors.inkFaint,
            fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
          )),
          const SizedBox(height: 12),
          ...List.generate(_examTypes.length, (i) {
            final cat = _examTypes[i];
            return _ExamCategoryTile(category: cat);
          }),
        ],
      ),
    );
  }
}

class _ExamCategory {
  final String title, subtitle, route;
  final IconData icon;
  final Color color;
  const _ExamCategory(this.title, this.icon, this.color, this.subtitle, this.route);
}

class _ExamCategoryTile extends StatelessWidget {
  final _ExamCategory category;
  const _ExamCategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push(category.route),
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
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.title, style: TextStyle(
                      color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w800,
                    )),
                    Text(category.subtitle, style: TextStyle(
                      color: context.colors.inkMuted, fontSize: 12,
                    )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab 2: Institutions ───────────────────────────────────────────────────
class _InstitutionsTab extends StatelessWidget {
  final _institutions = const [
    _Institution('Anna University', 'University • Tamil Nadu', '📍 Chennai', Color(0xFF8B5CF6)),
    _Institution('IIT Madras', 'Premier Institute • Central', '📍 Chennai', Color(0xFF7C3AED)),
    _Institution('VIT University', 'Deemed University', '📍 Vellore', Color(0xFF6366F1)),
    _Institution('CBSE Board', 'National Board', '📍 New Delhi', Color(0xFF4F46E5)),
    _Institution('Tamil Nadu State Board', 'State Board', '📍 Chennai', Color(0xFF8B5CF6)),
    _Institution('Bharathidasan University', 'University • Tamil Nadu', '📍 Tiruchirappalli', Color(0xFF7C3AED)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _institutions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final inst = _institutions[i];
        return InkWell(
          onTap: () => context.push('/results/academic/institution/inst-$i'),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: inst.color.withValues(alpha: 0.15),
                  child: Text(inst.name[0], style: TextStyle(
                    color: inst.color, fontSize: 20, fontWeight: FontWeight.w900,
                  )),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inst.name, style: TextStyle(
                        color: context.colors.ink, fontSize: 15, fontWeight: FontWeight.w800,
                      )),
                      Text(inst.type, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                      Text(inst.location, style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Institution {
  final String name, type, location;
  final Color color;
  const _Institution(this.name, this.type, this.location, this.color);
}

// ─── Tab 3: Trending ──────────────────────────────────────────────────────
class _TrendingTab extends StatelessWidget {
  final _trending = const [
    _TrendItem('Tamil Nadu 12th Board Results 2026', 'Released • 8.2M searches today', '🔥'),
    _TrendItem('JEE Mains Session 2 Results', 'Expected this week • 4.1M watching', '📊'),
    _TrendItem('NEET UG 2026 Answer Key', 'Released • 3.9M searches', '🩺'),
    _TrendItem('Anna University Nov 2025 Results', 'Released • 2.3M searches', '🎓'),
    _TrendItem('TNPSC Group 4 Rank List', 'Released • 1.8M searches', '🏛️'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _trending.length,
      separatorBuilder: (_, __) => Divider(height: 1),
      itemBuilder: (context, i) {
        final t = _trending[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: Text(t.emoji, style: const TextStyle(fontSize: 28)),
          title: Text(t.title, style: TextStyle(
            color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 14,
          )),
          subtitle: Text(t.subtitle, style: TextStyle(
            color: context.colors.inkMuted, fontSize: 12,
          )),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text('${i + 1}', style: const TextStyle(
              color: Color(0xFF8B5CF6), fontWeight: FontWeight.w900, fontSize: 12,
            )),
          ),
        );
      },
    );
  }
}

class _TrendItem {
  final String title, subtitle, emoji;
  const _TrendItem(this.title, this.subtitle, this.emoji);
}

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900,
          )),
          Text(label, style: const TextStyle(
            color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
