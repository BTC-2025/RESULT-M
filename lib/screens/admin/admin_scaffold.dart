import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_datasets_screen.dart';
import 'admin_records_screen.dart';
import 'upload_center_screen.dart';
import 'admin_search_screen.dart';
import 'admin_team_screen.dart';
import 'admin_settings_screen.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  final int initialIndex;
  const AdminScaffold({super.key, this.initialIndex = 0});

  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  late int _currentIndex;
  bool _isSidebarOpen = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.go('/');
  }

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
    
    // Automatically close sidebar on smaller screens to prevent overflow if they were resized
    if (!isDesktop && _isSidebarOpen) {
      _isSidebarOpen = false;
    }

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
            const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.ink,
                side: BorderSide(color: context.colors.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Return to Home', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.liveRed.withValues(alpha: 0.1),
                foregroundColor: context.colors.liveRed,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: context.colors.liveRed.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              icon: _isLoggingOut
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.liveRed))
                  : const Icon(Icons.logout_rounded),
              label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildSideNav() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _isSidebarOpen ? 250 : 80,
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(_isSidebarOpen ? 20.0 : 16.0),
            child: Row(
              mainAxisAlignment: _isSidebarOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (_isSidebarOpen) ...[
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
                        Text('ResultHub', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Admin', style: TextStyle(color: context.colors.inkMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu_open_rounded, color: context.colors.ink),
                    onPressed: () => setState(() => _isSidebarOpen = false),
                    tooltip: 'Collapse Sidebar',
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(Icons.menu_rounded, color: context.colors.ink),
                    onPressed: () => setState(() => _isSidebarOpen = true),
                    tooltip: 'Expand Sidebar',
                  ),
                ]
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
                  padding: EdgeInsets.symmetric(horizontal: _isSidebarOpen ? 12.0 : 8.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = i),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12, 
                        horizontal: _isSidebarOpen ? 16 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? context.colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Row(
                        mainAxisAlignment: _isSidebarOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(isSelected ? item.activeIcon : item.icon, 
                            color: isSelected ? context.colors.blue : context.colors.inkMuted,
                            size: 24,
                          ),
                          if (_isSidebarOpen) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(item.label, style: TextStyle(
                                color: isSelected ? context.colors.blue : context.colors.ink,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              )),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // â”€â”€ Home button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: EdgeInsets.fromLTRB(_isSidebarOpen ? 16 : 8, 8, _isSidebarOpen ? 16 : 8, 4),
            child: _isSidebarOpen
              ? OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.ink,
                    side: BorderSide(color: context.colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Return to Home', style: TextStyle(fontWeight: FontWeight.w700)),
                )
              : IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  color: context.colors.ink,
                  tooltip: 'Return to Home',
                ),
          ),
          // â”€â”€ Logout button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: EdgeInsets.fromLTRB(_isSidebarOpen ? 16 : 8, 0, _isSidebarOpen ? 16 : 8, 16),
            child: _isSidebarOpen
              ? ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.liveRed.withValues(alpha: 0.1),
                    foregroundColor: context.colors.liveRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: context.colors.liveRed.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  icon: _isLoggingOut
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.liveRed))
                    : const Icon(Icons.logout_rounded),
                  label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
                )
              : IconButton(
                  onPressed: _isLoggingOut ? null : _logout,
                  icon: const Icon(Icons.logout_rounded),
                  color: context.colors.liveRed,
                  tooltip: 'Log Out',
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
