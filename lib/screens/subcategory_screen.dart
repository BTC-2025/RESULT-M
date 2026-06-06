import 'package:flutter/material.dart';
import '../models/domain_model.dart';
import 'credential_screen.dart';
import 'sports_feed_screen.dart';
import 'govt_detail_screen.dart';
import 'politics_screen.dart';
import 'finance_screen.dart';
import 'entertainment_screen.dart';
import 'tech_screen.dart';
import 'law_screen.dart';
import 'local_workspace_screen.dart';

class SubcategoryScreen extends StatelessWidget {
  final ResultDomain domain;

  const SubcategoryScreen({super.key, required this.domain});

  void _navigateToFinal(BuildContext context, Subcategory subcategory) {
    if (subcategory.workspaceId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalWorkspaceScreen(
            workspaceId: subcategory.workspaceId!,
            workspaceName: subcategory.name,
            domain: domain,
            subcategory: subcategory,
          ),
        ),
      );
      return;
    }

    if (subcategory.status == EventStatus.upcoming) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${subcategory.name} starts soon! Stay tuned.'),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (domain.type == DomainType.sport) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SportsFeedScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.government) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GovtDetailScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.politics) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PoliticsScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.finance) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FinanceScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.entertainment) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EntertainmentScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.tech) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TechScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.law) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LawScreen(domain: domain, subcategory: subcategory),
        ),
      );
    } else if (domain.type == DomainType.hyperLocal) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalWorkspaceScreen(
            workspaceId: subcategory.id,
            workspaceName: subcategory.name,
            domain: domain,
            subcategory: subcategory,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CredentialScreen(domain: domain, subcategory: subcategory),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            domain.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          bottom: TabBar(
            labelColor: domain.displayColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: domain.displayColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'LIVE'),
              Tab(text: 'UPCOMING'),
              Tab(text: 'PAST'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, EventStatus.live),
            _buildList(context, EventStatus.upcoming),
            _buildList(context, EventStatus.past),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, EventStatus status) {
    final filteredList = domain.subcategories
        .where((s) => s.status == status)
        .toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          'No ${status.name.toUpperCase()} events found.',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final sub = filteredList[index];
        final badgeColor = _getStatusColor(status);

        return InkWell(
          onTap: () => _navigateToFinal(context, sub),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Badge & Bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        domain.name.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.bookmark_border,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Middle Section: Title & Agency
                Text(
                  sub.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scraped automatically from: ${sub.agencyName ?? "Official Board"}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Row: Date & View Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sub.dateStr ?? '6/1/2026',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.live:
        return const Color(0xFFFF5722); // Orange
      case EventStatus.upcoming:
        return const Color(0xFF3B82F6); // Blue
      case EventStatus.past:
        return Colors.grey; // Grey
    }
  }
}
