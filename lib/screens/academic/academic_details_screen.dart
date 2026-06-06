import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../dataset_search_screen.dart';

class AcademicDetailsScreen extends StatefulWidget {
  final String universityName;
  final String examType;

  const AcademicDetailsScreen({
    super.key,
    required this.universityName,
    required this.examType,
  });

  @override
  State<AcademicDetailsScreen> createState() => _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  String _year = '2025-2026';
  String _month = 'April 2026';
  String _course = 'B.Sc';
  String _dept = 'Computer Science';
  String _sem = 'Semester 4';

  final _years = ['2023-2024', '2024-2025', '2025-2026'];
  final _months = ['November 2025', 'April 2026', 'May 2026'];
  final _courses = ['B.Sc', 'B.E', 'B.Tech', 'B.Com', 'B.A'];
  final _depts = ['Computer Science', 'Information Technology', 'Mechanical', 'Civil', 'Commerce'];
  final _sems = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text(widget.examType, style: TextStyle(color: context.colors.ink, fontSize: 16)),
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Details',
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your examination session details.',
              style: TextStyle(
                color: context.colors.inkMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildDropdown('Academic Year', _year, _years, (val) => setState(() => _year = val!)),
            _buildDropdown('Month', _month, _months, (val) => setState(() => _month = val!)),
            _buildDropdown('Course', _course, _courses, (val) => setState(() => _course = val!)),
            _buildDropdown('Department', _dept, _depts, (val) => setState(() => _dept = val!)),
            _buildDropdown('Semester', _sem, _sems, (val) => setState(() => _sem = val!)),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final datasetName = '${widget.universityName} - ${widget.examType} $_month';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DatasetSearchScreen(
                        datasetId: 'univ_hub',
                        datasetName: datasetName,
                        domainType: 'ACADEMIC',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.colors.inkFaint,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
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
                icon: Icon(Icons.keyboard_arrow_down, color: context.colors.inkMuted),
                style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w600),
                onChanged: onChanged,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
