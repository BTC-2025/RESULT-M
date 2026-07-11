import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';

class DomainDatasetItem {
  final Map<String, dynamic> workspace;
  final Map<String, dynamic> dataset;

  const DomainDatasetItem({required this.workspace, required this.dataset});

  String get workspaceName =>
      workspace['name']?.toString() ??
      workspace['title']?.toString() ??
      'Publisher';

  String get datasetId => dataset['id']?.toString() ?? '';

  String get datasetName =>
      dataset['name']?.toString() ??
      dataset['datasetName']?.toString() ??
      'Untitled result';

  String get description =>
      dataset['description']?.toString() ??
      workspace['description']?.toString() ??
      'Published result dataset';

  String get domainType => dataset['domainType']?.toString() ?? 'CUSTOM';

  String get status => dataset['status']?.toString() ?? 'PUBLISHED';
}

final domainDatasetsProvider =
    FutureProvider.family<List<DomainDatasetItem>, String>((ref, domainType) async {
  final api = ref.watch(apiServiceProvider);
  final workspaces = await api.fetchPublicWorkspaces(domainType: domainType);

  final results = await Future.wait(workspaces.whereType<Map>().map((rawWorkspace) async {
    final workspace = Map<String, dynamic>.from(rawWorkspace);
    final workspaceId = workspace['id']?.toString();
    if (workspaceId == null || workspaceId.isEmpty) {
      return const <DomainDatasetItem>[];
    }

    final datasets = await api.fetchPublishedDatasets(workspaceId);
    return datasets.whereType<Map>().map((rawDataset) {
      final dataset = Map<String, dynamic>.from(rawDataset);
      return DomainDatasetItem(workspace: workspace, dataset: dataset);
    }).where((item) {
      return item.status.toUpperCase() == 'PUBLISHED' &&
          item.domainType.toUpperCase() == domainType.toUpperCase();
    }).toList();
  }));

  final items = results.expand((items) => items).toList()
    ..sort((a, b) {
      final left = b.dataset['updatedAt']?.toString() ?? '';
      final right = a.dataset['updatedAt']?.toString() ?? '';
      return left.compareTo(right);
    });
  return items;
});
