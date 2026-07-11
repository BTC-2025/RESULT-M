import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/home_feed_tab.dart';

class HomeTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final HomeFeedTab selected;
  final double topPadding;
  final ValueChanged<HomeFeedTab> onSelected;

  const HomeTabsHeaderDelegate({
    required this.selected,
    required this.topPadding,
    required this.onSelected,
  });

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final pinnedOffset = overlapsContent ? topPadding : 0.0;
    return Container(
      color: context.colors.bg,
      height: 48,
      child: Transform.translate(
        offset: Offset(0, pinnedOffset),
        child: Container(
          height: 48,
          color: context.colors.bg,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: HomeFeedTab.values.map((tab) {
              final active = tab == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: InkWell(
                  onTap: () => onSelected(tab),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: active
                              ? context.colors.purple
                              : context.colors.inkMuted,
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: active ? 32 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: context.colors.purple,
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeTabsHeaderDelegate oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.topPadding != topPadding;
  }
}
