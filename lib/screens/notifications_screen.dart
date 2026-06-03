import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'UPSC CSE 2026 Final Results',
      'body': 'The final marksheet for Civil Services has just been released. Tap to view your score.',
      'icon': Icons.account_balance,
      'color': const Color(0xFF10B981),
      'time': '2m ago',
      'isUnread': true,
      'dateHeader': 'TODAY',
    },
    {
      'title': 'Anna University Updates',
      'body': 'Semester 4 B.E evaluation is now complete. Expect results by tomorrow evening.',
      'icon': Icons.school,
      'color': const Color(0xFF3B82F6),
      'time': '1h ago',
      'isUnread': true,
      'dateHeader': 'TODAY',
    },
    {
      'title': 'CBSE Class 12',
      'body': 'The servers are currently experiencing heavy load. Please try checking your result again in 15 minutes.',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFFF5722),
      'time': '14:30 PM',
      'isUnread': false,
      'dateHeader': 'YESTERDAY',
    },
    {
      'title': 'SSC CGL Tier 1',
      'body': 'Your saved exam SSC CGL has published its scorecard.',
      'icon': Icons.bookmark,
      'color': const Color(0xFF0F172A),
      'time': '09:15 AM',
      'isUnread': false,
      'dateHeader': 'YESTERDAY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('NOTIFICATIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isUnread'] = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All marked as read')));
            },
            child: const Text('Mark all read', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _notifications.isEmpty 
        ? const Center(child: Text('No new notifications', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final n = _notifications[index];
              final isFirstOfDate = index == 0 || _notifications[index - 1]['dateHeader'] != n['dateHeader'];
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstOfDate) ...[
                    if (index > 0) const SizedBox(height: 16),
                    _buildDateHeader(n['dateHeader']),
                    const SizedBox(height: 16),
                  ],
                  Dismissible(
                    key: Key(n['title'] + n['time']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _notifications.removeAt(index);
                      });
                    },
                    child: _buildNotificationItem(n['title'], n['body'], n['icon'], n['color'], n['time'], n['isUnread']),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildDateHeader(String title) {
    return Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5));
  }

  Widget _buildNotificationItem(String title, String body, IconData icon, Color color, String time, bool isUnread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnread ? color.withValues(alpha: 0.3) : Colors.grey.shade200, width: isUnread ? 2 : 1),
        boxShadow: isUnread ? [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: const Color(0xFF0F172A)))),
                    Text(time, style: TextStyle(color: isUnread ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(body, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
