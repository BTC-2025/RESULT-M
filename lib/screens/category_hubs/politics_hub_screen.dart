import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'domain_datasets_tab.dart';
import 'shared_organizations_tab.dart';

class PoliticsHubScreen extends StatefulWidget {
  const PoliticsHubScreen({super.key});

  @override
  State<PoliticsHubScreen> createState() => _PoliticsHubScreenState();
}

class _PoliticsHubScreenState extends State<PoliticsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseCtrl.dispose();
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
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Politics Hub', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
                )),
                const SizedBox(width: 8),
                FadeTransition(
                  opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE', style: TextStyle(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1,
                    )),
                  ),
                ),
              ],
            ),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: context.colors.ink,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 112, 20, 58),
                  child: Row(children: [
                    const Expanded(child: _Chip('543', 'Constituencies')),
                    const SizedBox(width: 10),
                    const Expanded(child: _Chip('LIVE', 'Counting')),
                    const SizedBox(width: 10),
                    const Expanded(child: _Chip('12', 'Parties Leading')),
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
            DomainDatasetsTab(domainType: 'POLITICS', themeColor: Color(0xFFF59E0B)),
            SharedOrganizationsTab(domainType: 'POLITICS', themeColor: Color(0xFFF59E0B)),
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );
}
