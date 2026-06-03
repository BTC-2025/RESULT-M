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

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Subcategory> _searchResults = [];
  bool _isLoading = false;

  final List<Subcategory> _allEvents = [];

  @override
  void initState() {
    super.initState();
    // Gather all events for searching
    for (var domain in availableDomains) {
      _allEvents.addAll(domain.subcategories);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for premium feel
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = _allEvents
              .where((item) => item.name.toLowerCase().contains(query.toLowerCase()) || 
                               (item.agencyName?.toLowerCase().contains(query.toLowerCase()) ?? false))
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search exams, universities...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('What are you looking for?', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No results found for "${_searchController.text}"', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final sub = _searchResults[index];
        final domain = availableDomains.firstWhere((d) => d.subcategories.contains(sub));
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
              child: Icon(domain.icon, color: const Color(0xFF0F172A)),
            ),
            title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            subtitle: Text(domain.name, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              if (domain.type == DomainType.sport) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SportsFeedScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.government) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GovtDetailScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.politics) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PoliticsScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.finance) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FinanceScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.entertainment) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EntertainmentScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.tech) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TechScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.law) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LawScreen(domain: domain, subcategory: sub)));
              } else if (domain.type == DomainType.hyperLocal) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LocalWorkspaceScreen(domain: domain, subcategory: sub)));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CredentialScreen(domain: domain, subcategory: sub)));
              }
            },
          ),
        );
      },
    );
  }
}
