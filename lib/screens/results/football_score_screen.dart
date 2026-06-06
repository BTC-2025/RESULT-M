import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// FanCode-style Football Match Detail Screen
class FootballScoreScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String title;

  const FootballScoreScreen({super.key, required this.data, required this.title});

  @override
  State<FootballScoreScreen> createState() => _FootballScoreScreenState();
}

class _FootballScoreScreenState extends State<FootballScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  int _selectedTab = 0;

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
    final teamA = widget.data['team_a'] ?? 'Mumbai City FC';
    final teamB = widget.data['team_b'] ?? 'Kerala Blasters FC';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          // ─── Hero Match Card ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E1A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white70), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF0A0E1A)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 56),
                      // League + time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('⚽ ISL 2026 • Semi Final', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          FadeTransition(
                            opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('● LIVE • 76\'', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Main score display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _FootballTeam(name: teamA, score: '2', isHome: true),
                          Column(
                            children: [
                              const Text('VS', style: TextStyle(color: Colors.white24, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('HT: 1 - 0', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          _FootballTeam(name: teamB, score: '1', isHome: false),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Goal scorers
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bipin Singh 23\', 67\'', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          SizedBox(width: 32),
                          Text('Apostolos Giannou 54\'', style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Possession bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text('64%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              const Text('Possession', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              const Text('36%', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                            ]),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              child: LinearProgressIndicator(
                                value: 0.64,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                color: const Color(0xFF3B82F6),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: const Color(0xFF0A0E1A),
                child: Row(
                  children: ['Timeline', 'Stats', 'Lineups'].asMap().entries.map((e) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                            color: _selectedTab == e.key ? const Color(0xFF22C55E) : Colors.transparent,
                            width: 3,
                          )),
                        ),
                        child: Text(e.value, textAlign: TextAlign.center, style: TextStyle(
                          color: _selectedTab == e.key ? const Color(0xFF22C55E) : Colors.white38,
                          fontWeight: FontWeight.w800, fontSize: 13,
                        )),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),

          // ─── Tab Content ─────────────────────────────────────────────────
          if (_selectedTab == 0) SliverToBoxAdapter(child: _TimelineTab()),
          if (_selectedTab == 1) SliverToBoxAdapter(child: _StatsTab()),
          if (_selectedTab == 2) SliverToBoxAdapter(child: _LineupsTab()),
        ],
      ),
    );
  }
}

class _FootballTeam extends StatelessWidget {
  final String name, score;
  final bool isHome;
  const _FootballTeam({required this.name, required this.score, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: (isHome ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B)).withValues(alpha: 0.15),
          child: Text(name.split(' ').map((w) => w[0]).take(2).join(), style: TextStyle(
            color: isHome ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
            fontWeight: FontWeight.w900, fontSize: 18,
          )),
        ),
        const SizedBox(height: 8),
        Text(name.split(' ').first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 4),
        Text(score, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final _events = const [
    _MatchEvent(76, 'Hardik Singh — Yellow Card', '⚠️', false),
    _MatchEvent(67, 'Bipin Singh — GOAL!', '⚽', true),
    _MatchEvent(64, 'Substitution: Cassio → Mohamad', '🔄', false),
    _MatchEvent(54, 'Apostolos Giannou — GOAL!', '⚽', false),
    _MatchEvent(45, 'Half Time', '⏱️', false),
    _MatchEvent(23, 'Bipin Singh — GOAL!', '⚽', true),
    _MatchEvent(1, 'Kick Off', '🎯', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _events.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text("${e.minute}'", style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w700, fontSize: 12))),
              Text(e.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(child: Text(e.description, style: TextStyle(
                color: e.isHomeEvent ? const Color(0xFF3B82F6) : Colors.white70,
                fontWeight: FontWeight.w700, fontSize: 13,
              ))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _MatchEvent {
  final int minute;
  final String description, emoji;
  final bool isHomeEvent;
  const _MatchEvent(this.minute, this.description, this.emoji, this.isHomeEvent);
}

class _StatsTab extends StatelessWidget {
  final _stats = const [
    ['Shots on Target', '7', '4'],
    ['Total Shots', '14', '10'],
    ['Corners', '6', '3'],
    ['Fouls', '12', '15'],
    ['Yellow Cards', '2', '1'],
    ['Offsides', '3', '1'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _stats.map((s) {
          final homeVal = double.tryParse(s[1]) ?? 0;
          final awayVal = double.tryParse(s[2]) ?? 0;
          final total = homeVal + awayVal;
          final homeFrac = total > 0 ? homeVal / total : 0.5;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s[1], style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(s[0], style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
                  Text(s[2], style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 16)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                      child: LinearProgressIndicator(
                        value: homeFrac,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFF3B82F6),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                      child: LinearProgressIndicator(
                        value: 1 - homeFrac,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFFF59E0B),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LineupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MUMBAI CITY FC — 4-3-3', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...['1. Phurba Lachenpa (GK)', '5. Mehtab Singh (CB)', '4. Rahul Bheke (CB)', '11. Bipin Singh (LW)', '9. Greg Stewart (ST)']
              .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              )),
          const SizedBox(height: 20),
          const Text('KERALA BLASTERS FC — 4-4-2', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...['1. Albino Gomes (GK)', '5. Marko Leskovic (CB)', '19. Harmanjot Khabra (RB)', '10. Sahal Abdul Samad (CAM)', '7. Apostolos Giannou (ST)']
              .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              )),
        ],
      ),
    );
  }
}
