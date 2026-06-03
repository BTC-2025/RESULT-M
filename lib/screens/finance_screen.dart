import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/domain_model.dart';
import '../providers/domain_feed_notifier.dart';
import '../widgets/record_card_factory.dart';

class FinanceScreen extends ConsumerWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const FinanceScreen({super.key, required this.domain, required this.subcategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(domainFeedProvider(domain.type));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(subcategory.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(domainFeedProvider(domain.type).notifier).refresh();
            },
          ),
        ],
      ),
      body: feedState.when(
        data: (feedItems) {
          if (feedItems.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              final item = feedItems[index];
              return _buildWorkspaceSection(context, item);
            },
          );
        },
        loading: () => _buildSkeletonLoader(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load: $err', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(domainFeedProvider(domain.type).notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'No ${domain.name} results published yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              'Be the first to create a workspace!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceSection(BuildContext context, DomainFeedItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            children: [
              const Icon(Icons.business, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.workspaceName,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ),
        ...item.records.map((record) => InkWell(
          onTap: () {
            context.push('/workspace/${item.workspaceId}?name=${Uri.encodeComponent(item.workspaceName)}');
          },
          child: RecordCardFactory(domainType: domain.type, record: record),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Center(child: CircularProgressIndicator(color: Colors.grey)),
        );
      },
    );
  }
}
