import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/result_model.dart';
import '../models/domain_model.dart';
import '../services/api_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultDetailScreen extends ConsumerWidget {
  final ResultDomain domain;
  final Map<String, String> credentials;
  final String? examName;
  final ScreenshotController _screenshotController = ScreenshotController();

  ResultDetailScreen({super.key, required this.domain, required this.credentials, this.examName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We'll just pass the first credential for MVP as rollNumber
    final rollNumber = credentials.values.isNotEmpty ? credentials.values.first : 'UNKNOWN';
    final resultAsyncValue = ref.watch(resultProvider(rollNumber));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('OFFICIAL TRANSCRIPT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF0F172A)),
            onPressed: () {},
          )
        ],
      ),
      body: resultAsyncValue.when(
        data: (result) => _buildResultView(context, result),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Could not fetch results.\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(resultProvider(rollNumber)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, ResultModel result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Institution Header
            Row(
              children: [
                Icon(domain.icon, size: 50, color: const Color(0xFF0F172A)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(domain.name.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      if (examName != null)
                        Text(examName!.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                      const SizedBox(height: 4),
                      const Text('STATEMENT OF MARKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
            
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

            // Student Details Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Name', result.studentName),
                      const SizedBox(height: 8),
                      _buildDetailRow('Roll No', result.rollNumber),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Course', result.courseName),
                      const SizedBox(height: 8),
                      _buildDetailRow('Semester', result.semester),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Transcript Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 12),
                  dataTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 12),
                  columnSpacing: 20,
                  horizontalMargin: 12,
                  columns: const [
                    DataColumn(label: Text('CODE')),
                    DataColumn(label: Text('SUBJECT')),
                    DataColumn(label: Text('INT'), tooltip: 'Internal Marks'),
                    DataColumn(label: Text('EXT'), tooltip: 'External Marks'),
                    DataColumn(label: Text('TOT'), tooltip: 'Total Marks'),
                    DataColumn(label: Text('GRD'), tooltip: 'Grade'),
                    DataColumn(label: Text('CR'), tooltip: 'Credits'),
                  ],
                  rows: result.subjects.map((sub) {
                    return DataRow(cells: [
                      DataCell(Text(sub.subjectCode)),
                      DataCell(Text(sub.name)),
                      DataCell(Text(sub.internalMarks.toString())),
                      DataCell(Text(sub.externalMarks.toString())),
                      DataCell(Text(sub.marksObtained.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(sub.grade, style: const TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold))),
                      DataCell(Text(sub.credits.toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FINAL RESULT', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(
                        result.status.toUpperCase(),
                        style: TextStyle(color: result.status.toLowerCase() == 'pass' ? const Color(0xFF10B981) : Colors.red, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('CGPA', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(
                        result.cgpa.toStringAsFixed(2),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Authenticity
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2, size: 64, color: Color(0xFF0F172A)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                          SizedBox(width: 4),
                          Text('DIGITALLY VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Generated via Beta SoftNet Universal Portal', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            OutlinedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating Document...'), duration: Duration(seconds: 1)),
                );
                final image = await _screenshotController.capture();
                if (image != null) {
                  // ignore: deprecated_member_use
                  await Share.shareXFiles(
                    [XFile.fromData(image, mimeType: 'image/png', name: 'marksheet.png')],
                    text: 'My Official Transcript',
                  );
                }
              },
              icon: const Icon(Icons.download, color: Color(0xFF0F172A)),
              label: const Text('DOWNLOAD & SHARE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF0F172A), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
