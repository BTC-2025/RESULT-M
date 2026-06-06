import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Hyper-Local Hub — Community tournaments, tuition centers, local events
class HyperLocalHubScreen extends StatefulWidget {
  const HyperLocalHubScreen({super.key});

  @override
  State<HyperLocalHubScreen> createState() => _HyperLocalHubScreenState();
}

class _HyperLocalHubScreenState extends State<HyperLocalHubScreen>
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
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF84CC16),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 64),
              title: const Text('Hyper-Local Hub', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF65A30D), Color(0xFF84CC16), Color(0xFFA3E635)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
                  child: Row(children: [
                    _Chip('Your', 'Community'),
                    const SizedBox(width: 12),
                    _Chip('Local', 'Events'),
                    const SizedBox(width: 12),
                    _Chip('Private', 'Accessible'),
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
                Tab(text: 'Local Sports'),
                Tab(text: 'Tuition Centers'),
                Tab(text: 'Corporate Events'),
                Tab(text: 'Community'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _LocalSportsTab(),
            _TuitionTab(),
            _CorporateTab(),
            _CommunityTab(),
          ],
        ),
      ),
    );
  }
}

class _LocalSportsTab extends StatelessWidget {
  final _tournaments = const [
    _Tournament('Perambur Inter-Mohalla Cricket 2026', 'Gully Cricket', '16 Teams', 'Finals Today', Color(0xFF84CC16)),
    _Tournament('Ashok Nagar Turf Football League', 'Turf Football', '12 Teams', 'Semifinals', Color(0xFF10B981)),
    _Tournament('Chromepet Badminton Open', 'Badminton Academy', '48 Players', 'QF in Progress', Color(0xFF06B6D4)),
    _Tournament('T. Nagar Chess Club Tournament', 'Chess League', '32 Players', 'Round 6/7', Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF84CC16).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: const Color(0xFF84CC16).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Showing: Chennai, Tamil Nadu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Change Location →', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._tournaments.map((t) => GestureDetector(
          onTap: () => context.push('/results/hyperlocal/sports/${t.name.hashCode}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: t.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Center(child: Text(
                    t.sport == 'Gully Cricket' ? '🏏'
                        : t.sport == 'Turf Football' ? '⚽'
                        : t.sport == 'Badminton Academy' ? '🏸' : '♟️',
                    style: const TextStyle(fontSize: 22),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 13, height: 1.3)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(t.sport, style: TextStyle(color: context.colors.inkMuted, fontSize: 11)),
                        const SizedBox(width: 6),
                        Container(width: 3, height: 3, decoration: BoxDecoration(
                          color: context.colors.inkFaint, shape: BoxShape.circle,
                        )),
                        const SizedBox(width: 6),
                        Text(t.teams, style: TextStyle(color: context.colors.inkMuted, fontSize: 11)),
                      ]),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t.status, style: TextStyle(color: t.color, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/admin/dashboard'),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Create Local Tournament'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF84CC16),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tournament {
  final String name, sport, teams, status;
  final Color color;
  const _Tournament(this.name, this.sport, this.teams, this.status, this.color);
}

class _TuitionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final centers = [
      _TuitionCenter('Anu\'s Coaching Center', 'Nanganallur, Chennai', 'NEET / JEE', '🔒 Password Protected'),
      _TuitionCenter('Raj Academy', 'Vadapalani, Chennai', '10th & 12th Board', '🔒 Password Protected'),
      _TuitionCenter('Bright Futures Tuition', 'Tambaram, Chennai', 'All Boards', '🌐 Public'),
      _TuitionCenter('KVT IAS Academy', 'Anna Nagar, Chennai', 'TNPSC / UPSC', '🌐 Public'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: Color(0xFF8B5CF6), size: 16),
              SizedBox(width: 8),
              Text('Password-protected results require a code from your teacher.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...centers.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(c.location, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(c.subjects, style: TextStyle(color: const Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(c.access, style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
            ],
          ),
        )),
      ],
    );
  }
}

class _TuitionCenter {
  final String name, location, subjects, access;
  const _TuitionCenter(this.name, this.location, this.subjects, this.access);
}

class _CorporateTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final events = [
      ['Cognizant Hackathon Q2 2026', 'Internal Challenge', '24 Teams Competed', '🔒 Private'],
      ['TCS Sales Leaderboard — June', 'Monthly Performance', 'Q2 FY26 Rankings', '🔒 Private'],
      ['Infosys Tech Fest 2026', 'Innovation Challenge', '120 Submissions', '🔒 Private'],
      ['Zoho Corp Sports Day', 'Employee Event', 'Chennai Office', '🔒 Private'],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFF97316), size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('Corporate results are private. Access requires an invite or password.',
                style: TextStyle(fontSize: 12, color: Color(0xFFF97316), fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...events.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.business_center_rounded, color: Color(0xFFF97316), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e[0], style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(e[1], style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(e[2], style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                    Text(e[3], style: TextStyle(color: const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700)),
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

class _CommunityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF84CC16).withValues(alpha: 0.2), context.colors.surface],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: const Color(0xFF84CC16).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Text('🏘️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('Your Community Hub', style: TextStyle(
                color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              const SizedBox(height: 8),
              Text(
                'Publish results for local cricket tournaments, school events, drawing competitions, or any community activity — with full privacy control.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.inkMuted, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push('/admin/dashboard'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Event Result'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF84CC16),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('RECENT COMMUNITY RESULTS', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ...['Sivakasi Drawing Contest 2026', 'Perambur Pongal Cricket Tournament', 'MCC Colony Annual Sports Day', 'Church Youth Debate Competition'].map(
          (event) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(child: Text(event, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700))),
                Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
              ],
            ),
          ),
        ),
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
