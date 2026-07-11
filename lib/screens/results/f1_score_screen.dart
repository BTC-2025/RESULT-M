import 'package:flutter/material.dart';

class F1ScoreScreen extends StatelessWidget {
  final dynamic race;
  const F1ScoreScreen({super.key, this.race});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formula 1')),
      body: const Center(child: Text('F1 is not available in this version.')),
    );
  }
}
