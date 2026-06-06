import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AdminSearchScreen extends StatelessWidget {
  const AdminSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: const Text('Workspace Search')),
      body: const Center(child: Text('Search Coming Soon')),
    );
  }
}
