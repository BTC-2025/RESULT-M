import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/sports_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/live_stream_provider.dart';

/// Premium Dynamic Football Match Detail Screen
class FootballScoreScreen extends ConsumerStatefulWidget {
  final FootballMatch? match;

  const FootballScoreScreen({super.key, required this.match});

  @override
  ConsumerState<FootballScoreScreen> createState() => _FootballScoreScreenState();
}

class _FootballScoreScreenState extends ConsumerState<FootballScoreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  FootballMatch? _currentMatch;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _currentMatch = widget.match;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleLiveTick(Map<String, dynamic> data) {
    if (_currentMatch == null) return;
    
    int? scoreHome = _currentMatch!.scoreHome;
    int? scoreAway = _currentMatch!.scoreAway;
    String displayScoreStr = _currentMatch!.displayScoreStr;
    
    if (data['score'] != null) {
      final parts = data['score'].toString().split(' - ');
      if (parts.length == 2) {
        scoreHome = int.tryParse(parts[0]);
        scoreAway = int.tryParse(parts[1]);
        displayScoreStr = data['score'].toString();
      }
    }
    
    setState(() {
      _currentMatch = FootballMatch(
        id: _currentMatch!.id,
        title: _currentMatch!.title,
        teamHome: _currentMatch!.teamHome,
        teamAway: _currentMatch!.teamAway,
        teamHomeLogo: _currentMatch!.teamHomeLogo,
        teamAwayLogo: _currentMatch!.teamAwayLogo,
        scoreHome: scoreHome,
        scoreAway: scoreAway,
        statusShort: 'inprogress',
        statusLong: data['status'] ?? _currentMatch!.statusLong,
        displayScoreStr: displayScoreStr,
        leagueName: _currentMatch!.leagueName,
        leagueLogo: _currentMatch!.leagueLogo,
        leagueCountry: _currentMatch!.leagueCountry,
        round: _currentMatch!.round,
        date: _currentMatch!.date,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final match = _currentMatch;
    
    // Listen to WebSocket score stream
    ref.listen<AsyncValue<Map<String, dynamic>>>(liveScoreStreamProvider, (prev, next) {
      final data = next.value;
      if (data != null && data['type'] == 'football' && data['id'] == match?.id) {
        _handleLiveTick(data);
      }
    });
    if (match == null) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(child: Text('Match not found', style: TextStyle(color: context.colors.ink))),
      );
    }
    
    final teamA = match.teamHome;
    final teamB = match.teamAway;
    final logoA = match.teamHomeLogo;
    final logoB = match.teamAwayLogo;
    final scoreA = match.scoreHome?.toString() ?? '-';
    final scoreB = match.scoreAway?.toString() ?? '-';
    final isLive = match.isLive;
    final isFinished = match.isFinished;

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: context.colors.bg,
            elevation: 0,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (match.leagueLogo.isNotEmpty)
                              Image.network(match.leagueLogo, width: 20, height: 20, errorBuilder: (c,e,s) => const SizedBox()),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.colors.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: context.colors.border),
                              ),
                              child: Text('${match.leagueCountry} - ${match.leagueName}', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 10),
                            if (isLive)
                              FadeTransition(
                                opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.colors.liveRed.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: context.colors.liveRed.withValues(alpha: 0.3)),
                                  ),
                                  child: Text('● LIVE • ${match.statusLong}', style: TextStyle(color: context.colors.liveRed, fontSize: 11, fontWeight: FontWeight.w900)),
                                ),
                              )
                            else if (isFinished)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: context.colors.border),
                                ),
                                child: Text('FULL TIME', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w900)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: context.colors.blue.withValues(alpha: 0.2)),
                                ),
                                child: Text('UPCOMING • ${match.displayStatus}', style: TextStyle(color: context.colors.blue, fontSize: 11, fontWeight: FontWeight.w900)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _FootballTeam(name: teamA, score: scoreA, logo: logoA, isHome: true, showScore: isLive || isFinished),
                            Column(
                              children: [
                                if (isLive || isFinished)
                                  Text('$scoreA - $scoreB', style: TextStyle(color: context.colors.ink, fontSize: 36, fontWeight: FontWeight.w900))
                                else
                                  Text('VS', style: TextStyle(color: context.colors.inkFaint, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: context.colors.surface, border: Border.all(color: context.colors.border), borderRadius: BorderRadius.circular(20)),
                                  child: Text(match.statusLong, style: TextStyle(color: context.colors.inkMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                ),
                              ],
                            ),
                            _FootballTeam(name: teamB, score: scoreB, logo: logoB, isHome: false, showScore: isLive || isFinished),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MATCH DETAILS', style: TextStyle(color: context.colors.inkMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(icon: Icons.stadium_rounded, label: 'League', value: match.leagueName),
                        Divider(color: context.colors.border, height: 1),
                        _DetailRow(icon: Icons.calendar_today_rounded, label: 'Date', value: '${match.date.day}/${match.date.month}/${match.date.year}'),
                        Divider(color: context.colors.border, height: 1),
                        _DetailRow(icon: Icons.flag_rounded, label: 'Country', value: match.leagueCountry),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Stream section removed
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: context.colors.inkFaint, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: TextStyle(color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _FootballTeam extends StatelessWidget {
  final String name;
  final String score;
  final String logo;
  final bool isHome;
  final bool showScore;

  const _FootballTeam({
    required this.name,
    required this.score,
    required this.logo,
    required this.isHome,
    required this.showScore,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: logo.isNotEmpty 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(logo, fit: BoxFit.contain, errorBuilder: (c,e,s) => Icon(Icons.shield, color: context.colors.ink))
                )
              : Icon(Icons.shield, color: context.colors.ink, size: 30),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w800, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
