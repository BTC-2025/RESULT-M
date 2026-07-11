import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

/// Provider for fetching public workspaces by domain type
final publicWorkspacesProvider = FutureProvider.family<List<dynamic>, String?>((ref, domainType) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchPublicWorkspaces(domainType: domainType);
});

/// Provider for global platform metrics analytics
final globalAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchGlobalAnalytics();
});
