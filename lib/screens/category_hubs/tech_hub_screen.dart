import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'domain_datasets_tab.dart';
import 'shared_organizations_tab.dart';

class TechHubScreen extends StatefulWidget {
  const TechHubScreen({super.key});

  @override
  State<TechHubScreen> createState() => _TechHubScreenState();
}

class _TechHubScreenState extends State<TechHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: context.colors.ink,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Tech Hub', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
            )),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: context.colors.ink,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 112, 20, 58),
                  child: Row(children: const [
                    Expanded(child: _Chip('AI', 'Leaderboards')),
                    SizedBox(width: 10),
                    Expanded(child: _Chip('GPU', 'Benchmarks')),
                    SizedBox(width: 10),
                    Expanded(child: _Chip('Top 100', 'Apps')),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: context.colors.orange,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Datasets'),
                Tab(text: 'Organizations'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            DomainDatasetsTab(domainType: 'TECH', themeColor: Color(0xFF0891B2)),
            SharedOrganizationsTab(domainType: 'TECH', themeColor: Color(0xFF0891B2)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String value, label;
  const _Chip(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 72),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.15),
      ),
    ]),
  );
}
