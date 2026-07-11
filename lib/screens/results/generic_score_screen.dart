import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GenericScoreScreen extends StatelessWidget {
  final String matchId;
  final String matchName;
  final String leagueName;

  const GenericScoreScreen({
    super.key,
    required this.matchId,
    required this.matchName,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text(
          leagueName,
          style: TextStyle(color: context.colors.inkMuted, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LIVE MATCH',
                style: TextStyle(color: context.colors.ink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              matchName.split(' vs ').first,
              style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              '2 - 1',
              style: TextStyle(color: context.colors.ink, fontSize: 56, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 16),
            Text(
              matchName.split(' vs ').last,
              style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 64),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Match Events',
                style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _EventRow('12\'', 'Goal', matchName.split(' vs ').first),
                  Divider(color: context.colors.border, height: 32),
                  _EventRow('45\'', 'Yellow Card', matchName.split(' vs ').last),
                  Divider(color: context.colors.border, height: 32),
                  _EventRow('89\'', 'Goal', matchName.split(' vs ').first),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final String time;
  final String event;
  final String playerOrTeam;

  const _EventRow(this.time, this.event, this.playerOrTeam);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            time,
            style: TextStyle(color: context.colors.inkMuted, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            event,
            style: TextStyle(color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          playerOrTeam,
          style: TextStyle(color: context.colors.ink, fontSize: 14),
        ),
      ],
    );
  }
}
