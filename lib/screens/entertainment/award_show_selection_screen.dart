import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';
import 'category_selection_screen.dart';

class AwardShowSelectionScreen extends StatefulWidget {
  const AwardShowSelectionScreen({super.key});

  @override
  State<AwardShowSelectionScreen> createState() => _AwardShowSelectionScreenState();
}

class _AwardShowSelectionScreenState extends State<AwardShowSelectionScreen> {
  final _searchCtrl = TextEditingController();
  final DomainTheme _theme = DomainThemeFactory.getTheme(WorkspaceCategory.entertainment);

  final List<Map<String, String>> _allShows = [
    {'name': 'Oscars 2026', 'desc': 'Academy Awards', 'id': 'oscars26'},
    {'name': 'Filmfare Awards', 'desc': 'Indian Cinema Awards', 'id': 'filmfare'},
    {'name': 'Grammy Awards', 'desc': 'Music Industry Awards', 'id': 'grammys'},
    {'name': 'Emmy Awards', 'desc': 'Television Awards', 'id': 'emmys'},
    {'name': 'Box Office Rankings', 'desc': 'Global Top Grossing', 'id': 'boxoffice'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allShows;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allShows;
      } else {
        _filtered = _allShows
            .where((s) => s['name']!.toLowerCase().contains(query.toLowerCase()) || 
                          s['desc']!.toLowerCase().contains(query.toLowerCase()))
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
        title: const Text('Select Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                hintText: '🔍 Search Events...',
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
                final show = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: _theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.movie, color: _theme.primaryColor),
                  ),
                  title: Text(show['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                  subtitle: Text(show['desc']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategorySelectionScreen(
                          showId: show['id']!,
                          showName: show['name']!,
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
