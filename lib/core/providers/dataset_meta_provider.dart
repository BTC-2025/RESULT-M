import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dataset_meta.dart';
import '../../services/api_service.dart';

final datasetMetaProvider = FutureProvider.family<DatasetMeta, String>((ref, datasetId) async {
  final api = ref.watch(apiServiceProvider);
  final raw = await api.fetchDatasetMeta(datasetId);
  return DatasetMeta.fromJson(raw);
});
