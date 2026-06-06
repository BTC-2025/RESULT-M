import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/voting_hub_notifier.dart';
import '../../widgets/vote_box_card.dart';
import '../../core/theme/app_theme.dart';
import 'vote_box_detail_screen.dart';
import 'create_vote_box_screen.dart';

class VotingHubScreen extends ConsumerStatefulWidget {
  const VotingHubScreen({super.key});

  @override
  ConsumerState<VotingHubScreen> createState() => _VotingHubScreenState();
}

class _VotingHubScreenState extends ConsumerState<VotingHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(votingHubProvider.notifier).loadMore();
      }
    });
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
        title: const Text('Voting Hub'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppChip(
              label: 'Opinion',
              color: context.colors.blue,
              icon: Icons.bolt,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.blue,
          unselectedLabelColor: context.colors.inkMuted,
          indicatorColor: context.colors.blue,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: 'PUBLIC POLLS'),
            Tab(text: 'MY POLLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(),
          _buildMyPolls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateVoteBoxScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeed() {
    final state = ref.watch(votingHubProvider);

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: context.colors.blue));
    }

    if (state.error != null && state.voteBoxes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => ref.read(votingHubProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.voteBoxes.isEmpty) {
      return const Center(
        child: Text('No polls available right now.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(votingHubProvider.notifier).refresh(),
      color: context.colors.blue,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.voteBoxes.length + (state.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.voteBoxes.length) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: context.colors.blue)),
            );
          }

          final box = state.voteBoxes[index];
          return VoteBoxCard(
            voteBox: box,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => VoteBoxDetailScreen(voteBoxId: box.id)
              ));
            },
          );
        },
      ),
    );
  }

  Widget _buildMyPolls() {
    // Mock implementation for My Polls since the backend endpoint doesn't exist yet
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 48, color: context.colors.inkMuted),
          const SizedBox(height: 16),
          Text('My Polls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.ink)),
          const SizedBox(height: 8),
          Text('Coming soon! View and manage your created polls here.', style: TextStyle(color: context.colors.inkMuted)),
        ],
      ),
    );
  }
}

