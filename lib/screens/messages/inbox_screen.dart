import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.ink, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: context.colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: inboxAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.ink)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (inbox) {
          if (inbox.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: context.colors.inkMuted),
                  const SizedBox(height: 16),
                  Text('No Messages Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.ink)),
                  const SizedBox(height: 8),
                  Text('Start a conversation from a user profile.', style: TextStyle(color: context.colors.inkMuted)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: inbox.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.border),
            itemBuilder: (context, index) {
              final item = inbox[index];
              final otherUser = item['otherUser'];
              final lastMsg = item['lastMessage'];
              final unreadCount = item['unreadCount'] ?? 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: _buildAvatar(context, otherUser),
                title: Text(
                  otherUser['name'] ?? 'Unknown User',
                  style: TextStyle(
                    fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 15,
                    color: context.colors.ink,
                  ),
                ),
                subtitle: Text(
                  lastMsg['content'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                    color: unreadCount > 0 ? context.colors.ink : context.colors.inkMuted,
                  ),
                ),
                trailing: unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      )
                    : null,
                onTap: () {
                  context.push('/chat/${otherUser['id']}?name=${Uri.encodeComponent(otherUser['name'] ?? '')}');
                  // Optionally refresh the inbox after popping
                  // ref.refresh(inboxProvider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, dynamic user) {
    final base64String = user['profilePictureBase64'];
    final name = user['name'] ?? '?';
    
    if (base64String != null && base64String.isNotEmpty) {
      try {
        final bytes = base64Decode(base64String.split(',').last);
        return CircleAvatar(
          radius: 24,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback
      }
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: context.colors.surfaceAlt,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: context.colors.inkMuted,
        ),
      ),
    );
  }
}
