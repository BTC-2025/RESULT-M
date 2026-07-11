import 'package:flutter/material.dart';

class NBAHubScreen extends StatelessWidget {
  const NBAHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NBA Basketball')),
      body: const Center(child: Text('NBA is not available in this version.')),
    );
  }
}
