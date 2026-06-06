import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Government Hub — Tenders, Recruitment, Civil Services, Judiciary
class GovernmentHubScreen extends StatefulWidget {
  const GovernmentHubScreen({super.key});

  @override
  State<GovernmentHubScreen> createState() => _GovernmentHubScreenState();
}

class _GovernmentHubScreenState extends State<GovernmentHubScreen>
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
            backgroundColor: const Color(0xFF6366F1),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
              title: const Text('Government Hub', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF818CF8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(children: [
                    _Chip('50+', 'Departments'),
                    const SizedBox(width: 12),
                    _Chip('2,400+', 'Active Tenders'),
                    const SizedBox(width: 12),
                    _Chip('15K+', 'Jobs Open'),
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
                Tab(text: 'Recruitment'),
                Tab(text: 'Tenders'),
                Tab(text: 'Exam Results'),
                Tab(text: 'Notices'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _RecruitmentTab(),
            _TendersTab(),
            _ExamResultsTab(),
            _NoticesTab(),
          ],
        ),
      ),
    );
  }
}

class _RecruitmentTab extends StatelessWidget {
  final _jobs = const [
    _GovtJob('TNPSC Group 2 2026', 'Tamil Nadu Public Service Commission',
        '5,340 Posts', 'Applications Open', Color(0xFF6366F1), 'Jun 30, 2026'),
    _GovtJob('SSC CHSL 2026', 'Staff Selection Commission',
        '3,712 Posts', 'Result Declared', Color(0xFF10B981), 'N/A'),
    _GovtJob('RRB NTPC 2026', 'Railway Recruitment Board',
        '11,558 Posts', 'Exam Ongoing', Color(0xFFF59E0B), 'Jul 15, 2026'),
    _GovtJob('UPSC CSE 2026', 'Union Public Service Commission',
        '1,056 Posts', 'Prelims Scheduled', Color(0xFF3B82F6), 'Jun 22, 2026'),
    _GovtJob('Banking PO 2026', 'IBPS Bank PO Recruitment',
        '4,455 Posts', 'Applications Open', Color(0xFFEC4899), 'Jul 10, 2026'),
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
              hintText: 'Search government jobs...',
              hintStyle: TextStyle(color: context.colors.inkFaint),
              prefixIcon: Icon(Icons.search_rounded, color: context.colors.inkMuted),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._jobs.map((job) => _GovtJobCard(job: job)),
      ],
    );
  }
}

class _GovtJob {
  final String title, org, posts, status, deadline;
  final Color color;
  const _GovtJob(this.title, this.org, this.posts, this.status, this.color, this.deadline);
}

class _GovtJobCard extends StatelessWidget {
  final _GovtJob job;
  const _GovtJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final statusColor = job.status == 'Applications Open'
        ? const Color(0xFF10B981)
        : job.status == 'Result Declared'
            ? const Color(0xFF3B82F6)
            : const Color(0xFFF59E0B);

    return GestureDetector(
      onTap: () => context.push('/results/government/recruitment/${job.title.hashCode}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: job.color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 4, height: 70,
              decoration: BoxDecoration(color: job.color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(job.org, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(job.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people_outline_rounded, size: 12, color: context.colors.inkFaint),
                    const SizedBox(width: 3),
                    Text(job.posts, style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _TendersTab extends StatelessWidget {
  final _tenders = const [
    'Road Construction — NH-44 Expansion',
    'School Building Renovation — Chennai Corporation',
    'Solar Panel Installation — TANGEDCO',
    'Sewage Treatment Plant — TWAD Board',
    'Medical Equipment Supply — Tamil Nadu Health Dept',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _tenders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_rounded, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tenders[i], style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Ref: TDR-2026-${1000 + i}  •  Open Bid', style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _ExamResultsTab extends StatelessWidget {
  final _results = const [
    _GovtExamResult('TNPSC Group 2 Final List', '5,340 Selected', 'Released', Color(0xFF10B981)),
    _GovtExamResult('SSC CPO 2025 Result', '1,834 Selected', 'Released', Color(0xFF10B981)),
    _GovtExamResult('UPSC CSE 2025 Mains', 'Score Available', 'Released', Color(0xFF3B82F6)),
    _GovtExamResult('RRB ALP Result 2025', '64,371 Selected', 'Released', Color(0xFF10B981)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _results.map((r) => GestureDetector(
        onTap: () => context.push('/results/government/exam/${r.name.hashCode}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                  color: r.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(Icons.assignment_turned_in_rounded, color: r.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(r.posts, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: r.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(r.status, style: TextStyle(color: r.color, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _GovtExamResult {
  final String name, posts, status;
  final Color color;
  const _GovtExamResult(this.name, this.posts, this.status, this.color);
}

class _NoticesTab extends StatelessWidget {
  final _notices = const [
    '📢 TNPSC Group 4 Exam Postponed — New Date: August 2026',
    '📢 SSC CHSL 2026 Notification Released — Apply Now',
    '📢 UGC NET June 2026 Admit Card Available',
    '📢 RBI Grade B 2026 Registration Extended to July 5',
    '📢 IBPS PO 2026 Pre-Exam Training Schedule Released',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _notices.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(_notices[i], style: TextStyle(
          color: context.colors.ink, fontWeight: FontWeight.w600, height: 1.4,
        )),
      ),
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
