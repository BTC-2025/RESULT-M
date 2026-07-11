import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';
import 'bench_selection_screen.dart';

class CourtSelectionScreen extends StatefulWidget {
  const CourtSelectionScreen({super.key});

  @override
  State<CourtSelectionScreen> createState() => _CourtSelectionScreenState();
}

class _CourtSelectionScreenState extends State<CourtSelectionScreen> {
  final _searchCtrl = TextEditingController();
  final DomainTheme _theme = DomainThemeFactory.getTheme(WorkspaceCategory.law);

  final List<Map<String, String>> _allCourts = [
    {'name': 'Supreme Court of India', 'location': 'New Delhi', 'id': 'sc-india'},
    {'name': 'Madras High Court', 'location': 'Chennai, Tamil Nadu', 'id': 'hc-madras'},
    {'name': 'Madurai Bench of Madras HC', 'location': 'Madurai, Tamil Nadu', 'id': 'hc-madurai'},
    {'name': 'Bombay High Court', 'location': 'Mumbai, Maharashtra', 'id': 'hc-bombay'},
    {'name': 'Delhi High Court', 'location': 'New Delhi', 'id': 'hc-delhi'},
    {'name': 'Chennai District Court', 'location': 'Chennai', 'id': 'dc-chennai'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allCourts;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allCourts;
      } else {
        _filtered = _allCourts
            .where((c) => c['name']!.toLowerCase().contains(query.toLowerCase()) || 
                          c['location']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: _theme.primaryColor,
        elevation: 0,
        title: const Text('Select Court', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: _theme.primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: TextStyle(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: '🔍 Search Courts...',
                hintStyle: TextStyle(color: context.colors.inkMuted),
                filled: true,
                fillColor: context.colors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.search, color: context.colors.inkMuted),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.border),
              itemBuilder: (context, index) {
                final court = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: _theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.account_balance, color: _theme.primaryColor),
                  ),
                  title: Text(court['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'serif')),
                  subtitle: Text(court['location']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BenchSelectionScreen(
                          courtId: court['id']!,
                          courtName: court['name']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
