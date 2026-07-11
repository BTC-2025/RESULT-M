import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';
import 'constituency_selection_screen.dart';

class ElectionStateScreen extends StatefulWidget {
  const ElectionStateScreen({super.key});

  @override
  State<ElectionStateScreen> createState() => _ElectionStateScreenState();
}

class _ElectionStateScreenState extends State<ElectionStateScreen> {
  final _searchCtrl = TextEditingController();
  final DomainTheme _theme = DomainThemeFactory.getTheme(WorkspaceCategory.politics);

  final List<Map<String, String>> _allStates = [
    {'name': 'Tamil Nadu', 'desc': 'Assembly Elections 2026', 'id': 'tn-assembly'},
    {'name': 'National', 'desc': 'Lok Sabha Elections 2024', 'id': 'lok-sabha'},
    {'name': 'Karnataka', 'desc': 'Assembly Elections', 'id': 'ka-assembly'},
    {'name': 'Maharashtra', 'desc': 'Assembly Elections', 'id': 'mh-assembly'},
    {'name': 'Kerala', 'desc': 'Assembly Elections', 'id': 'kl-assembly'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allStates;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allStates;
      } else {
        _filtered = _allStates
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
        title: const Text('Select State / Region', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                hintText: '🔍 Search State or Election...',
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
                final stateData = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: _theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.how_to_vote, color: _theme.primaryColor),
                  ),
                  title: Text(stateData['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                  subtitle: Text(stateData['desc']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConstituencySelectionScreen(
                          electionId: stateData['id']!,
                          electionName: '${stateData['name']} - ${stateData['desc']}',
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
