import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/guest/local_workspace_screen.dart';
import '../screens/guest/password_unlock_screen.dart';
import '../screens/workspace_resolver_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/w/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final code = state.uri.queryParameters['code'];
        return WorkspaceResolverScreen(slug: slug, initialCode: code);
      },
    ),
    GoRoute(
      path: '/workspace/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Workspace';
        return LocalWorkspaceScreen(workspaceId: id, workspaceName: name);
      },
    ),
  ],
);
