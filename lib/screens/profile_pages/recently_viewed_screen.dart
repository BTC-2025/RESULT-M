import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/recently_viewed_provider.dart';
import '../dataset_search_screen.dart';

class RecentlyViewedScreen extends ConsumerWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(recentlyViewedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('RECENTLY VIEWED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Clear History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text('Are you sure you want to clear all recently viewed items?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          ref.read(recentlyViewedProvider.notifier).clearHistory();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No history yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Results you search for will appear here.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildTimelineItem(context, item);
              },
            ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, RecentlyViewedItem item) {
    // Generate human-readable time ago
    final diff = DateTime.now().difference(item.viewedAt);
    String timeAgo;
    if (diff.inDays > 1) {
      timeAgo = '${diff.inDays} days ago';
    } else if (diff.inDays == 1) {
      timeAgo = 'Yesterday';
    } else if (diff.inHours > 0) {
      timeAgo = '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      timeAgo = '${diff.inMinutes} mins ago';
    } else {
      timeAgo = 'Just now';
    }

    // Pick color and icon based on domain
    Color color = const Color(0xFF3B82F6);
    IconData icon = Icons.history;
    final d = item.domainType.toUpperCase();
    if (d.contains('EDU') || d.contains('ACADEMIC')) { color = const Color(0xFF10B981); icon = Icons.school; }
    else if (d.contains('SPORT')) { color = const Color(0xFFFF5722); icon = Icons.sports_esports; }
    else if (d.contains('FINANCE')) { color = const Color(0xFF8B5CF6); icon = Icons.trending_up; }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DatasetSearchScreen(
              datasetId: item.datasetId,
              datasetName: item.datasetName,
              domainType: item.domainType,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.datasetName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                  Text('Viewed $timeAgo', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
