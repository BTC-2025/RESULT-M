import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SearchKeysMappingScreen extends StatefulWidget {
  final List<String> headers;
  const SearchKeysMappingScreen({super.key, required this.headers});

  @override
  State<SearchKeysMappingScreen> createState() => _SearchKeysMappingScreenState();
}

class _SearchKeysMappingScreenState extends State<SearchKeysMappingScreen> {
  final Set<String> _selectedSearchKeys = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text('Map Search Fields', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Define Search Inputs', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Select which columns the user must input to fetch a record (e.g. Register Number and Date of Birth). This makes the dataset searchable without hardcoding database tables.', style: TextStyle(color: context.colors.inkMuted)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: context.colors.primary),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Only select unique identifiers as search keys to ensure correct result fetching.', style: TextStyle(color: context.colors.ink))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: widget.headers.length,
                itemBuilder: (context, index) {
                  final header = widget.headers[index];
                  final isSelected = _selectedSearchKeys.contains(header);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? context.colors.primary : context.colors.border, width: isSelected ? 2 : 1),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedSearchKeys.add(header);
                          } else {
                            _selectedSearchKeys.remove(header);
                          }
                        });
                      },
                      title: Text(header, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
                      activeColor: context.colors.primary,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSearchKeys.isEmpty ? null : () {
                  // Final submission logic
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: context.colors.surface,
                      title: Text('Dataset Published!', style: TextStyle(color: context.colors.ink)),
                      content: Text('Your dataset has been successfully processed and published to your workspace.', style: TextStyle(color: context.colors.inkMuted)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(c); // close dialog
                            context.go('/admin/dashboard'); // back to dashboard
                          },
                          child: Text('Go to Dashboard', style: TextStyle(color: context.colors.primary)),
                        )
                      ],
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Publish Dataset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
