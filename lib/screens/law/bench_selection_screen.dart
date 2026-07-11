import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';

class BenchSelectionScreen extends StatelessWidget {
  final String courtId;
  final String courtName;

  const BenchSelectionScreen({
    super.key,
    required this.courtId,
    required this.courtName,
  });

  @override
  Widget build(BuildContext context) {
    final DomainTheme theme = DomainThemeFactory.getTheme(WorkspaceCategory.law);

    final benches = [
      {'id': 'bench-civil', 'name': 'Civil Jurisdiction'},
      {'id': 'bench-criminal', 'name': 'Criminal Jurisdiction'},
      {'id': 'bench-corporate', 'name': 'Corporate & Commercial'},
      {'id': 'bench-family', 'name': 'Family Court'},
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(courtName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif')),
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
                Text('Case Status & Verdicts', style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('Select Bench', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'serif')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: benches.length,
              itemBuilder: (context, index) {
                final bench = benches[index];
                return Card(
                  color: context.colors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.push(
                        Uri(
                          path: '/dataset/${bench['id']}/search',
                          queryParameters: {
                            'name': '$courtName - ${bench['name']}',
                            'domainType': 'LAW',
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
                            child: Icon(Icons.gavel_rounded, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              bench['name']!,
                              style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'),
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
