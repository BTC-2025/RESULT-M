import 'package:flutter/material.dart';

class NBAScoreScreen extends StatelessWidget {
  final dynamic game;
  const NBAScoreScreen({super.key, this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NBA')),
      body: const Center(child: Text('NBA is not available in this version.')),
    );
  }
}
