import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/category_api_service.dart';

class DomainExplorerScreen extends ConsumerStatefulWidget {
  final String domainType;
  final String? parentId;
  final String? title;

  const DomainExplorerScreen({
    super.key,
    required this.domainType,
    this.parentId,
    this.title,
  });

  @override
  ConsumerState<DomainExplorerScreen> createState() => _DomainExplorerScreenState();
}

class _DomainExplorerScreenState extends ConsumerState<DomainExplorerScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = widget.parentId == null
        ? ref.watch(rootCategoriesProvider(widget.domainType))
        : ref.watch(subCategoriesProvider(widget.parentId!));

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.title ?? '${widget.domainType} Hub',
          style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.ink),
          onPressed: () => context.pop(),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: context.colors.liveRed, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load folders.', style: TextStyle(color: context.colors.ink)),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded, size: 64, color: context.colors.inkMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No categories found.', style: TextStyle(color: context.colors.inkMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // In future: Route to dataset search form if leaf node
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Leaf node reached. Dataset Search Form will render here.')),
                      );
                    },
                    child: const Text('View Datasets'),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                color: context.colors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.colors.border),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.folder_rounded, color: context.colors.purple),
                  ),
                  title: Text(
                    cat['name'] ?? 'Unknown Folder',
                    style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    // Drill down into nested category
                    context.push('/domain/${widget.domainType}/category/${cat['id']}?title=${cat['name']}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
