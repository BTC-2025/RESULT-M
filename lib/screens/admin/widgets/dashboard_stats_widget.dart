import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DashboardStatsWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const DashboardStatsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cross axis count depends on screen width
        int crossAxisCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: [
            _buildStatCard(context, 'Total Results', data['total_results'] ?? '0', Icons.description, Colors.blue),
            _buildStatCard(context, 'Total Students/Records', data['total_records'] ?? '0', Icons.people, Colors.orange),
            _buildStatCard(context, 'Searches Today', data['searches_today'] ?? '0', Icons.search, Colors.green),
            _buildStatCard(context, 'Downloads', data['downloads'] ?? '0', Icons.download, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: context.colors.inkMuted, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
