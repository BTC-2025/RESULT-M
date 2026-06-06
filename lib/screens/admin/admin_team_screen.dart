import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AdminTeamScreen extends StatelessWidget {
  const AdminTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: const Text('Manage Team')),
      body: const Center(child: Text('Team Management Coming Soon')),
    );
  }
}
