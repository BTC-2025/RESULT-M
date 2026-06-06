import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import 'result_detail_screen.dart';
import 'results/academic_result_screen.dart';
import 'results/cricket_score_screen.dart';
import 'results/election_result_screen.dart';
import 'results/entertainment_result_screen.dart';
import 'results/finance_result_screen.dart';
import 'results/football_score_screen.dart';
import 'results/law_result_screen.dart';

class PublicDatasetScreen extends StatefulWidget {
  final String datasetId;
  final String datasetName;
  final String domainType;

  const PublicDatasetScreen({
    super.key,
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
  });

  @override
  State<PublicDatasetScreen> createState() => _PublicDatasetScreenState();
}

class _PublicDatasetScreenState extends State<PublicDatasetScreen> {
  @override
  void initState() {
    super.initState();
    _fetchPublicData();
  }

  Future<void> _fetchPublicData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    Map<String, dynamic> mockData = {};
    IconData icon = Icons.data_usage;

    if (widget.domainType.toUpperCase().contains('SPORT')) {
      if (widget.datasetName.toLowerCase().contains('cricket')) {
        mockData = {
          'match': 'IND vs AUS - Finals',
          'toss': 'IND won and chose to bat',
          'score': '245/4',
          'overs': '42.3',
          'currentRunRate': '5.76',
          'projectedScore': '310',
          'batsman1': 'Kohli 82* (70)',
          'batsman2': 'Rahul 45 (40)',
          'bowler': 'Cummins 2/45 (8)',
          'recent': '1 0 W 4 2 1',
        };
        icon = Icons.sports_cricket;
      } else {
        // Football
        mockData = {
          'match': 'RMA vs FCB - El Clasico',
          'time': '74:12',
          'score': '2 - 1',
          'possession': '45% - 55%',
          'shotsOnTarget': '6 - 4',
          'scorers': 'Vinicius 12\', Bellingham 65\' | Lewandowski 42\'',
          'cards': '2 Yellow | 1 Yellow',
        };
        icon = Icons.sports_soccer;
      }
    } else if (widget.domainType.toUpperCase().contains('ELECTION')) {
      mockData = {
        'constituency': 'Central District',
        'totalVotesCounted': '1,245,000',
        'leadingCandidate': 'John Doe (Dem) - 52%',
        'trailingCandidate': 'Jane Smith (Rep) - 45%',
        'others': '3%',
      };
      icon = Icons.how_to_vote;
    }

    // Replace the current loading screen with the Detail Screen
    if (!mounted) return;
    
    Widget destinationScreen;
    final domain = widget.domainType.toUpperCase();
    
    if (domain.contains('ACADEMIC') || domain.contains('EDUCATION') || domain.contains('SCHOOL')) {
      destinationScreen = AcademicResultScreen(data: mockData, title: widget.datasetName);
    } else if (domain.contains('POLITICS') || domain.contains('ELECTION')) {
      destinationScreen = ElectionResultScreen(data: mockData, title: widget.datasetName);
    } else if (domain.contains('FINANCE') || domain.contains('MARKET') || domain.contains('ECONOM')) {
      destinationScreen = FinanceResultScreen(data: mockData, title: widget.datasetName);
    } else if (domain.contains('ENTERTAIN') || domain.contains('MEDIA') || domain.contains('MOVIE')) {
      destinationScreen = EntertainmentResultScreen(data: mockData, title: widget.datasetName);
    } else if (domain.contains('LAW') || domain.contains('GOV') || domain.contains('COURT')) {
      destinationScreen = LawResultScreen(data: mockData, title: widget.datasetName);
    } else if (domain.contains('SPORT') || domain.contains('GAME')) {
      if (widget.datasetName.toUpperCase().contains('CRICKET')) {
        destinationScreen = CricketScoreScreen(data: mockData, title: widget.datasetName);
      } else if (widget.datasetName.toUpperCase().contains('FOOTBALL') || widget.datasetName.toUpperCase().contains('SOCCER')) {
        destinationScreen = FootballScoreScreen(data: mockData, title: widget.datasetName);
      } else {
        destinationScreen = ResultDetailScreen(
          domainName: widget.domainType,
          icon: icon,
          recordData: mockData,
          datasetName: widget.datasetName,
        );
      }
    } else {
      // Fallback
      destinationScreen = ResultDetailScreen(
        domainName: widget.domainType,
        icon: icon,
        recordData: mockData,
        datasetName: widget.datasetName,
      );
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destinationScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.orange),
            const SizedBox(height: 16),
            Text(
              'Connecting to live data stream...',
              style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
