import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/domain_model.dart';
import '../models/govt_model.dart';

class GovtDetailScreen extends StatelessWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const GovtDetailScreen({super.key, required this.domain, required this.subcategory});

  // MOCK DATA for MVP based on Sarkari Result structure
  GovtExamDetails _getMockData() {
    return GovtExamDetails(
      title: '${subcategory.name} - Official Notification & Results',
      postUpdateDate: '01 June 2026 | 11:45 AM',
      shortInfo: 'Beta SoftNet Commission has released the official results and cutoff marks for the ${subcategory.name} examination. Candidates who appeared for the exam can download their results and check further eligibility requirements below.',
      importantDates: {
        'Application Begin': '15/02/2026',
        'Last Date for Apply': '15/03/2026',
        'Exam Date': '20/05/2026',
        'Result Available': '01/06/2026',
      },
      applicationFee: {
        'General / OBC / EWS': '₹500/-',
        'SC / ST / PH': '₹0/-',
        'All Category Female': '₹0/-',
      },
      vacancies: [
        VacancyModel(
          postName: 'Sub Inspector (SI)',
          totalPost: '1,450',
          eligibility: 'Bachelor Degree in Any Stream from a Recognized University. Minimum Age: 21 Years.',
        ),
        VacancyModel(
          postName: 'Constable',
          totalPost: '8,200',
          eligibility: '10+2 Intermediate Exam Passed from Any Recognized Board in India. Minimum Age: 18 Years.',
        ),
      ],
      importantLinks: {
        'Download Result': 'https://example.com/result',
        'Download Cutoff Marks': 'https://example.com/cutoff',
        'Download Official Notification': 'https://example.com/notification',
        'Official Website': 'https://example.com/official',
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _getMockData();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('EXAM DETAILS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(domain.icon, size: 40, color: const Color(0xFF0F172A)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          details.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Post Updated: ${details.postUpdateDate}',
                      style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Short Information:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(details.shortInfo, style: const TextStyle(color: Color(0xFF334155), fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dates & Fees Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoCard('Important Dates', details.importantDates, Icons.calendar_month, const Color(0xFFFF5722))),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard('Application Fee', details.applicationFee, Icons.account_balance_wallet, const Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 16),

            // Vacancy Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.work, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Vacancy Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 12),
                      dataTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 12),
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      columns: const [
                        DataColumn(label: Text('POST NAME')),
                        DataColumn(label: Text('TOTAL POST')),
                        DataColumn(label: Text('ELIGIBILITY CRITERIA')),
                      ],
                      rows: details.vacancies.map((v) {
                        return DataRow(cells: [
                          DataCell(Text(v.postName, style: const TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.w900))),
                          DataCell(Text(v.totalPost)),
                          DataCell(
                            SizedBox(
                              width: 250,
                              child: Text(v.eligibility, maxLines: 3, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Important Links
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5), // Indigo
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.link, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Important Links', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: details.importantLinks.entries.map((entry) {
                        final isPrimary = entry.key.toLowerCase().contains('result') || entry.key.toLowerCase().contains('apply');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ElevatedButton(
                            onPressed: () => _launchURL(entry.value),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPrimary ? const Color(0xFFFF5722) : const Color(0xFFF8F9FA),
                              foregroundColor: isPrimary ? Colors.white : const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: isPrimary ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(entry.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, String> data, IconData icon, Color headerColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: headerColor),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(color: headerColor, fontWeight: FontWeight.w900, fontSize: 12))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(entry.value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w900)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
