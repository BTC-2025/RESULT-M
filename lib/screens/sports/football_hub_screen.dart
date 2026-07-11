import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/sports_api_service.dart';
import '../../core/theme/app_theme.dart';

class FootballHubScreen extends ConsumerStatefulWidget {
  const FootballHubScreen({super.key});

  @override
  ConsumerState<FootballHubScreen> createState() => _FootballHubScreenState();
}

class _FootballHubScreenState extends ConsumerState<FootballHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previousAsync = ref.watch(previousFootballProvider);
    final liveAsync = ref.watch(liveFootballProvider);
    final upcomingAsync = ref.watch(upcomingFootballProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text(
          'Football',
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.blue,
          labelColor: context.colors.blue,
          unselectedLabelColor: context.colors.inkMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'PREVIOUS'),
            Tab(text: 'LIVE'),
            Tab(text: 'UPCOMING'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab(previousAsync),
          _buildTab(liveAsync),
          _buildTab(upcomingAsync),
        ],
      ),
    );
  }

  Widget _buildTab(AsyncValue<List<FootballMatch>> asyncMatches) {
    return asyncMatches.when(
      loading: () => Center(child: CircularProgressIndicator(color: context.colors.blue, strokeWidth: 2)),
      error: (e, st) => _ErrorView(
        error: e.toString(),
        onRetry: () {
          ref.invalidate(previousFootballProvider);
          ref.invalidate(liveFootballProvider);
          ref.invalidate(upcomingFootballProvider);
        },
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return const _EmptyView(message: 'No matches available');
        }

        // Group by league
        final grouped = <String, List<FootballMatch>>{};
        for (final m in matches) {
          final key = '${m.leagueCountry} – ${m.leagueName}';
          if (!grouped.containsKey(key)) grouped[key] = [];
          grouped[key]!.add(m);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final leagueKey = grouped.keys.elementAt(index);
            final leagueMatches = grouped[leagueKey]!;
            final firstMatch = leagueMatches.first;
            return _FootballLeagueGroup(
              leagueKey: leagueKey,
              leagueLogo: firstMatch.leagueLogo,
              matches: leagueMatches,
            );
          },
        );
      },
    );
  }
}

// ─── League Group ─────────────────────────────────────────────────────────────
class _FootballLeagueGroup extends StatelessWidget {
  final String leagueKey;
  final String leagueLogo;
  final List<FootballMatch> matches;

  const _FootballLeagueGroup({
    required this.leagueKey,
    required this.leagueLogo,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League header
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                if (leagueLogo.isNotEmpty)
                  Image.network(
                    leagueLogo,
                    width: 20, height: 20,
                    errorBuilder: (c, e, s) => Icon(Icons.sports_soccer, size: 20, color: context.colors.inkFaint),
                  )
                else
                  Icon(Icons.sports_soccer, size: 20, color: context.colors.inkFaint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leagueKey.toUpperCase(),
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: matches.asMap().entries.map((entry) {
                final i = entry.key;
                final match = entry.value;
                return Column(
                  children: [
                    _FootballMatchCard(match: match),
                    if (i < matches.length - 1)
                      Divider(height: 1, thickness: 1, color: context.colors.border),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Match Card ───────────────────────────────────────────────────────────────
class _FootballMatchCard extends StatelessWidget {
  final FootballMatch match;

  const _FootballMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/results/sports/football/live/${match.id}', extra: match),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (match.isLive) ...[
                  Container(
                    width: 7, height: 7,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: context.colors.liveRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    match.displayStatus,
                    style: TextStyle(
                      color: context.colors.liveRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ] else
                  Text(
                    match.isFinished ? 'FT • ${_formatDate(match.date)}' : _formatTime(match.date),
                    style: TextStyle(
                      color: context.colors.inkFaint,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Teams + score row
            Row(
              children: [
                // Home team
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          match.teamHome,
                          style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TeamLogo(url: match.teamHomeLogo),
                    ],
                  ),
                ),
                // Score / vs
                Container(
                  width: 72,
                  alignment: Alignment.center,
                  child: Text(
                    match.displayScore,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Away team
                Expanded(
                  child: Row(
                    children: [
                      _TeamLogo(url: match.teamAwayLogo),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          match.teamAway,
                          style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${local.day} ${months[local.month - 1]}';
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${local.day} ${months[local.month - 1]} • ${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}';
  }
}

class _TeamLogo extends StatelessWidget {
  final String url;

  const _TeamLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox(width: 32, height: 32);
    return Image.network(
      url,
      width: 32, height: 32,
      errorBuilder: (c, e, s) => Icon(Icons.sports_soccer, size: 28, color: Theme.of(context).extension<AppColorsExtension>()!.inkFaint),
    );
  }
}

// ─── Error and Empty Views ───────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: context.colors.inkFaint),
            const SizedBox(height: 16),
            Text('Failed to load matches', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(error, style: TextStyle(color: context.colors.inkFaint, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, color: context.colors.blue),
              label: Text('Retry', style: TextStyle(color: context.colors.blue, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_soccer_rounded, size: 56, color: context.colors.border),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
