import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/workspace_provider.dart';
import '../../core/theme/app_theme.dart';

class SharedOrganizationsTab extends ConsumerWidget {
  final String domainType;
  final Color themeColor;

  const SharedOrganizationsTab({
    super.key,
    required this.domainType,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(publicWorkspacesProvider(domainType));

    return workspacesAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 70,
          decoration: BoxDecoration(
            color: context.colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      error: (error, _) => _StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Unable to load publishers',
        message: error.toString(),
        color: themeColor,
      ),
      data: (workspaces) {
        if (workspaces.isEmpty) {
          return _StateMessage(
            icon: Icons.business_outlined,
            title: 'No publishers yet',
            message: 'When organizations publish results in this domain, they will appear here.',
            color: themeColor,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: workspaces.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final ws = Map<String, dynamic>.from(workspaces[i] as Map);
            final name = ws['name']?.toString() ?? ws['title']?.toString() ?? 'Organization';
            final slug = ws['slug']?.toString() ?? ws['id']?.toString() ?? '';
            final desc = ws['description']?.toString() ?? '$domainType publisher';

            return InkWell(
              onTap: slug.isEmpty ? null : () => context.push('/workspace/$slug'),
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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: themeColor.withValues(alpha: 0.15),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.inkMuted,
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
