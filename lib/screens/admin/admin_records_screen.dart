import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AdminRecordsScreen extends StatelessWidget {
  const AdminRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: const Text('Manage Records')),
      body: const Center(child: Text('Records Coming Soon')),
    );
  }
}
