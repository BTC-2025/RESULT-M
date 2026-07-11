import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

String _normalizeDomainType(String domainType) {
  var normalized = domainType.toUpperCase();
  return switch (normalized) {
    'SPORT' => 'SPORTS',
    'ACADEMIC' => 'EDUCATION',
    'ELECTION' => 'POLITICS',
    'GOVERNMENT' || 'LAW' || 'TECH' || 'HYPERLOCAL' => 'CUSTOM',
    _ => normalized,
  };
}

final rootCategoriesProvider = FutureProvider.family<List<dynamic>, String>((ref, domainType) async {
  final apiClient = ref.watch(apiClientProvider);
  final normalizedDomain = _normalizeDomainType(domainType);
  final response = await apiClient.client.get('/categories/domain/$normalizedDomain');

  if (response.statusCode == 200) {
    return response.data as List<dynamic>;
  } else {
    throw Exception('Failed to load root categories for $domainType');
  }
});

final subCategoriesProvider = FutureProvider.family<List<dynamic>, String>((ref, parentId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.client.get('/categories/$parentId/subcategories');

  if (response.statusCode == 200) {
    return response.data as List<dynamic>;
  } else {
    throw Exception('Failed to load subcategories for $parentId');
  }
});
