import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/domain_datasets_provider.dart';
import '../../core/theme/app_theme.dart';
import '../dataset_search_screen.dart';

class DomainDatasetsTab extends ConsumerWidget {
  final String domainType;
  final Color themeColor;
  final String emptyTitle;

  const DomainDatasetsTab({
    super.key,
    required this.domainType,
    required this.themeColor,
    this.emptyTitle = 'No published results yet',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetsAsync = ref.watch(domainDatasetsProvider(domainType));

    return datasetsAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 88,
          decoration: BoxDecoration(
            color: context.colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      error: (error, _) => _StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Unable to load results',
        message: error.toString(),
        color: themeColor,
      ),
      data: (items) {
        if (items.isEmpty) {
          return _StateMessage(
            icon: Icons.dataset_outlined,
            title: emptyTitle,
            message: 'Publish datasets from Admin to show live results here.',
            color: themeColor,
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(domainDatasetsProvider(domainType).future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: item.datasetId.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DatasetSearchScreen(
                              datasetId: item.datasetId,
                              datasetName: item.datasetName,
                              domainType: item.domainType,
                            ),
                          ),
                        ),
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Icon(Icons.dataset_rounded, color: themeColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.datasetName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.workspaceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.inkMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.inkFaint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 96),
        Icon(icon, color: color, size: 46),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
        ),
      ],
    );
  }
}
