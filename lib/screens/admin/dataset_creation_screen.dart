import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class DatasetCreationScreen extends StatefulWidget {
  const DatasetCreationScreen({super.key});

  @override
  State<DatasetCreationScreen> createState() => _DatasetCreationScreenState();
}

class _DatasetCreationScreenState extends State<DatasetCreationScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedType = 'Searchable';
  String _inputMethod = 'CSV Upload';

  final _types = [
    {'name': 'Searchable', 'desc': 'Users search by specific keys (e.g., Reg No + DOB)'},
    {'name': 'Public Listing', 'desc': 'Shows all records in a list view'},
    {'name': 'Protected Lookup', 'desc': 'Requires a common passcode to view'},
    {'name': 'Private Internal', 'desc': 'Only your team can view this data'},
  ];

  final _methods = [
    {'name': 'CSV Upload', 'icon': Icons.file_present},
    {'name': 'Excel Upload', 'icon': Icons.grid_on},
    {'name': 'Manual Entry', 'icon': Icons.keyboard},
    {'name': 'API Import', 'icon': Icons.api},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text('Create New Dataset', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dataset Details', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Dataset Name',
                hintText: 'e.g., Nov 2026 Examination',
                filled: true,
                fillColor: context.colors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            Text('Dataset Type', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            RadioGroup<String>(
              groupValue: _selectedType,
              onChanged: (val) => setState(() => _selectedType = val!),
              child: Column(
                children: _types.map((t) => RadioListTile<String>(
                  value: t['name']!,
                  title: Text(t['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
                  subtitle: Text(t['desc']!, style: TextStyle(color: context.colors.inkMuted)),
                  activeColor: context.colors.primary,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),
            Text('Data Input Method', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _methods.map((m) {
                final isSelected = _inputMethod == m['name'];
                return InkWell(
                  onTap: () => setState(() => _inputMethod = m['name'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primary.withValues(alpha: 0.1) : context.colors.surface,
                      border: Border.all(color: isSelected ? context.colors.primary : context.colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m['icon'] as IconData, color: isSelected ? context.colors.primary : context.colors.inkMuted),
                        const SizedBox(width: 8),
                        Text(m['name'] as String, style: TextStyle(color: isSelected ? context.colors.primary : context.colors.ink, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameCtrl.text.isEmpty) return;
                  if (_inputMethod == 'CSV Upload') {
                    context.push('/admin/dataset/csv-upload', extra: _nameCtrl.text);
                  } else {
                    // Implement other methods later
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Method coming soon!')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Next Step', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
