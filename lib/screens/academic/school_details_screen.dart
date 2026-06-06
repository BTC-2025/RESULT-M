import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../dataset_search_screen.dart';

class SchoolDetailsScreen extends StatefulWidget {
  final String boardName;
  final String examination;

  const SchoolDetailsScreen({
    super.key,
    required this.boardName,
    required this.examination,
  });

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen> {
  String _year = '2026';
  String _month = 'March';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text('Select Academic Details', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.teal.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Board', style: TextStyle(color: context.colors.teal, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(widget.boardName, style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Examination', style: TextStyle(color: context.colors.teal, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(widget.examination, style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text('Examination Session', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _buildDropdown('Academic Year', _year, ['2026', '2025', '2024', '2023'], (v) => setState(() => _year = v!)),
              const SizedBox(height: 16),
              
              _buildDropdown('Month', _month, ['March', 'April', 'May', 'June', 'September', 'October'], (v) => setState(() => _month = v!)),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Navigate to verification screen (DatasetSearchScreen handles this generically)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DatasetSearchScreen(
                          datasetId: 'school_results',
                          datasetName: '${widget.boardName} ${widget.examination}',
                          domainType: 'SCHOOL',
                        ),
                      ),
                    );
                  },
                  child: const Text('Proceed to Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: context.colors.surface,
              style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w500),
              icon: Icon(Icons.keyboard_arrow_down, color: context.colors.inkMuted),
              items: options.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
