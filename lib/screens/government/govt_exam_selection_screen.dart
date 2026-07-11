import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';

class GovtExamSelectionScreen extends StatelessWidget {
  final String departmentId;
  final String departmentName;

  const GovtExamSelectionScreen({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context) {
    final DomainTheme theme = DomainThemeFactory.getTheme(WorkspaceCategory.government);

    // Mock data for exams under this department
    final exams = [
      {'id': 'exam-1', 'name': '$departmentName Group 1 Services'},
      {'id': 'exam-2', 'name': '$departmentName Group 2 and 2A Services'},
      {'id': 'exam-4', 'name': '$departmentName Group 4 Services'},
      {'id': 'exam-ae', 'name': '$departmentName Assistant Engineer'},
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(departmentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Results', style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('Select Examination', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return Card(
                  color: context.colors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.push(
                        Uri(
                          path: '/dataset/${exam['id']}/search',
                          queryParameters: {
                            'name': exam['name']!,
                            'domainType': 'GOVERNMENT',
                          },
                        ).toString(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.assignment, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              exam['name']!,
                              style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: context.colors.inkMuted),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
