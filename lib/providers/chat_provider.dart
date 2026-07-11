import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/message_service.dart';

final messageServiceProvider = Provider<MessageService>((ref) => MessageService());

final inboxProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final service = ref.watch(messageServiceProvider);
  return service.getInbox();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(messageServiceProvider);
  return service.getGlobalUnreadCount();
});

final chatHistoryProvider = FutureProvider.family.autoDispose<List<dynamic>, String>((ref, userId) async {
  final service = ref.watch(messageServiceProvider);
  return service.getConversationHistory(userId);
});
