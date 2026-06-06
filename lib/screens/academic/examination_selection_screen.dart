import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'academic_details_screen.dart';

class ExaminationSelectionScreen extends StatelessWidget {
  final String universityName;

  const ExaminationSelectionScreen({super.key, required this.universityName});

  final List<String> _exams = const [
    'UG Results',
    'PG Results',
    'Revaluation Results',
    'Arrear Results',
    'PhD Results',
    'Internal Assessment',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text(universityName, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold, fontSize: 16)),
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Choose Examination',
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _exams.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.border),
              itemBuilder: (context, index) {
                final exam = _exams[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.description_outlined, color: context.colors.orange),
                  ),
                  title: Text(exam, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 16)),
                  trailing: Icon(Icons.arrow_forward_ios, color: context.colors.inkMuted, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AcademicDetailsScreen(
                          universityName: universityName,
                          examType: exam,
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
