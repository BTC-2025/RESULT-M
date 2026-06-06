import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Entertainment Result Detail — Awards, Box Office, Charts
class EntertainmentResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const EntertainmentResultScreen({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final category = data['category'] ?? 'Awards';
    final winner   = data['winner']   ?? 'Kalki 2898 AD';
    final event    = data['event']    ?? '73rd National Film Awards 2026';

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFBE185D),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF831843), Color(0xFFBE185D), Color(0xFFEC4899)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(category, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
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
                  // Winner card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Column(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        const Text('WINNER', style: TextStyle(
                          color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2,
                        )),
                        const SizedBox(height: 8),
                        Text(winner, style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22,
                        ), textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        const Text('National Film Awards 2026', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text('ALL WINNERS', style: TextStyle(
                    color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 12),

                  ...[
                    ['🥇 Best Film', 'Kalki 2898 AD'],
                    ['🎬 Best Director', 'S.S. Rajamouli'],
                    ['🎭 Best Actor', 'Prabhas'],
                    ['🎭 Best Actress', 'Deepika Padukone'],
                    ['🎵 Best Music', 'A.R. Rahman'],
                    ['🏅 Best Tamil Film', 'Amaran'],
                    ['🎨 Best VFX', 'Kalki 2898 AD'],
                  ].map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Text(item[0], style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item[1], style: TextStyle(
                          color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14,
                        ))),
                        Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
                      ],
                    ),
                  )),
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
