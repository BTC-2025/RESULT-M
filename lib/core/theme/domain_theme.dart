import 'package:flutter/material.dart';

enum WorkspaceCategory {
  academic,
  government,
  law,
  healthcare,
  entertainment,
  technology,
  sports,
  politics,
  finance,
  business,
  hyperlocal,
  unknown
}

enum HeroWidgetType {
  gradeCircle,
  meritRankBadge,
  caseDisposition,
  qualifyingScore,
  awardPodium,
  leaderboardRank,
  generic
}

class DomainTheme {
  final Color primaryColor;
  final Color gradientStart;
  final Color gradientEnd;
  final HeroWidgetType heroType;
  final FontStyle fontStyle;

  const DomainTheme({
    required this.primaryColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.heroType,
    required this.fontStyle,
  });

  factory DomainTheme.generic() {
    return const DomainTheme(
      primaryColor: Color(0xFF374151),
      gradientStart: Color(0xFF374151),
      gradientEnd: Color(0xFF1F2937),
      heroType: HeroWidgetType.generic,
      fontStyle: FontStyle.normal,
    );
  }
}

class DomainThemeFactory {
  static DomainTheme getTheme(WorkspaceCategory category) {
    switch (category) {
      case WorkspaceCategory.academic:
        return const DomainTheme(
          primaryColor: Color(0xFF1A3A5C),
          gradientStart: Color(0xFF1A3A5C),
          gradientEnd: Color(0xFF2D5F8E),
          heroType: HeroWidgetType.gradeCircle,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.government:
        return const DomainTheme(
          primaryColor: Color(0xFF1B3A2F),
          gradientStart: Color(0xFF1B3A2F),
          gradientEnd: Color(0xFF2E6B4F),
          heroType: HeroWidgetType.meritRankBadge,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.law:
        return const DomainTheme(
          primaryColor: Color(0xFF1C1C1C),
          gradientStart: Color(0xFF1C1C1C),
          gradientEnd: Color(0xFF2C2C2C),
          heroType: HeroWidgetType.caseDisposition,
          fontStyle: FontStyle.italic, // serif-like indicator
        );
      case WorkspaceCategory.healthcare:
        return const DomainTheme(
          primaryColor: Color(0xFF0F4C5C),
          gradientStart: Color(0xFF0F4C5C),
          gradientEnd: Color(0xFF1A7A8A),
          heroType: HeroWidgetType.qualifyingScore,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.entertainment:
        return const DomainTheme(
          primaryColor: Color(0xFF8B1A1A),
          gradientStart: Color(0xFF8B1A1A),
          gradientEnd: Color(0xFFC4960A),
          heroType: HeroWidgetType.awardPodium,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.technology:
        return const DomainTheme(
          primaryColor: Color(0xFF1A1A3E),
          gradientStart: Color(0xFF1A1A3E),
          gradientEnd: Color(0xFF2D2D6E),
          heroType: HeroWidgetType.leaderboardRank,
          fontStyle: FontStyle.normal,
        );
      default:
        return DomainTheme.generic();
    }
  }

  static WorkspaceCategory parseCategory(String categoryStr) {
    final s = categoryStr.toUpperCase();
    if (s.contains('ACADEMIC') || s.contains('EDU')) return WorkspaceCategory.academic;
    if (s.contains('GOV')) return WorkspaceCategory.government;
    if (s.contains('LAW') || s.contains('COURT')) return WorkspaceCategory.law;
    if (s.contains('HEALTH') || s.contains('MED')) return WorkspaceCategory.healthcare;
    if (s.contains('ENTERTAIN') || s.contains('MOVIE')) return WorkspaceCategory.entertainment;
    if (s.contains('TECH')) return WorkspaceCategory.technology;
    if (s.contains('SPORT')) return WorkspaceCategory.sports;
    if (s.contains('POLITIC')) return WorkspaceCategory.politics;
    if (s.contains('FINANCE') || s.contains('ECON')) return WorkspaceCategory.finance;
    if (s.contains('BUSINESS')) return WorkspaceCategory.business;
    if (s.contains('LOCAL')) return WorkspaceCategory.hyperlocal;
    return WorkspaceCategory.unknown;
  }
}
