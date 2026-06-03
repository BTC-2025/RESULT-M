import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain_model.dart';
import '../services/api_service.dart';

class SportsFeedScreen extends ConsumerStatefulWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const SportsFeedScreen({super.key, required this.domain, required this.subcategory});

  @override
  ConsumerState<SportsFeedScreen> createState() => _SportsFeedScreenState();
}

class _SportsFeedScreenState extends ConsumerState<SportsFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(widget.subcategory.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
          centerTitle: true,
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFFFF5722),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF5722),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'CRICKET'),
              Tab(text: 'FOOTBALL'),
              Tab(text: 'FORMULA 1'),
              Tab(text: 'ESPORTS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCricketFeed(),
            _buildFootballFeed(),
            _buildF1Feed(),
            _buildEsportsFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildCricketFeed() {
    // We simulate fetching records for the cricket dataset
    // In production, the dataset UUID would be passed through the subcategory model
    String dummyDatasetId = "00000000-0000-0000-0000-000000000000"; 

    return FutureBuilder<List<dynamic>>(
      future: ref.read(apiServiceProvider).fetchDatasetRecords(dummyDatasetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
        }

        List<Widget> feedItems = [];

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          for (var record in snapshot.data!) {
            var data = record['data'];
            if (data != null && data['team1'] != null) {
               feedItems.add(_buildLiveScoreCard(
                 data['team1'] ?? 'TBA',
                 data['team2'] ?? 'TBA',
                 data['score1'] ?? '0',
                 data['score2'] ?? '0',
                 data['status'] ?? 'LIVE',
                 'CRICKET'
               ));
               feedItems.add(const SizedBox(height: 16));
            }
          }
        } else {
          // Fallback static mock
          feedItems.add(_buildLiveScoreCard('IND', 'AUS', '284/6', '210/10', 'India won by 74 runs', 'CRICKET'));
          feedItems.add(const SizedBox(height: 16));
          feedItems.add(_buildLiveScoreCard('ENG', 'SA', '150/2', 'Yet to bat', 'Day 1 - Session 2', 'CRICKET'));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: feedItems,
        );
      }
    );
  }

  Widget _buildFootballFeed() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildFootballMatchCard('Real Madrid', 'Man City', '2', '1', '89\' - Live', true),
        const SizedBox(height: 16),
        _buildFootballMatchCard('Arsenal', 'Bayern Munich', '0', '0', 'Half Time', false),
        const SizedBox(height: 24),
        const Text('EPL LEAGUE TABLE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildLeagueTableRow(1, 'Man City', '82', '76'),
        _buildLeagueTableRow(2, 'Arsenal', '80', '72'),
        _buildLeagueTableRow(3, 'Liverpool', '78', '69'),
      ],
    );
  }

  Widget _buildF1Feed() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('MONACO GP - QUALIFYING', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildF1DriverRow(1, 'Max Verstappen', 'Red Bull Racing', '1:11.365'),
        _buildF1DriverRow(2, 'Charles Leclerc', 'Ferrari', '+0.084'),
        _buildF1DriverRow(3, 'Lando Norris', 'McLaren', '+0.210'),
        _buildF1DriverRow(4, 'Lewis Hamilton', 'Mercedes', '+0.345'),
      ],
    );
  }

  Widget _buildEsportsFeed() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildEsportsMatchCard('Team Liquid', 'Gaimin Gladiators', '2', '1', 'DOTA 2 - TI Finals'),
        const SizedBox(height: 16),
        _buildEsportsMatchCard('Sentinels', 'Fnatic', '0', '0', 'VALORANT - Masters (Live)'),
      ],
    );
  }

  Widget _buildLiveScoreCard(String team1, String team2, String score1, String score2, String status, String sport) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(team1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A))),
              Text(score1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFFFF5722))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(team2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A))),
              Text(score2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFootballMatchCard(String team1, String team2, String score1, String score2, String status, bool isLive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLive ? const Color(0xFFFF5722).withValues(alpha: 0.5) : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (isLive)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFF5722), borderRadius: BorderRadius.circular(4)),
              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text(team1, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)))),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                child: Text('$score1 - $score2', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(team2, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)))),
            ],
          ),
          const SizedBox(height: 12),
          Text(status, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLeagueTableRow(int rank, String team, String pts, String diff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey))),
          Expanded(child: Text(team, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))),
          SizedBox(width: 40, child: Text(diff, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          SizedBox(width: 40, child: Text(pts, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))),
        ],
      ),
    );
  }

  Widget _buildF1DriverRow(int pos, String name, String team, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$pos', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                Text(team, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildEsportsMatchCard(String team1, String team2, String score1, String score2, String tournament) {
    return _buildFootballMatchCard(team1, team2, score1, score2, tournament, false);
  }
}
