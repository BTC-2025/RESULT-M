import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'school_details_screen.dart';

class SchoolExamScreen extends StatelessWidget {
  final String boardName;

  const SchoolExamScreen({super.key, required this.boardName});

  @override
  Widget build(BuildContext context) {
    final exams = [
      'Class 10th (SSLC/Matriculation)',
      'Class 11th (+1)',
      'Class 12th (HSC/Intermediate)',
      'Revaluation Results',
      'Supplementary Exams',
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text('Select Examination', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Board', style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(boardName, style: TextStyle(color: context.colors.teal, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                Text('Choose Examination', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: exams.length,
              separatorBuilder: (ctx, i) => Divider(height: 1, color: context.colors.border),
              itemBuilder: (ctx, i) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  title: Text(exams[i], style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchoolDetailsScreen(
                          boardName: boardName,
                          examination: exams[i],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
