import 'package:flutter/material.dart';
import '../../core/theme/domain_theme.dart';

class HeroSectionFactory {
  static Widget build(HeroWidgetType type, Map<String, dynamic> record) {
    switch (type) {
      case HeroWidgetType.gradeCircle:
        return GradeCircleHero(
          grade: record['grade']?.toString() ?? 'N/A',
          total: record['total']?.toString() ?? '0',
          status: record['status']?.toString() ?? record['result']?.toString() ?? 'PASS',
        );
      case HeroWidgetType.meritRankBadge:
        return MeritRankBadgeHero(
          rank: record['merit_rank']?.toString() ?? record['rank']?.toString() ?? 'N/A',
          status: record['status']?.toString() ?? 'SELECTED',
        );
      case HeroWidgetType.caseDisposition:
        return CaseDispositionHero(
          verdict: record['verdict']?.toString() ?? 'PENDING',
          caseTitle: record['case_title']?.toString() ?? 'State vs Unknown',
        );
      case HeroWidgetType.qualifyingScore:
        return QualifyingScoreHero(
          score: record['score']?.toString() ?? record['total']?.toString() ?? '0',
          qualified: record['status']?.toString() ?? 'QUALIFIED',
        );
      case HeroWidgetType.awardPodium:
        return AwardPodiumHero(
          winner: record['winner']?.toString() ?? record['title']?.toString() ?? 'Winner',
          category: record['category']?.toString() ?? 'Best Category',
        );
      case HeroWidgetType.leaderboardRank:
        return LeaderboardRankHero(
          rank: record['rank']?.toString() ?? '1',
          score: record['score']?.toString() ?? '100',
        );
      default:
        return GenericDataHero(record: record);
    }
  }
}

// ─── Dummy Implementations for the Specific Heroes ───────────

class GradeCircleHero extends StatelessWidget {
  final String grade;
  final String total;
  final String status;

  const GradeCircleHero({super.key, required this.grade, required this.total, required this.status});

  @override
  Widget build(BuildContext context) {
    final isPass = status.toUpperCase() == 'PASS';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A5C), // Academic Theme
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 4),
            ),
            child: Center(
              child: Text(grade, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Total: $total', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isPass ? Colors.green.shade400 : Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class MeritRankBadgeHero extends StatelessWidget {
  final String rank;
  final String status;
  const MeritRankBadgeHero({super.key, required this.rank, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A2F), // Government Theme
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                const Text('MERIT RANK', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('#$rank', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CaseDispositionHero extends StatelessWidget {
  final String verdict;
  final String caseTitle;
  const CaseDispositionHero({super.key, required this.verdict, required this.caseTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C), // Law Theme
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
            child: Text(verdict.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          Text(caseTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class QualifyingScoreHero extends StatelessWidget {
  final String score;
  final String qualified;
  const QualifyingScoreHero({super.key, required this.score, required this.qualified});

  @override
  Widget build(BuildContext context) => const SizedBox(); // Implemented similarly
}

class AwardPodiumHero extends StatelessWidget {
  final String winner;
  final String category;
  const AwardPodiumHero({super.key, required this.winner, required this.category});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class LeaderboardRankHero extends StatelessWidget {
  final String rank;
  final String score;
  const LeaderboardRankHero({super.key, required this.rank, required this.score});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class GenericDataHero extends StatelessWidget {
  final Map<String, dynamic> record;
  const GenericDataHero({super.key, required this.record});

  @override
  Widget build(BuildContext context) => const SizedBox();
}
