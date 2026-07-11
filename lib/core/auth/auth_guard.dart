import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../storage/secure_storage.dart';

class AuthGuard {
  AuthGuard._();

  static Future<bool> ensureBackendAuth(
    BuildContext context, {
    String message = 'Sign in to continue.',
  }) async {
    final token = await SecureStorage().getToken();
    if (token != null && token.isNotEmpty) {
      return true;
    }

    if (!context.mounted) return false;

    final shouldLogin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign In Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    if (shouldLogin == true && context.mounted) {
      final returnTo = GoRouterState.of(context).uri.toString();
      final success = await context.push<bool>('/login?returnTo=${Uri.encodeComponent(returnTo)}');
      return success == true;
    }

    return false;
  }

  static Future<bool> requireLoginForAction(
    BuildContext context,
    WidgetRef ref, {
    required String actionName,
  }) async {
    final token = await SecureStorage().getToken();
    if (token != null && token.isNotEmpty) {
      return true;
    }

    // Token is missing, ensure auth provider reflects this
    ref.read(authProvider.notifier).logout();

    if (!context.mounted) return false;

    final shouldLogin = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Login to $actionName.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogin == true && context.mounted) {
      final returnTo = GoRouterState.of(context).uri.toString();
      final success = await context.push<bool>('/login?returnTo=${Uri.encodeComponent(returnTo)}');
      return success == true;
    }

    return false;
  }
}
