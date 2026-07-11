import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/sports_api_service.dart';
import '../../providers/live_stream_provider.dart';

class CricketScoreScreen extends ConsumerStatefulWidget {
  final CricketMatch match;
  const CricketScoreScreen({super.key, required this.match});

  @override
  ConsumerState<CricketScoreScreen> createState() => _CricketScoreScreenState();
}

class _CricketScoreScreenState extends ConsumerState<CricketScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late CricketMatch _currentMatch;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _currentMatch = widget.match;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleLiveTick(Map<String, dynamic> data) {
    if (data['score'] != null) {
      final scoreParts = data['score'].toString().split('/');
      final runs = int.tryParse(scoreParts[0]) ?? 0;
      final wickets = scoreParts.length > 1 ? (int.tryParse(scoreParts[1]) ?? 0) : 0;
      final overs = double.tryParse(data['overs']?.toString() ?? '0') ?? 0.0;
      
      final updatedScoreList = <CricketScore>[
        CricketScore(
          runs: runs,
          wickets: wickets,
          overs: overs,
          inning: _currentMatch.score.isNotEmpty ? _currentMatch.score[0].inning : '1st Innings',
        )
      ];
      
      setState(() {
        _currentMatch = CricketMatch(
          id: _currentMatch.id,
          name: _currentMatch.name,
          matchType: _currentMatch.matchType,
          status: data['status'] ?? _currentMatch.status,
          venue: _currentMatch.venue,
          date: _currentMatch.date,
          teams: _currentMatch.teams,
          teamInfo: _currentMatch.teamInfo,
          score: updatedScoreList,
          matchStarted: _currentMatch.matchStarted,
          matchEnded: _currentMatch.matchEnded,
          seriesId: _currentMatch.seriesId,
        );
      });
    } else {
      setState(() {
        _currentMatch = CricketMatch(
          id: _currentMatch.id,
          name: _currentMatch.name,
          matchType: _currentMatch.matchType,
          status: data['status'] ?? _currentMatch.status,
          venue: _currentMatch.venue,
          date: _currentMatch.date,
          teams: _currentMatch.teams,
          teamInfo: _currentMatch.teamInfo,
          score: _currentMatch.score,
          matchStarted: _currentMatch.matchStarted,
          matchEnded: _currentMatch.matchEnded,
          seriesId: _currentMatch.seriesId,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = _currentMatch;
    
    // Listen to WebSocket score stream
    ref.listen<AsyncValue<Map<String, dynamic>>>(liveScoreStreamProvider, (prev, next) {
      final data = next.value;
      if (data != null && data['type'] == 'cricket' && data['id'] == match.id) {
        _handleLiveTick(data);
      }
    });
    final isLive = match.matchStarted && !match.matchEnded;
    final matchInfoAsync = ref.watch(cricketMatchInfoProvider(match.id));

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        slivers: [
          // ─── Hero Score Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: context.colors.bg,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: context.colors.ink),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  border: Border(bottom: BorderSide(color: context.colors.border)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Match name + live badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  match.name,
                                  style: TextStyle(color: context.colors.inkMuted, fontSize: 12, fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLive) ...[
                                const SizedBox(width: 8),
                                FadeTransition(
                                  opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: context.colors.liveRed.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: context.colors.liveRed.withValues(alpha: 0.4)),
                                    ),
                                    child: Text('● LIVE', style: TextStyle(color: context.colors.liveRed, fontSize: 10, fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Teams + Scores
                          Row(
                            children: [
                              Expanded(
                                child: _TeamBlock(
                                  name: match.teamA,
                                  shortname: match.teamAShort,
                                  imgUrl: match.teamAImg,
                                  score: match.score1,
                                  align: CrossAxisAlignment.start,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('vs', style: TextStyle(color: context.colors.inkFaint, fontSize: 18, fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                child: _TeamBlock(
                                  name: match.teamB,
                                  shortname: match.teamBShort,
                                  imgUrl: match.teamBImg,
                                  score: match.score2,
                                  align: CrossAxisAlignment.end,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Status bar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: match.matchEnded
                                  ? context.colors.green.withValues(alpha: 0.1)
                                  : context.colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: match.matchEnded
                                    ? context.colors.green.withValues(alpha: 0.3)
                                    : context.colors.amber.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              match.status,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: match.matchEnded ? context.colors.green : context.colors.amber,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Meta row
                          Row(
                            children: [
                              _Pill(match.matchTypeLabel),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  match.venue,
                                  style: TextStyle(color: context.colors.inkMuted, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── All Innings Scores ────────────────────────────────────────────
          if (match.score.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scoreboard', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Column(
                        children: match.score.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.inning,
                                        style: TextStyle(color: context.colors.inkMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${s.runs}/${s.wickets}',
                                          style: TextStyle(color: context.colors.ink, fontSize: 22, fontWeight: FontWeight.w900),
                                        ),
                                        Text(
                                          '(${s.overs.toStringAsFixed(1)} Ov)',
                                          style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (i < match.score.length - 1)
                                Divider(height: 1, thickness: 1, color: context.colors.border),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Match Info from API ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: matchInfoAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, st) => const SizedBox.shrink(),
              data: (info) {
                if (info == null) return const SizedBox.shrink();
                final toss = info['toss']?.toString();
                final umpire = info['umpire']?.toString();
                final referee = info['referee']?.toString();
                final matchWinner = info['matchWinner']?.toString();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Match Details', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          children: [
                            if (matchWinner != null && matchWinner.isNotEmpty)
                              _InfoRow(icon: Icons.emoji_events_rounded, label: 'Winner', value: matchWinner),
                            if (toss != null && toss.isNotEmpty)
                              _InfoRow(icon: Icons.flip_rounded, label: 'Toss', value: toss),
                            _InfoRow(icon: Icons.location_on_outlined, label: 'Venue', value: match.venue),
                            if (umpire != null && umpire.isNotEmpty)
                              _InfoRow(icon: Icons.person_outline_rounded, label: 'Umpires', value: umpire),
                            if (referee != null && referee.isNotEmpty)
                              _InfoRow(icon: Icons.verified_user_outlined, label: 'Referee', value: referee),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _TeamBlock extends StatelessWidget {
  final String name;
  final String? shortname;
  final String? imgUrl;
  final CricketScore? score;
  final CrossAxisAlignment align;

  const _TeamBlock({
    required this.name,
    this.shortname,
    this.imgUrl,
    this.score,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        if (imgUrl != null && imgUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(imgUrl!, width: 36, height: 36,
                errorBuilder: (c, e, s) => const SizedBox(width: 36, height: 36)),
            ),
          ),
        Text(
          shortname?.isNotEmpty == true ? shortname! : name,
          style: TextStyle(color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w900),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (score != null) ...[
          Text(
            '${score!.runs}/${score!.wickets}',
            style: TextStyle(color: context.colors.ink, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(
            '${score!.overs.toStringAsFixed(1)} Ov',
            style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
          ),
        ] else
          Text('–', style: TextStyle(color: context.colors.inkFaint, fontSize: 28, fontWeight: FontWeight.w300)),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Text(text, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.inkFaint),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
