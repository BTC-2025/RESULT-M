import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/field_renderer.dart';

/// Election / Politics Result Screen — fully dynamic.
class ElectionResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const ElectionResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFF1D4ED8);

  String get _electionTitle =>
      data['election_name'] ?? data['electionName'] ?? data['title'] ??
      data['constituency'] ?? title;

  String get _constituency =>
      data['constituency'] ?? data['district'] ?? data['state'] ?? '';

  String get _status =>
      data['status'] ?? data['election_status'] ?? data['electionStatus'] ?? 'DECLARED';

  String get _winner =>
      data['winner'] ?? data['leading_candidate'] ?? data['leadingCandidate'] ??
      data['elected_candidate'] ?? data['electedCandidate'] ?? '';

  String get _winnerParty =>
      data['winner_party'] ?? data['winnerParty'] ?? data['party'] ??
      data['leading_party'] ?? data['leadingParty'] ?? '';

  String get _margin =>
      data['margin'] ?? data['lead_margin'] ?? data['leadMargin'] ??
      data['winning_margin'] ?? '';

  String get _totalVotes =>
      data['total_votes'] ?? data['totalVotes'] ?? data['votes_polled'] ??
      data['totalVoters'] ?? '';

  String get _turnout =>
      data['turnout'] ?? data['voter_turnout'] ?? data['voterTurnout'] ?? '';

  List<Map<String, dynamic>> get _candidateResults {
    final raw = data['results'] ?? data['candidates'] ?? data['party_results'] ?? data['partywiseResults'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> get _extraData {
    const skip = {
      'election_name', 'electionName', 'title', 'constituency', 'district', 'state',
      'status', 'election_status', 'electionStatus',
      'winner', 'leading_candidate', 'leadingCandidate', 'elected_candidate', 'electedCandidate',
      'winner_party', 'winnerParty', 'party', 'leading_party', 'leadingParty',
      'margin', 'lead_margin', 'leadMargin', 'winning_margin',
      'total_votes', 'totalVotes', 'votes_polled', 'totalVoters',
      'turnout', 'voter_turnout', 'voterTurnout',
      'results', 'candidates', 'party_results', 'partywiseResults',
    };
    return Map.fromEntries(data.entries.where((e) => !skip.contains(e.key) && e.value != null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _themeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_electionTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D3A7A), _themeColor],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
                  child: Wrap(
                    spacing: 10, runSpacing: 8,
                    children: [
                      if (_constituency.isNotEmpty) _InfoChip(_constituency, 'Constituency'),
                      if (_totalVotes.isNotEmpty) _InfoChip(_totalVotes, 'Total Votes'),
                      if (_turnout.isNotEmpty) _InfoChip('$_turnout%', 'Turnout'),
                      _InfoChip(_status.toUpperCase(), 'Status'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Winner Card
                  if (_winner.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_themeColor.withValues(alpha: 0.9), _themeColor],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('WINNER', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(_winner, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                if (_winnerParty.isNotEmpty)
                                  Text(_winnerParty, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                if (_margin.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('Margin: $_margin votes', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Candidate-wise results if available
                  if (_candidateResults.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ElectionChartWidget(candidates: _candidateResults),
                    const SizedBox(height: 20),
                    Text('Candidate-wise Results', style: TextStyle(color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    ..._candidateResults.map((cand) => _CandidateRow(data: cand, context: context)),
                  ],

                  // Extra fields
                  if (_extraData.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Additional Details', style: TextStyle(color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    FullRecordPanel(data: _extraData, accentColor: _themeColor),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String value, label;
  const _InfoChip(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w600, fontSize: 10)),
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final BuildContext context;
  const _CandidateRow({required this.data, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final name = data['name'] ?? data['candidateName'] ?? data['candidate'] ?? 'Unknown';
    final party = data['party'] ?? data['partyName'] ?? '';
    final votes = data['votes'] ?? data['vote_count'] ?? data['voteCount'] ?? 0;
    final won = data['won'] ?? data['status']?.toString().toUpperCase().contains('WON') ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: won == true ? const Color(0xFF1D4ED8).withValues(alpha: 0.08) : ctx.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: won == true ? const Color(0xFF1D4ED8).withValues(alpha: 0.3) : ctx.colors.border,
        ),
      ),
      child: Row(
        children: [
          if (won == true)
            const Icon(Icons.emoji_events_rounded, color: Color(0xFF1D4ED8), size: 18),
          if (won == true) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toString(), style: TextStyle(color: ctx.colors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                if (party.isNotEmpty)
                  Text(party.toString(), style: TextStyle(color: ctx.colors.inkMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(votes.toString(), style: TextStyle(
            color: ctx.colors.ink, fontSize: 16, fontWeight: FontWeight.w900,
          )),
        ],
      ),
    );
  }
}

class ElectionChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> candidates;
  const ElectionChartWidget({super.key, required this.candidates});

  @override
  State<ElectionChartWidget> createState() => _ElectionChartWidgetState();
}

class _ElectionChartWidgetState extends State<ElectionChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    int totalVotes = 0;
    for (final c in widget.candidates) {
      final v = _parseVotes(c['votes'] ?? c['vote_count'] ?? c['voteCount']);
      totalVotes += v;
    }

    if (totalVotes == 0) return const SizedBox.shrink();

    final List<PieChartSectionData> sections = [];
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEF4444), // Red
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange/Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];

    for (int i = 0; i < widget.candidates.length; i++) {
      final c = widget.candidates[i];
      final v = _parseVotes(c['votes'] ?? c['vote_count'] ?? c['voteCount']);
      final pct = totalVotes > 0 ? (v / totalVotes) * 100 : 0.0;
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 45.0 : 35.0;
      final color = colors[i % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: v.toDouble(),
          title: '${pct.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: isTouched ? 14 : 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          showTitle: pct > 5,
        ),
      );
    }

    String centerTitle = 'Total Votes';
    String centerSubtitle = _formatVotes(totalVotes);
    if (_touchedIndex >= 0 && _touchedIndex < widget.candidates.length) {
      final cand = widget.candidates[_touchedIndex];
      final name = cand['name'] ?? cand['candidateName'] ?? cand['candidate'] ?? 'Unknown';
      final v = _parseVotes(cand['votes'] ?? cand['vote_count'] ?? cand['voteCount']);
      final pct = totalVotes > 0 ? (v / totalVotes) * 100 : 0.0;
      centerTitle = name.toString();
      centerSubtitle = '${_formatVotes(v)}\n(${pct.toStringAsFixed(1)}%)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Text(
            'VOTE SHARE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: context.colors.inkMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections: sections,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          centerTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.colors.inkMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        centerSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: context.colors.ink,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(widget.candidates.length, (i) {
              final cand = widget.candidates[i];
              final name = cand['name'] ?? cand['candidateName'] ?? cand['candidate'] ?? 'Unknown';
              final color = colors[i % colors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.colors.inkMuted,
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  int _parseVotes(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    final clean = v.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  String _formatVotes(int v) {
    if (v >= 10000000) {
      return '${(v / 10000000).toStringAsFixed(2)} Cr';
    }
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(2)} L';
    }
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)} K';
    }
    return v.toString();
  }
}
