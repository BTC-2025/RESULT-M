import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../results/generic_score_screen.dart';

class MatchSelectionScreen extends StatelessWidget {
  final String leagueId;
  final String leagueName;

  const MatchSelectionScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    // Mock generic matches since we don't have APIs for every sport yet
    final matches = [
      {'id': 'match-1', 'name': 'Match A vs Match B', 'status': 'Live', 'score': '2 - 1'},
      {'id': 'match-2', 'name': 'Match C vs Match D', 'status': 'Upcoming', 'score': '-'},
      {'id': 'match-3', 'name': 'Match E vs Match F', 'status': 'Completed', 'score': '0 - 3'},
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text(leagueName, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.colors.border, height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: matches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final match = matches[index];
          final isLive = match['status'] == 'Live';
          
          return Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLive ? context.colors.ink : context.colors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenericScoreScreen(
                      matchId: match['id']!,
                      matchName: match['name']!,
                      leagueName: leagueName,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  color: isLive ? context.colors.ink : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (isLive) const SizedBox(width: 8),
                              Text(
                                match['status']!,
                                style: TextStyle(
                                  color: isLive ? context.colors.ink : context.colors.inkMuted, 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            match['name']!,
                            style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      match['score']!,
                      style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
