import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Election Result Detail Screen
class ElectionResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const ElectionResultScreen({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final electionTitle = data['title'] ?? 'Election Results';

    final results = [
      _PartySeat('DMK',    '5,340', 178, 0.44, const Color(0xFFEF4444)),
      _PartySeat('AIADMK', '3,210', 82,  0.20, const Color(0xFF10B981)),
      _PartySeat('BJP',    '2,180', 52,  0.13, const Color(0xFF3B82F6)),
      _PartySeat('INC',    '1,920', 38,  0.09, const Color(0xFF8B5CF6)),
      _PartySeat('Others', '1,450', 48,  0.12, const Color(0xFFF59E0B)),
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1D4ED8),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(electionTitle, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
                  child: Row(children: [
                    _InfoChip('543', 'Seats'),
                    const SizedBox(width: 10),
                    _InfoChip('Counting', 'Status'),
                    const SizedBox(width: 10),
                    _InfoChip('272', 'Magic Mark'),
                  ]),
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
                  // Seat donut
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      children: [
                        Text('SEAT TALLY', style: TextStyle(
                          color: context.colors.inkFaint, fontSize: 11,
                          fontWeight: FontWeight.w900, letterSpacing: 1.5,
                        )),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadii.full),
                                child: SizedBox(
                                  height: 16,
                                  child: Row(
                                    children: results.map((r) => Expanded(
                                      flex: (r.fraction * 100).round(),
                                      child: Container(color: r.color),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: results.map((r) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('${r.party} ${r.seats}', style: TextStyle(color: context.colors.ink, fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          )).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text('PARTY WISE RESULTS', style: TextStyle(
                    color: context.colors.inkFaint, fontSize: 11,
                    fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 12),

                  ...results.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.party, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15))),
                          Text('${r.seats} seats', style: TextStyle(color: r.color, fontWeight: FontWeight.w900, fontSize: 15)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              child: LinearProgressIndicator(
                                value: r.fraction,
                                backgroundColor: context.colors.border,
                                color: r.color,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(r.fraction * 100).toStringAsFixed(1)}%', style: TextStyle(color: context.colors.inkMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 4),
                        Text('Vote Share: ${r.voteShare}', style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartySeat {
  final String party, voteShare;
  final int seats;
  final double fraction;
  final Color color;
  const _PartySeat(this.party, this.voteShare, this.seats, this.fraction, this.color);
}

class _InfoChip extends StatelessWidget {
  final String value, label;
  const _InfoChip(this.value, this.label);
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
