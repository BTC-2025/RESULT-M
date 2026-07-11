import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/auth_provider.dart';

class HomeSliverAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeSliverAppBar({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: context.colors.bg,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.purple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'R',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'ResultHub',
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () => context.go('/explore'),
          icon: Icon(Icons.search_rounded, color: context.colors.ink),
        ),
        Consumer(
          builder: (context, ref, _) {
            final unread = ref.watch(notificationProvider).valueOrNull?.where((item) => !item.isRead).length ?? 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () => context.push('/notifications'),
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: context.colors.ink,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 12,
                    right: 10,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: context.colors.liveRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.bg, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authProvider);
              final isLoggedIn = authState.isLoggedIn;
              
              if (!isLoggedIn) {
                return TextButton(
                  onPressed: () => context.push('/login'),
                  style: TextButton.styleFrom(
                    backgroundColor: context.colors.orange.withValues(alpha: 0.1),
                    foregroundColor: context.colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              final name = authState.name ?? '';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
              
              ImageProvider? imageProvider;
              if (authState.profilePictureBase64 != null && authState.profilePictureBase64!.startsWith('data:image')) {
                try {
                  final base64Str = authState.profilePictureBase64!.split(',').last;
                  imageProvider = MemoryImage(base64Decode(base64Str));
                } catch (e) {
                  // Fallback
                }
              }

              return GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: imageProvider == null ? LinearGradient(
                      colors: [context.colors.orange, context.colors.orangeGlow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                    image: imageProvider != null ? DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ) : null,
                  ),
                  alignment: Alignment.center,
                  child: imageProvider == null ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
