import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'school_exam_screen.dart';

class SchoolHubScreen extends StatefulWidget {
  const SchoolHubScreen({super.key});

  @override
  State<SchoolHubScreen> createState() => _SchoolHubScreenState();
}

class _SchoolHubScreenState extends State<SchoolHubScreen> {
  final _searchCtrl = TextEditingController();
  
  final List<String> _allBoards = [
    'CBSE (Central Board of Secondary Education)',
    'ICSE (Council for the Indian School Certificate Examinations)',
    'State Board of Tamil Nadu',
    'Maharashtra State Board',
    'UP Board of High School and Intermediate Education',
    'Karnataka Secondary Education Examination Board',
    'Kerala Board of Public Examinations',
    'Andhra Pradesh Board of Secondary Education',
    'Telangana State Board of Intermediate Education',
    'West Bengal Board of Secondary Education',
  ];
  
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allBoards;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allBoards;
      } else {
        _filtered = _allBoards
            .where((b) => b.toLowerCase().contains(query.toLowerCase()))
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
        title: Text('Select School Board', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
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
                hintText: '🔍 Search Education Board',
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
                final board = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: context.colors.teal.withValues(alpha: 0.1),
                    child: Icon(Icons.backpack, color: context.colors.teal),
                  ),
                  title: Text(board, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchoolExamScreen(boardName: board),
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
