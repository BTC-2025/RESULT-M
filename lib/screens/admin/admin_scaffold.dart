import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_datasets_screen.dart';
import 'admin_records_screen.dart';
import 'upload_center_screen.dart';
import 'admin_search_screen.dart';
import 'admin_team_screen.dart';
import 'admin_settings_screen.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  const AdminScaffold({super.key});

  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminDatasetsScreen(),
    const AdminRecordsScreen(),
    const UploadCenterScreen(),
    const AdminSearchScreen(),
    const AdminTeamScreen(),
    const AdminSettingsScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    _NavItem('Datasets', Icons.folder_open_outlined, Icons.folder),
    _NavItem('Records', Icons.table_chart_outlined, Icons.table_chart),
    _NavItem('Upload', Icons.upload_file_outlined, Icons.upload_file),
    _NavItem('Search', Icons.search_outlined, Icons.search),
    _NavItem('Team', Icons.group_outlined, Icons.group),
    _NavItem('Settings', Icons.settings_outlined, Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text(_navItems[_currentIndex].label, style: TextStyle(
          color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 18,
        )),
      ),
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop) _buildSideNav(),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(Icons.corporate_fare_rounded, color: context.colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ResultHub', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('Workspace Admin', style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final isSelected = _currentIndex == i;
                  return ListTile(
                    leading: Icon(isSelected ? item.activeIcon : item.icon, 
                      color: isSelected ? context.colors.blue : context.colors.inkMuted,
                    ),
                    title: Text(item.label, style: TextStyle(
                      color: isSelected ? context.colors.blue : context.colors.ink,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    )),
                    selected: isSelected,
                    selectedTileColor: context.colors.blue.withValues(alpha: 0.1),
                    onTap: () {
                      setState(() => _currentIndex = i);
                      Navigator.pop(context); // close drawer
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 250,
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(Icons.corporate_fare_rounded, color: context.colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ResultHub', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
                      Text('Workspace Admin', style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isSelected = _currentIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    leading: Icon(isSelected ? item.activeIcon : item.icon, 
                      color: isSelected ? context.colors.blue : context.colors.inkMuted,
                    ),
                    title: Text(item.label, style: TextStyle(
                      color: isSelected ? context.colors.blue : context.colors.ink,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    )),
                    selected: isSelected,
                    selectedTileColor: context.colors.blue.withValues(alpha: 0.1),
                    onTap: () => setState(() => _currentIndex = i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.label, this.icon, this.activeIcon);
}
