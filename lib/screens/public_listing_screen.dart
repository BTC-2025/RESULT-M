import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/domain_theme.dart';
import '../core/providers/listing_provider.dart';

class PublicListingScreen extends ConsumerWidget {
  final String datasetId;
  final String datasetName;
  final String domainType;

  const PublicListingScreen({
    super.key,
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingProvider(datasetId));
    final category = DomainThemeFactory.parseCategory(domainType);
    final theme = DomainThemeFactory.getTheme(category);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(datasetName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.records.length,
                  itemBuilder: (context, index) {
                    final record = state.records[index] as Map<String, dynamic>;
                    final data = record['data'] as Map<String, dynamic>? ?? {};
                    return Card(
                      color: context.colors.surfaceAlt,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record['recordTitle'] ?? 'Record #${index + 1}',
                              style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...data.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Text('${e.key}: ', style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.bold)),
                                  Expanded(child: Text('${e.value}', style: TextStyle(color: context.colors.ink))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
