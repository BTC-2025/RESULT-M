import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/sports_api_service.dart';
import 'shared_organizations_tab.dart';

class SportsHubScreen extends StatefulWidget {
  const SportsHubScreen({super.key});

  @override
  State<SportsHubScreen> createState() => _SportsHubScreenState();
}

class _SportsHubScreenState extends State<SportsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _sports = [
    _Sport('Cricket', '🏏', 'IPL, Test, T20I, ODI', Color(0xFF10B981), Icons.sports_cricket_rounded, '/results/sports/cricket'),
    _Sport('Football', '⚽', 'ISL, EPL, La Liga, Champions League', Color(0xFF22C55E), Icons.sports_soccer_rounded, '/results/sports/football'),
    _Sport('Kabaddi', '🤼', 'Pro Kabaddi League', Color(0xFF16A34A), Icons.sports_mma_rounded, '/results/sports/kabaddi'),
    _Sport('Badminton', '🏸', 'BWF World Tour, Premier Badminton', Color(0xFF15803D), Icons.sports_tennis_rounded, '/results/sports/badminton'),
    _Sport('Athletics', '🏃', 'Olympics, Asian Games, National', Color(0xFF166534), Icons.directions_run_rounded, '/results/sports/athletics'),
    _Sport('Formula 1', '🏎️', 'FIA Formula One World Championship', Color(0xFF14532D), Icons.speed_rounded, '/results/sports/f1'),
    _Sport('Tennis', '🎾', 'ATP, WTA, Grand Slams', Color(0xFF4ADE80), Icons.sports_tennis_rounded, '/results/sports/tennis'),
    _Sport('Basketball', '🏀', 'NBA, NBL India', Color(0xFF86EFAC), Icons.sports_basketball_rounded, '/results/sports/basketball'),
    _Sport('Esports', '🎮', 'BGMI, Valorant, Free Fire', Color(0xFF34D399), Icons.videogame_asset_rounded, '/results/sports/esports'),
    _Sport('Local Sports', '📍', 'Gully cricket, turf football, academies', Color(0xFF6EE7B7), Icons.location_city_rounded, '/results/sports/local'),
  ];

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
            expandedHeight: 210,
            pinned: true,
            backgroundColor: context.colors.ink,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Sports Hub', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
            )),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: context.colors.ink,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 112, 20, 58),
                  child: Row(
                    children: [
                      const Expanded(child: _Chip('10+', 'Sports')),
                      const SizedBox(width: 10),
                      const Expanded(child: _Chip('LIVE', 'Matches Today')),
                      const SizedBox(width: 10),
                      const Expanded(child: _Chip('50M+', 'Fans')),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: context.colors.orange,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Live'),
                Tab(text: 'Leagues'),
                Tab(text: 'My Sports'),
                Tab(text: 'Organizations'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _LiveMatchesTab(),
            _LeaguesTab(sports: _sports),
            _MySportsTab(),
            const SharedOrganizationsTab(domainType: 'SPORT', themeColor: Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }
}

// ─── Live Matches Tab ─────────────────────────────────────────────────────
class _LiveMatchesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LiveMatchesTab> createState() => _LiveMatchesTabState();
}

class _LiveMatchesTabState extends ConsumerState<_LiveMatchesTab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final liveMatchesAsync = ref.watch(liveFootballProvider);
    final liveCricketAsync = ref.watch(currentCricketMatchesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FadeTransition(
                opacity: _pulse,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 6),
              Text('LIVE MATCHES', style: TextStyle(
                color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14,
              )),
            ],
          ),
          const SizedBox(height: 12),
          
          // --- FOOTBALL ---
          const Text('⚽ Football', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          liveMatchesAsync.when(
            loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))),
            error: (e, st) => Center(child: Text('Failed to load football: $e', style: TextStyle(color: context.colors.inkFaint))),
            data: (matches) {
              if (matches.isEmpty) {
                return Center(child: Text('No live matches right now.', style: TextStyle(color: context.colors.inkMuted)));
              }
              return Column(
                children: matches.map((match) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FootballLiveCard(
                    teamA: match.teamHome,
                    teamB: match.teamAway,
                    scoreA: match.scoreHome?.toString() ?? '0',
                    scoreB: match.scoreAway?.toString() ?? '0',
                    status: match.displayStatus,
                    onTap: () => context.push('/results/sports/football/live/${match.id}', extra: match),
                  ),
                )).toList(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // --- CRICKET ---
          const Text('🏏 Cricket', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          liveCricketAsync.when(
            loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))),
            error: (e, st) => Center(child: Text('Failed to load cricket: $e', style: TextStyle(color: context.colors.inkFaint))),
            data: (matches) {
              final live = matches.where((m) => m.matchStarted && !m.matchEnded).toList();
              if (live.isEmpty) {
                return Center(child: Text('No live cricket right now.', style: TextStyle(color: context.colors.inkMuted)));
              }
              return Column(
                children: live.map((match) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FootballLiveCard(
                    teamA: match.teamA,
                    teamB: match.teamB,
                    scoreA: match.score1 != null ? '${match.score1!.runs}/${match.score1!.wickets}' : '–',
                    scoreB: match.score2 != null ? '${match.score2!.runs}/${match.score2!.wickets}' : '–',
                    status: match.matchTypeLabel,
                    onTap: () => context.push('/results/sports/cricket/live/${match.id}', extra: match),
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FootballLiveCard extends StatelessWidget {
  final String teamA, teamB, scoreA, scoreB, status;
  final VoidCallback onTap;
  const _FootballLiveCard({required this.teamA, required this.teamB, required this.scoreA, required this.scoreB, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('⚽', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 6),
                    const _LiveDot(),
                  ]),
                  const SizedBox(height: 8),
                  Text(teamA, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(teamB, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
            ),
            Column(
              children: [
                Text(scoreA, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 28)),
                Text(scoreB, style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w700, fontSize: 24)),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text('LIVE', style: TextStyle(
        color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8,
      )),
    );
  }
}

// ─── Leagues Tab ──────────────────────────────────────────────────────────
class _LeaguesTab extends StatelessWidget {
  final List<_Sport> sports;
  const _LeaguesTab({required this.sports});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
      ),
      itemCount: sports.length,
      itemBuilder: (context, i) {
        final s = sports[i];
        return GestureDetector(
          onTap: () => context.push(s.route),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [s.color.withValues(alpha: 0.2), context.colors.surface],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: s.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Text(s.name, style: TextStyle(
                  color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15,
                )),
                Text(s.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
                  color: context.colors.inkMuted, fontSize: 11,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── My Sports Tab ────────────────────────────────────────────────────────
class _MySportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_outline_rounded, size: 64, color: context.colors.inkFaint),
          const SizedBox(height: 16),
          Text('Follow Sports', style: TextStyle(
            color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900,
          )),
          const SizedBox(height: 8),
          Text('Follow your favourite leagues to\nsee them first here', textAlign: TextAlign.center, style: TextStyle(
            color: context.colors.inkMuted, fontSize: 14,
          )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Browse Sports'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sport {
  final String name, emoji, subtitle, route;
  final Color color;
  final IconData icon;
  const _Sport(this.name, this.emoji, this.subtitle, this.color, this.icon, this.route);
}

class _Chip extends StatelessWidget {
  final String value, label;
  const _Chip(this.value, this.label);

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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
