import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'examination_selection_screen.dart';

class UniversityHubScreen extends StatefulWidget {
  const UniversityHubScreen({super.key});

  @override
  State<UniversityHubScreen> createState() => _UniversityHubScreenState();
}

class _UniversityHubScreenState extends State<UniversityHubScreen> {
  final _searchCtrl = TextEditingController();
  
  final List<String> _allUniversities = [
    'Anna University',
    'University of Madras',
    'Bharathiar University',
    'Bharathidasan University',
    'Alagappa University',
    'Periyar University',
    'VIT University',
    'SRM University',
    'Madurai Kamaraj University',
    'Annamalai University',
  ];
  
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allUniversities;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allUniversities;
      } else {
        _filtered = _allUniversities
            .where((u) => u.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text('Select University', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: TextStyle(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: '🔍 Search University',
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
                final univ = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: context.colors.orange.withValues(alpha: 0.1),
                    child: Icon(Icons.account_balance, color: context.colors.orange),
                  ),
                  title: Text(univ, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 16)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExaminationSelectionScreen(universityName: univ),
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
