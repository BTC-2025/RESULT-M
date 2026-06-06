import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/domain_model.dart';
import '../services/api_service.dart';

final dynamicDomainsProvider = FutureProvider<List<ResultDomain>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final domains = <ResultDomain>[];

  for (final domain in availableDomains) {
    final backendDomainType = backendDomainTypeFor(domain.type);
    if (backendDomainType == null) {
      domains.add(domain);
      continue;
    }

    try {
      final workspaces = await api.fetchWorkspacesByDomain(backendDomainType);
      final dynamicSubcategories = workspaces
          .map((workspace) {
            final workspaceId = workspace['id']?.toString() ?? '';
            final name = workspace['name']?.toString() ?? 'Workspace';
            return Subcategory(
              id: workspaceId,
              name: name,
              status: EventStatus.live,
              subtitle: workspace['description']?.toString(),
              agencyName: 'ResultHub Workspace',
              dateStr: _formatDate(workspace['createdAt']?.toString()),
              workspaceId: workspaceId,
              workspaceSlug: workspace['slug']?.toString(),
            );
          })
          .where((subcategory) => subcategory.workspaceId?.isNotEmpty == true);

      final merged = <String, Subcategory>{
        for (final subcategory in domain.subcategories)
          subcategory.id: subcategory,
        for (final subcategory in dynamicSubcategories)
          subcategory.id: subcategory,
      }.values.toList();

      domains.add(domain.copyWith(subcategories: merged));
    } catch (_) {
      domains.add(domain);
    }
  }

  return domains;
});

String? _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return '${parsed.month}/${parsed.day}/${parsed.year}';
}
