import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/app_notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        foregroundColor: context.colors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationProvider.notifier).markAllRead(),
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: context.colors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.purple)),
        error: (err, stack) => Center(child: Text('Error loading notifications', style: TextStyle(color: context.colors.liveRed))),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _NotificationEmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () {
                  ref
                      .read(notificationProvider.notifier)
                      .markAsRead(notification.id);
                  _openNotification(context, notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openNotification(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case NotificationType.resultPublished:
        if (notification.linkedId.startsWith('fallback-')) {
          context.go('/?expand=${notification.linkedId}');
        } else {
          context.push('/workspace/${notification.linkedId}');
        }
        break;
      case NotificationType.complaint:
        context.go('/?expand=${notification.linkedId}');
        break;
      case NotificationType.pollResult:
      case NotificationType.comment:
        context.go('/?expand=${notification.linkedId}');
        break;
      case NotificationType.follower:
        context.push('/profile/public/${notification.linkedId}');
        break;
      case NotificationType.message:
        context.push('/chat/${notification.linkedId}');
        break;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context, notification.type);
    final unread = !notification.isRead;

    return Material(
      color: unread
          ? context.colors.purple.withValues(alpha: 0.05)
          : context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(_typeIcon(notification.type), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            color: context.colors.ink,
                            fontSize: 14,
                            height: 1.25,
                          ),
                          children: [
                            TextSpan(
                              text: notification.title,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: ' ${notification.body}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(notification.createdAt),
                        style: TextStyle(
                          color: context.colors.inkMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedOpacity(
                  opacity: unread ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.resultPublished:
        return Icons.bar_chart_rounded;
      case NotificationType.complaint:
        return Icons.campaign_rounded;
      case NotificationType.pollResult:
        return Icons.poll_rounded;
      case NotificationType.comment:
        return Icons.chat_bubble_rounded;
      case NotificationType.follower:
        return Icons.person_add_alt_1_rounded;
      case NotificationType.message:
        return Icons.mail_outline_rounded;
    }
  }

  Color _typeColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.resultPublished:
        return context.colors.purple;
      case NotificationType.complaint:
        return context.colors.liveRed;
      case NotificationType.pollResult:
        return context.colors.teal;
      case NotificationType.comment:
        return context.colors.pink;
      case NotificationType.follower:
        return context.colors.blue;
      case NotificationType.message:
        return context.colors.orange;
    }
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: context.colors.inkMuted,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "We'll notify you when something happens",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.inkMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
