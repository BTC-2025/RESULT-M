import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/complaint_feed_notifier.dart';
import '../../widgets/complaint_card.dart';
import '../../core/theme/app_theme.dart';
import 'complaint_detail_screen.dart';
import 'create_complaint_screen.dart';

class ComplaintFeedScreen extends ConsumerStatefulWidget {
  const ComplaintFeedScreen({super.key});

  @override
  ConsumerState<ComplaintFeedScreen> createState() => _ComplaintFeedScreenState();
}

class _ComplaintFeedScreenState extends ConsumerState<ComplaintFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _sortTypes = ['trending', 'top', 'new'];
  final List<String> _categories = ['Infrastructure', 'Education', 'Sports', 'Politics', 'Other'];
  final List<String> _statuses = ['OPEN', 'UNDER_REVIEW', 'RESOLVED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final currentSort = _sortTypes[_tabController.index];
        ref.read(complaintFeedProvider(currentSort).notifier).loadMore();
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      // Refresh logic or filter apply logic if we wanted them isolated
    });
  }

  void _applyFilters() {
    for (var sort in _sortTypes) {
      ref.read(complaintFeedProvider(sort).notifier).setFilters(
        category: _selectedCategory,
        status: _selectedStatus,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: const Text('Complaint Box'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppChip(
              label: 'Community',
              color: context.colors.orange,
              icon: Icons.forum,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.orange,
          unselectedLabelColor: context.colors.inkMuted,
          indicatorColor: context.colors.orange,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: 'TRENDING'),
            Tab(text: 'TOP'),
            Tab(text: 'NEW'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.tune, size: 20, color: context.colors.inkMuted),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Category'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('All Categories')),
                      ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    hint: const Text('Status'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('All Statuses')),
                      ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedStatus = val);
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeed('trending'),
                _buildFeed('top'),
                _buildFeed('new'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateComplaintScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeed(String sortType) {
    final state = ref.watch(complaintFeedProvider(sortType));
    
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: context.colors.orange));
    }

    if (state.error != null && state.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => ref.read(complaintFeedProvider(sortType).notifier).refresh(),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (state.complaints.isEmpty) {
      return const Center(
        child: Text('No complaints found.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(complaintFeedProvider(sortType).notifier).refresh(),
      color: context.colors.orange,
      child: ListView.builder(
        // Use physics that always scroll so RefreshIndicator works even if list is small
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.complaints.length + (state.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.complaints.length) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: context.colors.orange)),
            );
          }
          
          final complaint = state.complaints[index];
          return ComplaintCard(
            complaint: complaint,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ComplaintDetailScreen(complaint: complaint)
              ));
            },
            onVote: (voteType) async {
              ref.read(complaintFeedProvider(sortType).notifier).castVote(complaint.id, voteType);
            },
          );
        },
      ),
    );
  }
}

