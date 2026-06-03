import 'package:flutter/material.dart';

enum DomainType { academic, sport, government, politics, finance, entertainment, tech, law, hyperLocal }

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

  Subcategory({
    required this.id,
    required this.name,
    required this.status,
    this.subtitle,
    this.agencyName,
    this.dateStr,
    this.availableExams = const [],
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

  Color get displayColor {
    switch (type) {
      case DomainType.academic:      return const Color(0xFF3B82F6);
      case DomainType.government:    return const Color(0xFF10B981);
      case DomainType.sport:         return const Color(0xFFFF5722);
      case DomainType.politics:      return const Color(0xFF8B5CF6);
      case DomainType.finance:       return const Color(0xFF059669);
      case DomainType.entertainment: return const Color(0xFFEC4899);
      case DomainType.tech:          return const Color(0xFF0EA5E9);
      case DomainType.law:           return const Color(0xFF92400E);
      case DomainType.hyperLocal:    return const Color(0xFFF59E0B);
    }
  }
}

// ─── MOCK DATA ─────────────────────────────────────────────────────────────────

final List<ResultDomain> availableDomains = [

  // ── 1. GOVERNMENT / UPSC ──────────────────────────────────────────────────
  ResultDomain(
    id: 'upsc',
    name: 'UPSC / Govt',
    icon: Icons.account_balance,
    color: const Color(0xFF10B981),
    type: DomainType.government,
    requiredCredentials: ['Roll Number', 'Date of Birth'],
    subcategories: [
      Subcategory(id: 'cse2026', name: 'Civil Services Exam 2026', status: EventStatus.live, subtitle: 'Final Results Declared', agencyName: 'Union Public Service Commission (UPSC)', dateStr: '6/1/2026'),
      Subcategory(id: 'ssc_cgl', name: 'SSC CGL Tier-1 2025', status: EventStatus.live, subtitle: 'Marks Released', agencyName: 'Staff Selection Commission', dateStr: '6/1/2026'),
      Subcategory(id: 'ibps_po', name: 'IBPS PO Prelims', status: EventStatus.upcoming, subtitle: 'Admit Card Soon', agencyName: 'IBPS', dateStr: '6/10/2026'),
      Subcategory(id: 'ies2026', name: 'Engineering Services 2026', status: EventStatus.live, subtitle: 'Mains Results'),
      Subcategory(id: 'capf2026', name: 'CAPF (AC) 2026', status: EventStatus.upcoming, subtitle: 'Physical Test Aug 1'),
    ],
  ),

  // ── 2. UNIVERSITIES ───────────────────────────────────────────────────────
  ResultDomain(
    id: 'university',
    name: 'Universities',
    icon: Icons.school,
    color: const Color(0xFF3B82F6),
    type: DomainType.academic,
    requiredCredentials: ['Student ID', 'Semester'],
    subcategories: [
      Subcategory(id: 'anna_univ', name: 'Anna University', status: EventStatus.live, subtitle: 'B.E / B.Tech Results', agencyName: 'Anna University', dateStr: '6/1/2026', availableExams: ['B.E Semester 1', 'B.E Semester 3', 'B.Tech Semester 5', 'M.E Final Semester']),
      Subcategory(id: 'madras_univ', name: 'Madras University', status: EventStatus.past, subtitle: 'UG/PG Nov 2025', agencyName: 'University of Madras', dateStr: '5/20/2026'),
      Subcategory(id: 'delhi_univ', name: 'Delhi University', status: EventStatus.upcoming, subtitle: 'Odd Semester 2026 Schedule', agencyName: 'Delhi University', dateStr: '6/15/2026'),
      Subcategory(id: 'mumbai_univ', name: 'Mumbai University', status: EventStatus.live, subtitle: 'Final Year Results', agencyName: 'Mumbai University', dateStr: '6/2/2026'),
      Subcategory(id: 'vit', name: 'VIT Vellore', status: EventStatus.upcoming, subtitle: 'Winter Semester 2025-26'),
      Subcategory(id: 'srm', name: 'SRM Institute', status: EventStatus.live, subtitle: 'Continuous Assessment 3'),
    ],
  ),

  // ── 3. SCHOOL BOARDS ──────────────────────────────────────────────────────
  ResultDomain(
    id: 'boards',
    name: 'School Boards',
    icon: Icons.menu_book,
    color: const Color(0xFF3B82F6),
    type: DomainType.academic,
    requiredCredentials: ['Roll Number', 'School Code'],
    subcategories: [
      Subcategory(id: 'cbse12', name: 'CBSE Class 12 Results', status: EventStatus.live, subtitle: 'Results Declared', agencyName: 'CBSE', dateStr: '5/12/2026'),
      Subcategory(id: 'cbse10', name: 'CBSE Class 10 Results', status: EventStatus.upcoming, subtitle: 'Evaluation in Progress', agencyName: 'CBSE', dateStr: '5/20/2026'),
      Subcategory(id: 'icse10', name: 'ICSE Class 10', status: EventStatus.live, subtitle: 'Scorecards Live', agencyName: 'CISCE', dateStr: '5/10/2026'),
      Subcategory(id: 'state_board', name: 'State Board SSLC', status: EventStatus.upcoming, subtitle: 'Notification Expected'),
    ],
  ),

  // ── 4. SPORTS ─────────────────────────────────────────────────────────────
  ResultDomain(
    id: 'sports',
    name: 'Sports Scores',
    icon: Icons.sports_score,
    color: const Color(0xFFFF5722),
    type: DomainType.sport,
    subcategories: [
      Subcategory(id: 'ipl2026', name: 'Indian Premier League 2026', status: EventStatus.live, subtitle: 'Live Matches & Points Table'),
      Subcategory(id: 't20worldcup', name: 'T20 World Cup 2026', status: EventStatus.upcoming, subtitle: 'Tournament Fixtures'),
      Subcategory(id: 'epl', name: 'English Premier League', status: EventStatus.live, subtitle: 'Live Matchweek 34'),
      Subcategory(id: 'ucl', name: 'UEFA Champions League', status: EventStatus.live, subtitle: 'Quarter Finals'),
      Subcategory(id: 'olympics2026', name: 'Olympics 2026 Medal Tally', status: EventStatus.upcoming, subtitle: 'Winter Games Schedule'),
      Subcategory(id: 'f1_2026', name: 'Formula 1 2026', status: EventStatus.live, subtitle: 'Monaco GP — Constructor Standings'),
    ],
  ),

  // ── 5. POLITICS & ELECTIONS ───────────────────────────────────────────────
  ResultDomain(
    id: 'politics',
    name: 'Elections',
    icon: Icons.how_to_vote,
    color: const Color(0xFF8B5CF6),
    type: DomainType.politics,
    subcategories: [
      Subcategory(id: 'lok_sabha_2026', name: 'Lok Sabha By-Polls 2026', status: EventStatus.live, subtitle: 'Live Seat Count — 12 Constituencies', agencyName: 'Election Commission of India', dateStr: '6/1/2026'),
      Subcategory(id: 'tn_assembly', name: 'Tamil Nadu Assembly By-Election', status: EventStatus.upcoming, subtitle: 'Vote Count Starts June 10', agencyName: 'ECI', dateStr: '6/10/2026'),
      Subcategory(id: 'us_midterms', name: 'US Senate Mid-Terms 2026', status: EventStatus.upcoming, subtitle: 'November 2026 — Early Polls', agencyName: 'Associated Press', dateStr: '11/3/2026'),
      Subcategory(id: 'uk_local', name: 'UK Local Council Elections', status: EventStatus.past, subtitle: 'Final Results Certified', agencyName: 'Electoral Commission UK', dateStr: '5/2/2026'),
    ],
  ),

  // ── 6. FINANCE & MARKETS ──────────────────────────────────────────────────
  ResultDomain(
    id: 'finance',
    name: 'Markets',
    icon: Icons.candlestick_chart,
    color: const Color(0xFF059669),
    type: DomainType.finance,
    subcategories: [
      Subcategory(id: 'nse_nifty', name: 'NSE Nifty 50 Daily Close', status: EventStatus.live, subtitle: 'Today: 24,512 ▲ +1.2%', dateStr: '6/2/2026'),
      Subcategory(id: 'bse_sensex', name: 'BSE Sensex Closing', status: EventStatus.live, subtitle: 'Today: 80,234 ▲ +0.9%', dateStr: '6/2/2026'),
      Subcategory(id: 'crypto_top10', name: 'Top 10 Crypto Prices', status: EventStatus.live, subtitle: 'BTC: \$69,200 | ETH: \$3,450'),
      Subcategory(id: 'q1_earnings', name: 'Q1 FY2026 Earnings Season', status: EventStatus.live, subtitle: 'Reliance, TCS, Infosys Reports In', agencyName: 'NSE/BSE Disclosures', dateStr: '6/2/2026'),
      Subcategory(id: 'rbi_rates', name: 'RBI Monetary Policy Decision', status: EventStatus.upcoming, subtitle: 'Rate Announcement June 7', agencyName: 'Reserve Bank of India', dateStr: '6/7/2026'),
    ],
  ),

  // ── 7. ENTERTAINMENT & AWARDS ─────────────────────────────────────────────
  ResultDomain(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie_creation,
    color: const Color(0xFFEC4899),
    type: DomainType.entertainment,
    subcategories: [
      Subcategory(id: 'box_office', name: 'Weekend Box Office India', status: EventStatus.live, subtitle: '1. Kalki 2898 AD — ₹82 Cr | 2. Stree 3', dateStr: '6/1/2026'),
      Subcategory(id: 'oscars2026', name: 'Academy Awards 2026 Winners', status: EventStatus.past, subtitle: 'Best Picture: The Horizon', agencyName: 'Academy of Motion Picture Arts', dateStr: '3/2/2026'),
      Subcategory(id: 'iifa_2026', name: 'IIFA Awards 2026', status: EventStatus.upcoming, subtitle: 'Ceremony July 15, Dubai'),
      Subcategory(id: 'music_charts', name: 'Spotify India Top 50 — This Week', status: EventStatus.live, subtitle: '1. Kesariya 2.0 | 2. Pasoori Nu'),
      Subcategory(id: 'bigg_boss', name: 'Bigg Boss 18 Grand Finale', status: EventStatus.past, subtitle: 'Winner Declared', dateStr: '2/10/2026'),
    ],
  ),

  // ── 8. DIGITAL & TECH ─────────────────────────────────────────────────────
  ResultDomain(
    id: 'tech',
    name: 'Tech & AI',
    icon: Icons.memory,
    color: const Color(0xFF0EA5E9),
    type: DomainType.tech,
    subcategories: [
      Subcategory(id: 'gpu_bench', name: 'GPU Benchmark Leaderboard 2026', status: EventStatus.live, subtitle: '1. Nvidia RTX 5090 | 2. AMD RX 9800'),
      Subcategory(id: 'llm_rank', name: 'AI / LLM Global Rankings (MMLU)', status: EventStatus.live, subtitle: 'GPT-5: 92.4% | Gemini Ultra 2: 91.8%'),
      Subcategory(id: 'play_store', name: 'Google Play Store Top Charts', status: EventStatus.live, subtitle: 'India Top Free Apps — June 2026'),
      Subcategory(id: 'app_store', name: 'Apple App Store Rankings', status: EventStatus.live, subtitle: 'Global Top Paid — June 2026'),
      Subcategory(id: 'domain_ranks', name: 'Top 100 Global Websites (Alexa)', status: EventStatus.past, subtitle: 'Q1 2026 Report', dateStr: '4/1/2026'),
    ],
  ),

  // ── 9. LAW & GOVERNMENT BIDS ──────────────────────────────────────────────
  ResultDomain(
    id: 'law',
    name: 'Law & Tenders',
    icon: Icons.gavel,
    color: const Color(0xFF92400E),
    type: DomainType.law,
    subcategories: [
      Subcategory(id: 'sc_verdicts', name: 'Supreme Court Landmark Verdicts', status: EventStatus.live, subtitle: 'Electoral Bonds Judgment — June 2026', agencyName: 'Supreme Court of India', dateStr: '6/1/2026'),
      Subcategory(id: 'hc_rulings', name: 'High Court Notable Rulings', status: EventStatus.live, subtitle: 'Madras HC: 3 Landmark Orders This Week'),
      Subcategory(id: 'gem_tenders', name: 'GeM Portal Government Tenders', status: EventStatus.live, subtitle: '₹2,400 Cr in Active Bids — IT & Infra', agencyName: 'Government e-Marketplace', dateStr: '6/2/2026'),
      Subcategory(id: 'cpwd_bids', name: 'CPWD Infrastructure Tenders', status: EventStatus.upcoming, subtitle: 'National Highway Projects — Bid Open June 15'),
      Subcategory(id: 'civil_merit', name: 'State Civil Services Merit List', status: EventStatus.live, subtitle: 'Tamil Nadu Group 2A — Final Select List', dateStr: '5/30/2026'),
    ],
  ),

  // ── 10. HYPER-LOCAL ────────────────────────────────────────────────────────
  ResultDomain(
    id: 'hyper_local',
    name: 'Local & Private',
    icon: Icons.place,
    color: const Color(0xFFF59E0B),
    type: DomainType.hyperLocal,
    visibility: WorkspaceVisibility.passwordProtected,
    subcategories: [
      Subcategory(id: 'gully_cricket', name: 'Putlur Local Cricket Finals 2026', status: EventStatus.live, subtitle: 'Live Scorecard • Man of the Match Active'),
      Subcategory(id: 'school_sports', name: 'St. Joseph\'s School Sports Day', status: EventStatus.upcoming, subtitle: 'Track & Field — House-wise Points'),
      Subcategory(id: 'corp_hackathon', name: 'TechCorp Internal Hackathon Q2', status: EventStatus.past, subtitle: 'Winners: Team Sigma — ₹50,000 Prize'),
      Subcategory(id: 'tuition_mock', name: 'Raja Coaching — NEET Mock #12', status: EventStatus.live, subtitle: 'Batch A Results Live • Password Protected', agencyName: 'Raja Coaching Center'),
      Subcategory(id: 'esports_room', name: 'BGMI Custom Room Finals', status: EventStatus.live, subtitle: 'Kill Leaderboard — Top 20 Players'),
    ],
  ),
];
