import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'domain_datasets_tab.dart';
import 'shared_organizations_tab.dart';

class AcademicHubScreen extends ConsumerStatefulWidget {
  const AcademicHubScreen({super.key});

  @override
  ConsumerState<AcademicHubScreen> createState() => _AcademicHubScreenState();
}

class _AcademicHubScreenState extends ConsumerState<AcademicHubScreen>
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
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: context.colors.ink,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Academic Hub', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
            )),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: context.colors.ink,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 112, 20, 58),
                  child: Row(
                    children: [
                      const Expanded(child: _StatChip('12M+', 'Students')),
                      const SizedBox(width: 10),
                      const Expanded(child: _StatChip('8,500+', 'Exams')),
                      const SizedBox(width: 10),
                      const Expanded(child: _StatChip('2,300+', 'Institutions')),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: context.colors.orange,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Datasets'),
                Tab(text: 'Institutions'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            DomainDatasetsTab(domainType: 'EDUCATION', themeColor: Color(0xFF3B82F6)),
            SharedOrganizationsTab(domainType: 'EDUCATION', themeColor: Color(0xFF3B82F6)),
          ],
        ),
      ),
    );
  }
}



class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900,
          )),
          Text(label, style: const TextStyle(
            color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
