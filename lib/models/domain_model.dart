import 'package:flutter/material.dart';

enum DomainType {
  academic,
  sport,
  government,
  politics,
  finance,
  entertainment,
  tech,
  law,
  healthcare,
  business,
  hyperLocal,
}

enum EventStatus { live, upcoming, past }

enum WorkspaceVisibility { public, passwordProtected, private }

class Subcategory {
  final String id;
  final String name;
  final String? subtitle;
  final EventStatus status;
  final String? agencyName;
  final String? dateStr;
  final List<String> availableExams;
  final String? workspaceId;
  final String? workspaceSlug;

  Subcategory({
    required this.id,
    required this.name,
    required this.status,
    this.subtitle,
    this.agencyName,
    this.dateStr,
    this.availableExams = const [],
    this.workspaceId,
    this.workspaceSlug,
  });
}

class ResultDomain {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DomainType type;
  final List<String> requiredCredentials;
  final List<Subcategory> subcategories;
  final WorkspaceVisibility visibility;

  ResultDomain({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.requiredCredentials = const [],
    this.subcategories = const [],
    this.visibility = WorkspaceVisibility.public,
  });

  ResultDomain copyWith({List<Subcategory>? subcategories}) {
    return ResultDomain(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type,
      requiredCredentials: requiredCredentials,
      subcategories: subcategories ?? this.subcategories,
      visibility: visibility,
    );
  }

  Color get displayColor {
    switch (type) {
      case DomainType.academic:
        return const Color(0xFF3B82F6);
      case DomainType.government:
        return const Color(0xFF10B981);
      case DomainType.sport:
        return const Color(0xFFFF5722);
      case DomainType.politics:
        return const Color(0xFF8B5CF6);
      case DomainType.finance:
        return const Color(0xFF059669);
      case DomainType.entertainment:
        return const Color(0xFFEC4899);
      case DomainType.tech:
        return const Color(0xFF0EA5E9);
      case DomainType.law:
        return const Color(0xFF92400E);
      case DomainType.healthcare:
        return const Color(0xFFDC2626);
      case DomainType.business:
        return const Color(0xFFF97316);
      case DomainType.hyperLocal:
        return const Color(0xFFF59E0B);
    }
  }
}

String? backendDomainTypeFor(DomainType type) {
  switch (type) {
    case DomainType.academic:
      return 'EDUCATION';
    case DomainType.sport:
      return 'SPORTS';
    case DomainType.finance:
      return 'FINANCE';
    case DomainType.politics:
      return 'POLITICS';
    case DomainType.entertainment:
      return 'ENTERTAINMENT';
    case DomainType.government:
      return 'GOVERNMENT';
    case DomainType.tech:
      return 'TECH';
    case DomainType.law:
      return 'LAW';
    case DomainType.healthcare:
      return 'HEALTHCARE';
    case DomainType.business:
      return 'BUSINESS';
    case DomainType.hyperLocal:
      return 'HYPERLOCAL';
  }
}

// ─── MOCK DATA ─────────────────────────────────────────────────────────────────

final List<ResultDomain> availableDomains = [
  ResultDomain(
    id: 'upsc',
    name: 'UPSC / Govt',
    icon: Icons.account_balance,
    color: const Color(0xFF10B981),
    type: DomainType.government,
    requiredCredentials: ['Roll Number', 'Date of Birth'],
  ),
  ResultDomain(
    id: 'university',
    name: 'Universities',
    icon: Icons.school,
    color: const Color(0xFF3B82F6),
    type: DomainType.academic,
    requiredCredentials: ['Student ID', 'Semester'],
  ),
  ResultDomain(
    id: 'boards',
    name: 'School Boards',
    icon: Icons.menu_book,
    color: const Color(0xFF3B82F6),
    type: DomainType.academic,
    requiredCredentials: ['Roll Number', 'School Code'],
  ),
  ResultDomain(
    id: 'sports',
    name: 'Sports Scores',
    icon: Icons.sports_score,
    color: const Color(0xFFFF5722),
    type: DomainType.sport,
  ),
  ResultDomain(
    id: 'politics',
    name: 'Elections',
    icon: Icons.how_to_vote,
    color: const Color(0xFF8B5CF6),
    type: DomainType.politics,
  ),
  ResultDomain(
    id: 'finance',
    name: 'Markets',
    icon: Icons.candlestick_chart,
    color: const Color(0xFF059669),
    type: DomainType.finance,
  ),
  ResultDomain(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie_creation,
    color: const Color(0xFFEC4899),
    type: DomainType.entertainment,
  ),
  ResultDomain(
    id: 'tech',
    name: 'Tech & AI',
    icon: Icons.memory,
    color: const Color(0xFF0EA5E9),
    type: DomainType.tech,
  ),
  ResultDomain(
    id: 'law',
    name: 'Law & Tenders',
    icon: Icons.gavel,
    color: const Color(0xFF92400E),
    type: DomainType.law,
  ),
  ResultDomain(
    id: 'hyper_local',
    name: 'Local & Private',
    icon: Icons.place,
    color: const Color(0xFFF59E0B),
    type: DomainType.hyperLocal,
    visibility: WorkspaceVisibility.passwordProtected,
  ),
  ResultDomain(
    id: 'business',
    name: 'Business',
    icon: Icons.business_center,
    color: const Color(0xFFF97316),
    type: DomainType.business,
  ),
];
