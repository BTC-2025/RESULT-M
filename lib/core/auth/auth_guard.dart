import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      context.push('/login');
    }

    return false;
  }
}
