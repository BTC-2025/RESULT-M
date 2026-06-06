import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Premium Cricbuzz-style Cricket Scorecard
class CricketScoreScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String title;

  const CricketScoreScreen({super.key, required this.data, required this.title});

  @override
  State<CricketScoreScreen> createState() => _CricketScoreScreenState();
}

class _CricketScoreScreenState extends State<CricketScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  int _selectedInnings = 1;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamA = widget.data['team_a'] ?? 'CSK';
    final teamB = widget.data['team_b'] ?? 'MI';
    final match = widget.data['match'] ?? 'IPL 2026 • Match 45';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // ─── Hero Score Bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white70), onPressed: () {}),
              IconButton(icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white70), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Match info + LIVE badge
                        Row(
                          children: [
                            Text(match, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            FadeTransition(
                              opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('● LIVE', style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Scores
                        Row(
                          children: [
                            Expanded(child: _TeamScoreBlock(
                              name: teamA, score: '168/4', overs: '18.2 Ov', isLeading: false,
                            )),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('vs', style: TextStyle(color: Colors.white30, fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                            Expanded(child: _TeamScoreBlock(
                              name: teamB, score: '165/6', overs: '20.0 Ov', isLeading: false, align: CrossAxisAlignment.end,
                            )),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Status bar
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'CSK need 2 runs off 10 balls • RRR: 1.2',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // CRR + RRR
                        Row(
                          children: [
                            _StatPill('CRR', '9.16'),
                            const SizedBox(width: 8),
                            _StatPill('RRR', '1.2'),
                            const SizedBox(width: 8),
                            _StatPill('Last 6', '52 runs'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Tab Selector ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1E293B),
              child: Row(
                children: [1, 2].map((i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedInnings = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: _selectedInnings == i ? const Color(0xFF10B981) : Colors.transparent,
                          width: 3,
                        )),
                      ),
                      child: Text(
                        '$teamA Innings ${i == 1 ? '' : '2'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedInnings == i ? const Color(0xFF10B981) : Colors.white38,
                          fontWeight: FontWeight.w800, fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          // ─── Batting Scorecard ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BATTING', style: TextStyle(
                    color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 8),
                  // Header
                  _ScorecardHeader(cols: const ['Batter', 'R', 'B', '4s', '6s', 'SR']),
                  const SizedBox(height: 4),
                  _BatterRow(name: 'MS Dhoni *', runs: 58, balls: 32, fours: 4, sixes: 4, sr: 181.25, isPlaying: true),
                  _BatterRow(name: 'Ravindra Jadeja', runs: 44, balls: 27, fours: 2, sixes: 3, sr: 162.96, isPlaying: true),
                  _BatterRow(name: 'Ruturaj Gaikwad', runs: 38, balls: 30, fours: 5, sixes: 1, sr: 126.67, isPlaying: false),
                  _BatterRow(name: 'Faf du Plessis', runs: 22, balls: 18, fours: 2, sixes: 0, sr: 122.22, isPlaying: false),

                  const SizedBox(height: 20),
                  const Text('BOWLING', style: TextStyle(
                    color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 8),
                  _ScorecardHeader(cols: const ['Bowler', 'O', 'M', 'R', 'W', 'ECO']),
                  const SizedBox(height: 4),
                  _BowlerRow(name: 'Jasprit Bumrah', overs: 4, maiden: 0, runs: 28, wickets: 2, eco: 7.00),
                  _BowlerRow(name: 'Hardik Pandya *', overs: 1.2, maiden: 0, runs: 22, wickets: 0, eco: 16.50, isCurrent: true),
                  _BowlerRow(name: 'Piyush Chawla', overs: 4, maiden: 0, runs: 35, wickets: 1, eco: 8.75),
                  _BowlerRow(name: 'T Natarajan', overs: 4, maiden: 0, runs: 42, wickets: 0, eco: 10.50),

                  const SizedBox(height: 20),
                  // Ball by ball
                  const Text('RECENT OVERS', style: TextStyle(
                    color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 10),
                  _RecentOvers(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _TeamScoreBlock extends StatelessWidget {
  final String name, score, overs;
  final bool isLeading;
  final CrossAxisAlignment align;

  const _TeamScoreBlock({
    required this.name, required this.score, required this.overs,
    required this.isLeading, this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(name, style: TextStyle(
          color: isLeading ? Colors.white : Colors.white60,
          fontSize: 16, fontWeight: FontWeight.w900,
        )),
        Text(score, style: TextStyle(
          color: isLeading ? const Color(0xFF10B981) : Colors.white,
          fontSize: 28, fontWeight: FontWeight.w900,
        )),
        Text(overs, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  const _StatPill(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text('$label: $value', style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ScorecardHeader extends StatelessWidget {
  final List<String> cols;
  const _ScorecardHeader({required this.cols});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 4, child: Text(cols[0], style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700))),
        ...cols.skip(1).map((c) => SizedBox(
          width: 40,
          child: Text(c, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
        )),
      ],
    );
  }
}

class _BatterRow extends StatelessWidget {
  final String name;
  final int runs, balls, fours, sixes;
  final double sr;
  final bool isPlaying;

  const _BatterRow({required this.name, required this.runs, required this.balls,
      required this.fours, required this.sixes, required this.sr, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 4, child: Row(children: [
            Text(name, style: TextStyle(
              color: isPlaying ? Colors.white : Colors.white70,
              fontWeight: isPlaying ? FontWeight.w900 : FontWeight.w600,
              fontSize: 13,
            )),
            if (isPlaying) ...[
              const SizedBox(width: 4),
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              ),
            ],
          ])),
          SizedBox(width: 40, child: Text('$runs', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
          SizedBox(width: 40, child: Text('$balls', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13))),
          SizedBox(width: 40, child: Text('$fours', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13))),
          SizedBox(width: 40, child: Text('$sixes', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13))),
          SizedBox(width: 40, child: Text(sr.toStringAsFixed(1), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12))),
        ],
      ),
    );
  }
}

class _BowlerRow extends StatelessWidget {
  final String name;
  final double overs;
  final int maiden, runs, wickets;
  final double eco;
  final bool isCurrent;

  const _BowlerRow({required this.name, required this.overs, required this.maiden,
      required this.runs, required this.wickets, required this.eco, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 4, child: Row(children: [
            Text(name, style: TextStyle(
              color: isCurrent ? const Color(0xFFF59E0B) : Colors.white70,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
              fontSize: 13,
            )),
            if (isCurrent) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900)),
            ],
          ])),
          SizedBox(width: 40, child: Text('$overs', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13))),
          SizedBox(width: 40, child: Text('$maiden', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13))),
          SizedBox(width: 40, child: Text('$runs', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13))),
          SizedBox(width: 40, child: Text('$wickets', textAlign: TextAlign.center, style: TextStyle(
            color: wickets > 0 ? const Color(0xFF10B981) : Colors.white60,
            fontWeight: wickets > 0 ? FontWeight.w900 : FontWeight.normal,
            fontSize: 14,
          ))),
          SizedBox(width: 40, child: Text(eco.toStringAsFixed(2), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12))),
        ],
      ),
    );
  }
}

class _RecentOvers extends StatelessWidget {
  final _overs = const [
    ['18.2', ['4', '1', '0', '1', '6', '0']],
    ['18.1', ['W', '0', '1', '4', '2', '1']],
    ['17', ['1', '6', '4', '0', '1', '2']],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: (_overs).map((over) {
        final overNum = over[0] as String;
        final balls = over[1] as List<String>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text(overNum, style: const TextStyle(color: Colors.white38, fontSize: 12))),
              ...balls.map((b) => Container(
                width: 32, height: 32,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: b == 'W'
                      ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                      : b == '6'
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : b == '4'
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(color: b == 'W'
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : b == '6'
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : b == '4'
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                              : Colors.transparent),
                ),
                child: Center(child: Text(b, style: TextStyle(
                  color: b == 'W'
                      ? const Color(0xFFEF4444)
                      : b == '6'
                          ? const Color(0xFF10B981)
                          : b == '4'
                              ? const Color(0xFF3B82F6)
                              : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ))),
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
