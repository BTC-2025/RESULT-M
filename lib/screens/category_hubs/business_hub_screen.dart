import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Business/Jobs Hub — Placement Results, Job Listings, Startup Funding
class BusinessHubScreen extends StatefulWidget {
  const BusinessHubScreen({super.key});

  @override
  State<BusinessHubScreen> createState() => _BusinessHubScreenState();
}

class _BusinessHubScreenState extends State<BusinessHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFFF97316),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
              title: const Text('Business & Jobs', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFB923C)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(children: [
                    _Chip('4.2M+', 'Jobs Listed'),
                    const SizedBox(width: 12),
                    _Chip('12K+', 'Companies'),
                    const SizedBox(width: 12),
                    _Chip('Placement', 'Results'),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Placement Results'),
                Tab(text: 'Job Openings'),
                Tab(text: 'Startups'),
                Tab(text: 'Leaderboards'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PlacementTab(),
            _JobsTab(),
            _StartupsTab(),
            _LeaderboardTab(),
          ],
        ),
      ),
    );
  }
}

class _PlacementTab extends StatelessWidget {
  final _placements = const [
    _Placement('IIT Madras', 'BTech 2026 Batch', '1,240 Offers', '₹28.5 LPA Avg', '₹1.8 Cr Peak', Color(0xFFF97316)),
    _Placement('VIT Vellore', 'BTech 2026 Batch', '8,400 Offers', '₹9.2 LPA Avg', '₹72 LPA Peak', Color(0xFF10B981)),
    _Placement('SRM Institute', 'BTech/MBA 2026', '7,200 Offers', '₹7.4 LPA Avg', '₹60 LPA Peak', Color(0xFF3B82F6)),
    _Placement('IIM Ahmedabad', 'MBA PGP 2026', '421 Offers', '₹38.4 LPA Avg', '₹1.1 Cr Peak', Color(0xFF8B5CF6)),
    _Placement('NIT Trichy', 'BTech 2026 Batch', '980 Offers', '₹14.8 LPA Avg', '₹82 LPA Peak', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Text('🎓', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Campus Placement Season 2026', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text('Final Placement Data — All Institutions', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._placements.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: p.color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.institute, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15)),
                    Text(p.batch, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                )),
                Text(p.offers, style: TextStyle(color: p.color, fontWeight: FontWeight.w900, fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _PlaceStat('Average CTC', p.avgCTC, p.color)),
                const SizedBox(width: 8),
                Expanded(child: _PlaceStat('Highest CTC', p.highestCTC, p.color)),
              ]),
            ],
          ),
        )),
      ],
    );
  }
}

class _PlaceStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PlaceStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.colors.inkFaint, fontSize: 10, fontWeight: FontWeight.w700)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}

class _Placement {
  final String institute, batch, offers, avgCTC, highestCTC;
  final Color color;
  const _Placement(this.institute, this.batch, this.offers, this.avgCTC, this.highestCTC, this.color);
}

class _JobsTab extends StatelessWidget {
  final _jobs = const [
    _Job('Senior Flutter Developer', 'Flipkart', 'Bengaluru • ₹25-40 LPA', 'Full-Time', Color(0xFFF97316)),
    _Job('Data Scientist', 'CRED', 'Bengaluru • ₹18-32 LPA', 'Full-Time', Color(0xFF8B5CF6)),
    _Job('Product Manager', 'Zomato', 'Gurugram • ₹30-50 LPA', 'Full-Time', Color(0xFFEF4444)),
    _Job('Backend Engineer', 'PhonePe', 'Bengaluru • ₹20-35 LPA', 'Full-Time', Color(0xFF6366F1)),
    _Job('UI/UX Designer', 'Swiggy', 'Bengaluru • ₹12-22 LPA', 'Full-Time', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: TextField(
            style: TextStyle(color: context.colors.ink),
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              hintStyle: TextStyle(color: context.colors.inkFaint),
              prefixIcon: Icon(Icons.search_rounded, color: context.colors.inkMuted),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._jobs.map((job) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: job.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Center(child: Text(job.company[0], style: TextStyle(
                  color: job.color, fontWeight: FontWeight.w900, fontSize: 18,
                ))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(job.company, style: TextStyle(color: job.color, fontWeight: FontWeight.w700, fontSize: 12)),
                    Text(job.location, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.colors.bg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Text(job.type, style: TextStyle(color: context.colors.inkMuted, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _Job {
  final String title, company, location, type;
  final Color color;
  const _Job(this.title, this.company, this.location, this.type, this.color);
}

class _StartupsTab extends StatelessWidget {
  final _startups = const [
    _Startup('Zomato', 'FoodTech', '₹2,400 Cr raised (2026)', 'Unicorn', Color(0xFFEF4444)),
    _Startup('PhonePe', 'FinTech', '₹4,100 Cr Series D', 'Unicorn', Color(0xFF6366F1)),
    _Startup('Meesho', 'E-Commerce', '₹1,800 Cr raised', 'Unicorn', Color(0xFFF97316)),
    _Startup('Nykaa', 'Beauty & Fashion', '₹900 Cr expansion', 'Listed', Color(0xFFEC4899)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('LATEST FUNDING ROUNDS', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ..._startups.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: s.color.withValues(alpha: 0.15),
                child: Text(s.name[0], style: TextStyle(color: s.color, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
                    Text(s.sector, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(s.funding, style: TextStyle(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(s.stage, style: TextStyle(color: s.color, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _Startup {
  final String name, sector, funding, stage;
  final Color color;
  const _Startup(this.name, this.sector, this.funding, this.stage, this.color);
}

class _LeaderboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rankings = [
      ['#1', 'Tata Group', '₹15.4L Cr Revenue', 'Conglomerate'],
      ['#2', 'Reliance Industries', '₹9.7L Cr Revenue', 'Diversified'],
      ['#3', 'HDFC Bank', '₹4.2L Cr Revenue', 'Banking'],
      ['#4', 'Infosys', '₹3.8L Cr Revenue', 'IT Services'],
      ['#5', 'TCS', '₹3.6L Cr Revenue', 'IT Services'],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('TOP COMPANIES BY REVENUE 2026', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ...rankings.asMap().entries.map((entry) {
          final r = entry.value;
          final colors = [const Color(0xFFFBBF24), const Color(0xFF9CA3AF), const Color(0xFFB45309)];
          final rankColor = entry.key < 3 ? colors[entry.key] : const Color(0xFFF97316);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: entry.key == 0 ? rankColor.withValues(alpha: 0.4) : context.colors.border),
            ),
            child: Row(
              children: [
                SizedBox(width: 32, child: Text(r[0], style: TextStyle(color: rankColor, fontWeight: FontWeight.w900, fontSize: 14))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r[1], style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
                      Text(r[3], style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Text(r[2], style: TextStyle(color: const Color(0xFFF97316), fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String value, label;
  const _Chip(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );
}
