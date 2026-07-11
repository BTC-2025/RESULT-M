import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';
import 'govt_exam_selection_screen.dart';

class DepartmentSelectionScreen extends StatefulWidget {
  const DepartmentSelectionScreen({super.key});

  @override
  State<DepartmentSelectionScreen> createState() => _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  final _searchCtrl = TextEditingController();
  final DomainTheme _theme = DomainThemeFactory.getTheme(WorkspaceCategory.government);

  final List<Map<String, String>> _allDepartments = [
    {'name': 'TNPSC', 'desc': 'Tamil Nadu Public Service Commission', 'id': 'tnpsc'},
    {'name': 'UPSC', 'desc': 'Union Public Service Commission', 'id': 'upsc'},
    {'name': 'SSC', 'desc': 'Staff Selection Commission', 'id': 'ssc'},
    {'name': 'RRB', 'desc': 'Railway Recruitment Board', 'id': 'rrb'},
    {'name': 'IBPS', 'desc': 'Institute of Banking Personnel Selection', 'id': 'ibps'},
    {'name': 'TNUrb', 'desc': 'Tamil Nadu Uniformed Services', 'id': 'tnurb'},
    {'name': 'TRB', 'desc': 'Teachers Recruitment Board', 'id': 'trb'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allDepartments;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allDepartments;
      } else {
        _filtered = _allDepartments
            .where((d) => d['name']!.toLowerCase().contains(query.toLowerCase()) || 
                          d['desc']!.toLowerCase().contains(query.toLowerCase()))
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
        title: const Text('Select Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                hintText: '🔍 Search Departments...',
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
                final dept = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: _theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.account_balance, color: _theme.primaryColor),
                  ),
                  title: Text(dept['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                  subtitle: Text(dept['desc']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GovtExamSelectionScreen(
                          departmentId: dept['id']!,
                          departmentName: dept['name']!,
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
