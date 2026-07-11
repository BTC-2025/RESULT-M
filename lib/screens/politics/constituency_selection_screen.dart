import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';

class ConstituencySelectionScreen extends StatelessWidget {
  final String electionId;
  final String electionName;

  const ConstituencySelectionScreen({
    super.key,
    required this.electionId,
    required this.electionName,
  });

  @override
  Widget build(BuildContext context) {
    final DomainTheme theme = DomainThemeFactory.getTheme(WorkspaceCategory.politics);

    final constituencies = [
      {'id': 'const-1', 'name': 'Chennai South'},
      {'id': 'const-2', 'name': 'Coimbatore'},
      {'id': 'const-3', 'name': 'Madurai'},
      {'id': 'const-4', 'name': 'Salem'},
      {'id': 'const-all', 'name': 'Overall State Results (Live)'},
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(electionName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                Text('Vote Counting Status', style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('Select Constituency', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: constituencies.length,
              itemBuilder: (context, index) {
                final consti = constituencies[index];
                final isLive = consti['id'] == 'const-all';
                return Card(
                  color: context.colors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.push(
                        Uri(
                          path: '/dataset/public/${consti['id']}',
                          queryParameters: {
                            'name': consti['name']!,
                            'domainType': 'POLITICS',
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
                              color: isLive ? Colors.red.withValues(alpha: 0.1) : theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(isLive ? Icons.live_tv : Icons.location_on, color: isLive ? Colors.red : theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              consti['name']!,
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
