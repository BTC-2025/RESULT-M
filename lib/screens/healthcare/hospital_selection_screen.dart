import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/domain_theme.dart';
import 'report_type_screen.dart';

class HospitalSelectionScreen extends StatefulWidget {
  const HospitalSelectionScreen({super.key});

  @override
  State<HospitalSelectionScreen> createState() => _HospitalSelectionScreenState();
}

class _HospitalSelectionScreenState extends State<HospitalSelectionScreen> {
  final _searchCtrl = TextEditingController();
  final DomainTheme _theme = DomainThemeFactory.getTheme(WorkspaceCategory.healthcare);

  final List<Map<String, String>> _allHospitals = [
    {'name': 'Apollo Hospitals', 'location': 'Greams Road, Chennai', 'id': 'apollo-chn'},
    {'name': 'AIIMS', 'location': 'New Delhi', 'id': 'aiims-delhi'},
    {'name': 'Fortis Healthcare', 'location': 'Bengaluru', 'id': 'fortis-blr'},
    {'name': 'CMC Vellore', 'location': 'Vellore, Tamil Nadu', 'id': 'cmc-vellore'},
    {'name': 'Max Super Speciality', 'location': 'Saket, New Delhi', 'id': 'max-delhi'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allHospitals;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allHospitals;
      } else {
        _filtered = _allHospitals
            .where((h) => h['name']!.toLowerCase().contains(query.toLowerCase()) || 
                          h['location']!.toLowerCase().contains(query.toLowerCase()))
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
        title: const Text('Select Hospital', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                hintText: '🔍 Search Hospitals & Clinics...',
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
                final hospital = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: _theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.local_hospital, color: _theme.primaryColor),
                  ),
                  title: Text(hospital['name']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                  subtitle: Text(hospital['location']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: context.colors.inkMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportTypeScreen(
                          hospitalId: hospital['id']!,
                          hospitalName: hospital['name']!,
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
