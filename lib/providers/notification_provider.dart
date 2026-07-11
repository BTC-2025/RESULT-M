import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_notification_model.dart';
import '../services/notification_api_service.dart';

final notificationServiceProvider = Provider((ref) => NotificationApiService());

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return _fetchNotifications();
  }

  Future<List<AppNotification>> _fetchNotifications() async {
    final service = ref.read(notificationServiceProvider);
    return service.getNotifications();
  }

  int get unreadCount => state.valueOrNull?.where((item) => !item.isRead).length ?? 0;

  Future<void> markAsRead(String id) async {
    final service = ref.read(notificationServiceProvider);
    await service.markAsRead(id);
    
    // Optimistic update
    if (state.value != null) {
      state = AsyncValue.data([
        for (final item in state.value!)
          item.id == id ? item.copyWith(isRead: true) : item,
      ]);
    }
  }

  Future<void> markAllRead() async {
    final service = ref.read(notificationServiceProvider);
    await service.markAllAsRead();
    
    if (state.value != null) {
      state = AsyncValue.data([
        for (final item in state.value!) item.copyWith(isRead: true)
      ]);
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
      NotificationNotifier.new,
    );
