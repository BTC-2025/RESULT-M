import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Politics Hub — Elections, Polls, Governance, Development Indexes
class PoliticsHubScreen extends StatefulWidget {
  const PoliticsHubScreen({super.key});

  @override
  State<PoliticsHubScreen> createState() => _PoliticsHubScreenState();
}

class _PoliticsHubScreenState extends State<PoliticsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseCtrl.dispose();
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
            backgroundColor: const Color(0xFF3B82F6),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 64),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Politics Hub', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
                  )),
                  const SizedBox(width: 8),
                  FadeTransition(
                    opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE', style: TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1,
                      )),
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
                  child: Row(children: [
                    _Chip('543', 'Constituencies'),
                    const SizedBox(width: 12),
                    _Chip('LIVE', 'Counting'),
                    const SizedBox(width: 12),
                    _Chip('12', 'Parties Leading'),
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
                Tab(text: 'Elections'),
                Tab(text: 'Polls & Surveys'),
                Tab(text: 'Parliament'),
                Tab(text: 'Indexes'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ElectionsTab(pulseCtrl: _pulseCtrl),
            _PollsTab(),
            _ParliamentTab(),
            _IndexesTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Elections Tab ────────────────────────────────────────────────────────
class _ElectionsTab extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _ElectionsTab({required this.pulseCtrl});

  final _elections = const [
    _Election('Tamil Nadu By-Poll 2026', 'State Assembly', '14 Seats', true,
        [_PartyResult('DMK', '8 leading', 0.57), _PartyResult('AIADMK', '4 leading', 0.29), _PartyResult('BJP', '2 leading', 0.14)]),
    _Election('Lok Sabha By-Polls', 'General Election', '5 Seats', true,
        [_PartyResult('INC', '3 leading', 0.60), _PartyResult('BJP', '2 leading', 0.40)]),
    _Election('UP Assembly 2026', 'State Assembly', '403 Seats', false,
        [_PartyResult('BJP', '240 won', 0.60), _PartyResult('SP', '111 won', 0.28), _PartyResult('INC', '52 won', 0.12)]),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _elections.map((e) => _ElectionCard(election: e, pulseCtrl: pulseCtrl)).toList(),
    );
  }
}

class _Election {
  final String title, type, seats;
  final bool isLive;
  final List<_PartyResult> results;
  const _Election(this.title, this.type, this.seats, this.isLive, this.results);
}

class _PartyResult {
  final String party, status;
  final double fraction;
  const _PartyResult(this.party, this.status, this.fraction);
}

class _ElectionCard extends StatelessWidget {
  final _Election election;
  final AnimationController pulseCtrl;
  const _ElectionCard({required this.election, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final partyColors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEF4444)];
    return GestureDetector(
      onTap: () => context.push('/results/politics/election/${election.title.hashCode}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: election.isLive
              ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
              : context.colors.border),
          boxShadow: election.isLive
              ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.08), blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(election.title, style: TextStyle(
                        color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15,
                      )),
                      Text('${election.type} • ${election.seats}', style: TextStyle(
                        color: context.colors.inkMuted, fontSize: 12,
                      )),
                    ],
                  ),
                ),
                if (election.isLive)
                  FadeTransition(
                    opacity: Tween(begin: 0.4, end: 1.0).animate(pulseCtrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(
                            color: Color(0xFFEF4444), shape: BoxShape.circle,
                          )),
                          const SizedBox(width: 4),
                          const Text('LIVE', style: TextStyle(
                            color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w900,
                          )),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: const Text('DECLARED', style: TextStyle(
                      color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900,
                    )),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Party results with progress bars
            ...election.results.asMap().entries.map((entry) {
              final i = entry.key;
              final party = entry.value;
              final color = partyColors[i % partyColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(party.party, style: TextStyle(
                          color: color, fontWeight: FontWeight.w800, fontSize: 13,
                        )),
                        Text(party.status, style: TextStyle(
                          color: context.colors.inkMuted, fontSize: 12,
                        )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      child: LinearProgressIndicator(
                        value: party.fraction,
                        backgroundColor: context.colors.border,
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Polls Tab ────────────────────────────────────────────────────────────
class _PollsTab extends StatelessWidget {
  final _polls = const [
    _Poll('Who will win Tamil Nadu 2027?', 'Political Opinion', ['DMK 47%', 'AIADMK 28%', 'BJP 13%'], [0.47, 0.28, 0.13]),
    _Poll('Approval Rating: PM Modi', 'Governance Survey', ['Approve 63%', 'Disapprove 37%'], [0.63, 0.37]),
    _Poll('Best Economic Policy 2026?', 'Economic Survey', ['Budget Boost 52%', 'GST Reform 31%', 'Others 17%'], [0.52, 0.31, 0.17]),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEF4444)];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _polls.map((poll) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(poll.category, style: const TextStyle(
                color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w800,
              )),
            ),
            const SizedBox(height: 8),
            Text(poll.question, style: TextStyle(
              color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 15, height: 1.3,
            )),
            const SizedBox(height: 14),
            ...poll.options.asMap().entries.map((entry) {
              final color = colors[entry.key % colors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(entry.value, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      child: LinearProgressIndicator(
                        value: poll.fractions[entry.key],
                        backgroundColor: context.colors.border,
                        color: color,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      )).toList(),
    );
  }
}

class _Poll {
  final String question, category;
  final List<String> options;
  final List<double> fractions;
  const _Poll(this.question, this.category, this.options, this.fractions);
}

// ─── Parliament Tab ───────────────────────────────────────────────────────
class _ParliamentTab extends StatelessWidget {
  final _bills = const [
    _Bill('Digital India Act 2026', 'Technology & Communications', 'Passed', Color(0xFF10B981)),
    _Bill('NEET Reform Bill 2026', 'Education', 'Under Review', Color(0xFFF59E0B)),
    _Bill('One Nation One Election', 'Constitutional Amendment', 'Pending', Color(0xFFF97316)),
    _Bill('UCC - Uniform Civil Code', 'Law & Justice', 'Debated', Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _bills.map((bill) => Container(
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
              width: 4, height: 60,
              decoration: BoxDecoration(
                color: bill.statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(bill.category, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bill.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(bill.status, style: TextStyle(
                      color: bill.statusColor, fontSize: 11, fontWeight: FontWeight.w800,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _Bill {
  final String title, category, status;
  final Color statusColor;
  const _Bill(this.title, this.category, this.status, this.statusColor);
}

// ─── Indexes Tab ──────────────────────────────────────────────────────────
class _IndexesTab extends StatelessWidget {
  final _indexes = const [
    _DevelopmentIndex('Human Development Index', 'India Rank: 132/193', '0.644', '+0.012', Color(0xFF3B82F6)),
    _DevelopmentIndex('Press Freedom Index', 'India Rank: 159/180', '41.3', '-2.1', Color(0xFFF59E0B)),
    _DevelopmentIndex('Ease of Doing Business', 'India Rank: 63/190', '71.0', '+4.2', Color(0xFF10B981)),
    _DevelopmentIndex('Corruption Perception Index', 'India Rank: 96/180', '39/100', '+2', Color(0xFF8B5CF6)),
    _DevelopmentIndex('Happiness Index', 'India Rank: 126/137', '4.054', '+0.18', Color(0xFFEC4899)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('GLOBAL DEVELOPMENT INDEXES', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ..._indexes.map((idx) => Container(
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
                  color: idx.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(Icons.public_rounded, color: idx.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(idx.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(idx.rank, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(idx.value, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 17)),
                  Text(idx.change, style: TextStyle(
                    color: idx.change.startsWith('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w700, fontSize: 12,
                  )),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _DevelopmentIndex {
  final String name, rank, value, change;
  final Color color;
  const _DevelopmentIndex(this.name, this.rank, this.value, this.change, this.color);
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
