import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/sports_api_service.dart';
import '../../core/theme/app_theme.dart';

class CricketHubScreen extends ConsumerStatefulWidget {
  const CricketHubScreen({super.key});

  @override
  ConsumerState<CricketHubScreen> createState() => _CricketHubScreenState();
}

class _CricketHubScreenState extends ConsumerState<CricketHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _genderFilter = 'All'; // 'All', 'Men', 'Women'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use currentMatches for Previous + Live, upcomingMatches for Upcoming
    final currentAsync = ref.watch(currentCricketMatchesProvider);
    final upcomingAsync = ref.watch(upcomingCricketMatchesProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text(
          'Cricket',
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // Gender Filter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: ['All', 'Men', 'Women'].map((label) {
                    final isSelected = _genderFilter == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _genderFilter = label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? context.colors.ink : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? context.colors.ink : context.colors.border,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? context.colors.bg : context.colors.inkMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: context.colors.green,
                labelColor: context.colors.green,
                unselectedLabelColor: context.colors.inkMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                tabs: const [
                  Tab(text: 'PREVIOUS'),
                  Tab(text: 'LIVE'),
                  Tab(text: 'UPCOMING'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PREVIOUS: from currentMatches where matchEnded=true
          _buildTab(currentAsync, (m) => m.matchEnded),
          // LIVE: from currentMatches where matchStarted=true AND matchEnded=false
          _buildTab(currentAsync, (m) => m.matchStarted && !m.matchEnded),
          // UPCOMING: from upcomingMatches where matchStarted=false
          _buildTab(upcomingAsync, (m) => !m.matchStarted && !m.matchEnded),
        ],
      ),
    );
  }

  Widget _buildTab(AsyncValue<List<CricketMatch>> asyncMatches, bool Function(CricketMatch) filterFn) {
    return asyncMatches.when(
      loading: () => Center(child: CircularProgressIndicator(color: context.colors.green, strokeWidth: 2)),
      error: (e, st) => _ErrorView(error: e.toString(), onRetry: () => ref.invalidate(currentCricketMatchesProvider)),
      data: (matches) {
        // Apply gender filter first
        var filtered = matches.where((m) {
          if (_genderFilter == 'Men') return m.isMens;
          if (_genderFilter == 'Women') return m.isWomens;
          return true;
        }).toList();

        // Apply tab filter
        filtered = filtered.where(filterFn).toList();

        if (filtered.isEmpty) {
          return _EmptyView(message: 'No matches available');
        }

        // Group by series name (extracted from match name)
        final grouped = <String, List<CricketMatch>>{};
        for (final m in filtered) {
          // Extract series from name: "Team A vs Team B, X Match, [SERIES]"
          final parts = m.name.split(',');
          final series = parts.length >= 3 ? parts.sublist(2).join(',').trim() : (parts.length >= 2 ? parts[1].trim() : m.matchType.toUpperCase());
          if (!grouped.containsKey(series)) grouped[series] = [];
          grouped[series]!.add(m);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final series = grouped.keys.elementAt(index);
            final matchesInGroup = grouped[series]!;
            return _CricketSeriesGroup(series: series, matches: matchesInGroup);
          },
        );
      },
    );
  }
}

// ─── Series Group ─────────────────────────────────────────────────────────────
class _CricketSeriesGroup extends StatelessWidget {
  final String series;
  final List<CricketMatch> matches;

  const _CricketSeriesGroup({required this.series, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Series header
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.sports_cricket_rounded, size: 16, color: context.colors.inkFaint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    series.toUpperCase(),
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Match cards
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
                    _CricketMatchCard(match: match),
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
class _CricketMatchCard extends StatelessWidget {
  final CricketMatch match;

  const _CricketMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.matchStarted && !match.matchEnded;
    final isUpcoming = !match.matchStarted && !match.matchEnded;

    return InkWell(
      onTap: () => context.push('/results/sports/cricket/live/${match.id}', extra: match),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match type + status row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    match.matchTypeLabel,
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.liveRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: context.colors.liveRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(color: context.colors.liveRed, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  _formatDate(match.date),
                  style: TextStyle(color: context.colors.inkFaint, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Teams row
            Row(
              children: [
                Expanded(child: _TeamRow(match: match, teamIndex: 0)),
                // Score in center
                Container(
                  width: 64,
                  alignment: Alignment.center,
                  child: Text(
                    isUpcoming ? 'vs' : '',
                    style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(child: _TeamRow(match: match, teamIndex: 1, alignRight: true)),
              ],
            ),
            if (match.score.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Scores
              ...match.score.map((s) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${s.inning.split(' ').first}: ${s.display}',
                  style: TextStyle(
                    color: context.colors.inkMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ],
            const SizedBox(height: 10),
            // Status text
            Text(
              match.status,
              style: TextStyle(
                color: match.matchEnded ? context.colors.green : isLive ? context.colors.liveRed : context.colors.inkFaint,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${local.day} ${months[local.month - 1]}, ${local.year}';
  }
}

class _TeamRow extends StatelessWidget {
  final CricketMatch match;
  final int teamIndex;
  final bool alignRight;

  const _TeamRow({required this.match, required this.teamIndex, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    final name = teamIndex == 0 ? match.teamA : match.teamB;
    final short = teamIndex == 0 ? match.teamAShort : match.teamBShort;
    final img = teamIndex == 0 ? match.teamAImg : match.teamBImg;

    final children = [
      if (img != null && img.isNotEmpty)
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            img,
            width: 32, height: 32,
            errorBuilder: (c, e, s) => Icon(Icons.sports_cricket, size: 28, color: context.colors.inkFaint),
          ),
        )
      else
        Icon(Icons.sports_cricket, size: 28, color: context.colors.inkFaint),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          short?.isNotEmpty == true ? short! : name,
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
      ),
    ];

    return Row(
      mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignRight ? children.reversed.toList() : children,
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
              icon: Icon(Icons.refresh, color: context.colors.green),
              label: Text('Retry', style: TextStyle(color: context.colors.green, fontWeight: FontWeight.w700)),
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
          Icon(Icons.sports_cricket_rounded, size: 56, color: context.colors.border),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
