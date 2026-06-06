import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SchoolResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const SchoolResultScreen({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Generate some mock data or extract from real data if available
    final studentName = data['name'] ?? 'P. FAIZUR RAHMAN';
    final rollNo = data['roll_no'] ?? data['ID'] ?? '1234567';
    final dob = data['dob'] ?? '15/08/2008';
    final schoolName = data['school'] ?? 'St. John\'s High School';
    
    final pass = (data['result'] ?? 'PASS').toString().toUpperCase() == 'PASS';
    
    // Mock subject data since it's a structural demo
    final subjects = [
      {'name': 'English Language', 'theory': 78, 'practical': 20, 'total': 98, 'grade': 'A1'},
      {'name': 'Mathematics', 'theory': 75, 'practical': 20, 'total': 95, 'grade': 'A1'},
      {'name': 'Science & Technology', 'theory': 68, 'practical': 20, 'total': 88, 'grade': 'A2'},
      {'name': 'Social Science', 'theory': 72, 'practical': 20, 'total': 92, 'grade': 'A1'},
      {'name': 'Second Language', 'theory': 76, 'practical': 20, 'total': 96, 'grade': 'A1'},
    ];
    
    final totalMarks = subjects.fold<int>(0, (sum, subj) => sum + (subj['total'] as int));
    final maxMarks = subjects.length * 100;
    final percentage = (totalMarks / maxMarks * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text('Official Marksheet', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.ink),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: context.colors.ink),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Marks Card
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.teal.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      border: Border(bottom: BorderSide(color: context.colors.teal.withValues(alpha: 0.2))),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance, color: context.colors.teal, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.teal, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SECONDARY SCHOOL CERTIFICATE',
                          style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  
                  // Student Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(context, 'Candidate Name', studentName),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Roll Number', rollNo),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Date of Birth', dob),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'School', schoolName),
                      ],
                    ),
                  ),

                  // Marks Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: context.colors.surfaceAlt,
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('SUBJECT', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800))),
                        Expanded(child: Text('TH', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800))),
                        Expanded(child: Text('PR', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800))),
                        Expanded(child: Text('TOT', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800))),
                        Expanded(child: Text('GR', textAlign: TextAlign.right, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800))),
                      ],
                    ),
                  ),

                  // Marks Table Body
                  ...subjects.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: context.colors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(s['name'] as String, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w600))),
                        Expanded(child: Text(s['theory'].toString(), textAlign: TextAlign.center, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w500))),
                        Expanded(child: Text(s['practical'].toString(), textAlign: TextAlign.center, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w500))),
                        Expanded(child: Text(s['total'].toString(), textAlign: TextAlign.center, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w800))),
                        Expanded(child: Text(s['grade'] as String, textAlign: TextAlign.right, style: TextStyle(color: context.colors.teal, fontSize: 13, fontWeight: FontWeight.w900))),
                      ],
                    ),
                  )),

                  // Footer Stats
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOTAL MARKS', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('$totalMarks / $maxMarks', style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('PERCENTAGE', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('$percentage%', style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Result Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: pass ? context.colors.green.withValues(alpha: 0.1) : context.colors.liveRed.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Center(
                      child: Text(
                        pass ? 'PASSED ✅' : 'FAILED ❌',
                        style: TextStyle(
                          color: pass ? context.colors.green : context.colors.liveRed,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download, color: context.colors.ink),
                    label: const Text('Download PDF'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: context.colors.teal),
                    onPressed: () {},
                    icon: const Icon(Icons.verified, color: Colors.white),
                    label: const Text('Verify Record'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const Text(':  ', style: TextStyle(color: Colors.grey)),
        Expanded(
          flex: 3,
          child: Text(value, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
