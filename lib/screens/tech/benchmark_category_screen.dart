import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';
import 'device_selection_screen.dart';

class BenchmarkCategoryScreen extends StatefulWidget {
  const BenchmarkCategoryScreen({super.key});

  @override
  State<BenchmarkCategoryScreen> createState() => _BenchmarkCategoryScreenState();
}

class _BenchmarkCategoryScreenState extends State<BenchmarkCategoryScreen> {
  final _searchCtrl = TextEditingController();
  final DomainTheme _theme = DomainThemeFactory.getTheme(WorkspaceCategory.technology);

  final List<Map<String, String>> _allCategories = [
    {'name': 'Desktop Processors', 'desc': 'CPU Single-Core & Multi-Core', 'id': 'cpu'},
    {'name': 'Graphics Cards', 'desc': 'GPU rendering & gaming performance', 'id': 'gpu'},
    {'name': 'Mobile SOCs', 'desc': 'Smartphones & Tablets chips', 'id': 'mobile-soc'},
    {'name': 'AI Accelerators', 'desc': 'NPU & Tensor Cores', 'id': 'ai-accel'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allCategories;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allCategories;
      } else {
        _filtered = _allCategories
            .where((c) => c['name']!.toLowerCase().contains(query.toLowerCase()) || 
                          c['desc']!.toLowerCase().contains(query.toLowerCase()))
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
        title: const Text('Hardware Benchmarks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                hintText: '🔍 Search Categories...',
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
                final category = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: _theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.memory, color: _theme.primaryColor),
                  ),
                  title: Text(category['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                  subtitle: Text(category['desc']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeviceSelectionScreen(
                          categoryId: category['id']!,
                          categoryName: category['name']!,
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
