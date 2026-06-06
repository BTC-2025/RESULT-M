import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/badge_notifier.dart';

class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainShellScreen({super.key, required this.navigationShell});

  void _onTap(int index, WidgetRef ref) {
    if (index == 0) ref.read(badgeProvider.notifier).markComplaintsRead();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 820;
    final current = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: isWide
          ? Row(children: [
              _WideRail(currentIndex: current, onTap: (i) => _onTap(i, ref)),
              Expanded(child: navigationShell),
            ])
          : navigationShell,
      bottomNavigationBar: isWide ? null : _BottomBar(
        currentIndex: current,
        onTap: (i) => _onTap(i, ref),
      ),
      floatingActionButton: _ComposeFAB(currentIndex: current),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined,     Icons.home,          'Home'),
    _NavItem(Icons.leaderboard_outlined, Icons.leaderboard, 'Results'),
    _NavItem(Icons.search_outlined,   Icons.search,        'Search'),
    _NavItem(Icons.person_outline,    Icons.person,        'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.rail,
        border: Border(top: BorderSide(color: context.colors.borderBold)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top orange line on selected
                        Container(
                          height: 2,
                          width: selected ? 28 : 0,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: context.colors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? item.selectedIcon : item.icon,
                            key: ValueKey(selected),
                            color: selected ? context.colors.orange : context.colors.inkMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize:   9,
                            fontWeight: FontWeight.w800,
                            color: selected ? context.colors.orange : context.colors.inkFaint,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Wide Rail (tablet / web) ─────────────────────────────────────────────────
class _WideRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _WideRail({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined,      Icons.home,           'Home'),
    _NavItem(Icons.leaderboard_outlined, Icons.leaderboard,  'Results'),
    _NavItem(Icons.search_outlined,    Icons.search,         'Search'),
    _NavItem(Icons.person_outline,     Icons.person,         'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      color: context.colors.rail,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.orange,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Icon(Icons.leaderboard, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 24),
            ...List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Tooltip(
                  message: item.label,
                  preferBelow: false,
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? context.colors.railActive : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: selected
                              ? context.colors.orange.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected ? context.colors.orange : context.colors.inkMuted,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: selected ? context.colors.orange : context.colors.inkFaint,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Compose FAB ─────────────────────────────────────────────────────────────
class _ComposeFAB extends StatelessWidget {
  final int currentIndex;
  const _ComposeFAB({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    // Only show on Home (0) and Results (1) tabs
    if (currentIndex > 1) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.full),
        boxShadow: AppShadows.orangeGlow,
      ),
      child: FloatingActionButton(
        heroTag: 'compose_fab',
        onPressed: () => _showComposeSheet(context),
        backgroundColor: context.colors.orange,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  void _showComposeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _ComposeSheet(),
    );
  }
}

// ─── Compose Sheet ────────────────────────────────────────────────────────────
class _ComposeSheet extends StatelessWidget {
  const _ComposeSheet();

  @override
  Widget build(BuildContext context) {
    final items = [
      _ComposeOption(Icons.campaign_outlined,   'Complaint',   context.colors.amber,  '/complaints/new'),
      _ComposeOption(Icons.poll_outlined,        'Poll',        context.colors.purple, '/votes/new'),
      _ComposeOption(Icons.edit_outlined,        'Result Post', context.colors.blue,   null),
      _ComposeOption(Icons.add_business_outlined,'New Workspace',context.colors.green, '/admin/dashboard'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(
              children: [
                Text('Create', style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                )),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: context.colors.inkMuted),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          ...items.map((item) => _ComposeOptionTile(
            option: item,
            onTap: () {
              Navigator.pop(context);
              if (item.route != null) context.push(item.route!);
            },
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ComposeOption {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  const _ComposeOption(this.icon, this.label, this.color, this.route);
}

class _ComposeOptionTile extends StatelessWidget {
  final _ComposeOption option;
  final VoidCallback onTap;
  const _ComposeOptionTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(option.icon, color: option.color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(option.label, style: TextStyle(
              color: context.colors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            )),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: context.colors.inkFaint, size: 14),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}
