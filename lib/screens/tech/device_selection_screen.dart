import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';

class DeviceSelectionScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const DeviceSelectionScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final DomainTheme theme = DomainThemeFactory.getTheme(WorkspaceCategory.technology);

    final queries = [
      {'id': 'tech-all', 'name': 'Overall Leaderboard'},
      {'id': 'tech-single', 'name': 'Single-Core Performance'},
      {'id': 'tech-multi', 'name': 'Multi-Core Performance'},
      {'id': 'tech-efficiency', 'name': 'Power Efficiency'},
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                Text('Performance Charts', style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('Select Metric', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: queries.length,
              itemBuilder: (context, index) {
                final query = queries[index];
                return Card(
                  color: context.colors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.push(
                        Uri(
                          path: '/dataset/public/${query['id']}',
                          queryParameters: {
                            'name': '$categoryName - ${query['name']}',
                            'domainType': 'TECH',
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
                            child: Icon(Icons.bar_chart, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              query['name']!,
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
