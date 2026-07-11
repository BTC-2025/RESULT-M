import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'domain_datasets_tab.dart';
import 'shared_organizations_tab.dart';

/// Entertainment Hub — Box Office, Awards, Reality Shows, Music Charts
class EntertainmentHubScreen extends StatefulWidget {
  const EntertainmentHubScreen({super.key});

  @override
  State<EntertainmentHubScreen> createState() => _EntertainmentHubScreenState();
}

class _EntertainmentHubScreenState extends State<EntertainmentHubScreen>
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
            expandedHeight: 220,
            pinned: true,
            backgroundColor: context.colors.ink,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Entertainment', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
            )),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: context.colors.ink,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 112, 20, 58),
                  child: Row(children: [
                    const Expanded(child: _Chip('BOX OFFICE', 'This Weekend')),
                    const SizedBox(width: 10),
                    const Expanded(child: _Chip('73rd', 'National Awards')),
                    const SizedBox(width: 10),
                    const Expanded(child: _Chip('Cinema', 'Charts')),
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
            DomainDatasetsTab(domainType: 'ENTERTAINMENT', themeColor: Color(0xFFDB2777)),
            SharedOrganizationsTab(domainType: 'ENTERTAINMENT', themeColor: Color(0xFFDB2777)),
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
