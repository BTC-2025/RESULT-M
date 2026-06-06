import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Law Hub — Verdicts, Tenders, Civil Services results
class LawHubScreen extends StatefulWidget {
  const LawHubScreen({super.key});

  @override
  State<LawHubScreen> createState() => _LawHubScreenState();
}

class _LawHubScreenState extends State<LawHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF14B8A6),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 64),
              title: const Text('Law & Judiciary', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6), Color(0xFF2DD4BF)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
                  child: Row(children: [
                    _Chip('High Court', 'Jurisdictions'),
                    const SizedBox(width: 12),
                    _Chip('4,200+', 'Judgments/Year'),
                    const SizedBox(width: 12),
                    _Chip('⚖️', 'Justice'),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Verdicts'),
                Tab(text: 'Gov Bids'),
                Tab(text: 'Civil Services'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _VerdictsTab(),
            _BidsTab(),
            _CivilServicesTab(),
          ],
        ),
      ),
    );
  }
}

class _VerdictsTab extends StatelessWidget {
  final _verdicts = const [
    _Verdict('Suo Motu vs. State of Tamil Nadu',
        'Madras High Court', 'Petition Dismissed', Color(0xFFEF4444),
        'Road repair delay — Held: State liable. ₹5L compensation ordered.', '05 Jun 2026'),
    _Verdict('M/s ABC Construction vs. NHAI',
        'Supreme Court', 'Appeal Allowed', Color(0xFF10B981),
        'Arbitration clause valid. NHAI directed to pay ₹12.3Cr arbitration award.', '04 Jun 2026'),
    _Verdict('State vs. Rajesh Kumar',
        'Sessions Court Chennai', 'Convicted', Color(0xFF6366F1),
        'Found guilty under IPC 420. Sentenced to 3 years rigorous imprisonment.', '03 Jun 2026'),
    _Verdict('Environmental Board vs. XYZ Factory',
        'National Green Tribunal', 'Fined', Color(0xFFF59E0B),
        'NGT imposes ₹50L fine for illegal effluent discharge.', '02 Jun 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _verdicts.map((v) => GestureDetector(
        onTap: () => context.push('/results/law/verdict/${v.title.hashCode}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: v.statusColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.court, style: TextStyle(color: v.statusColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(v.title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14, height: 1.3)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: v.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(v.status, style: TextStyle(color: v.statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.bg,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(v.summary, style: TextStyle(color: context.colors.inkMuted, fontSize: 12, height: 1.4)),
              ),
              const SizedBox(height: 8),
              Text(v.date, style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _Verdict {
  final String title, court, status, summary, date;
  final Color statusColor;
  const _Verdict(this.title, this.court, this.status, this.statusColor, this.summary, this.date);
}

class _BidsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bids = [
      ['Prison Renovation — Chennai Central Jail', 'Ministry of Home Affairs', '₹18.5 Cr', 'Open'],
      ['Court Complex Construction — Madurai', 'High Court of Madras', '₹42 Cr', 'Closed'],
      ['Legal Aid Software — eCourts Project', 'Dept. of Justice', '₹6.2 Cr', 'Open'],
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final bid = bids[i];
        final isOpen = bid[3] == 'Open';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bid[0], style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(bid[1], style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                Text(bid[2], style: TextStyle(color: const Color(0xFF14B8A6), fontWeight: FontWeight.w900, fontSize: 15)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Text(bid[3], style: TextStyle(
                    color: isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 10, fontWeight: FontWeight.w900,
                  )),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _CivilServicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final results = [
      ['TNPSC Group 1 2025', 'Final Selection List Released', '368 Posts', Color(0xFF10B981)],
      ['IAS/IPS 2025 Final Allotment', 'UPSC CSE Final Results', '1,056 Posts', Color(0xFF3B82F6)],
      ['Tamil Nadu Police SI 2025', 'Written Exam Result', '4,212 Posts', Color(0xFFF59E0B)],
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = results[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: (r[3] as Color).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (r[3] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(Icons.badge_rounded, color: r[3] as Color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r[0] as String, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(r[1] as String, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(r[2] as String, style: TextStyle(color: r[3] as Color, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
            ],
          ),
        );
      },
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
