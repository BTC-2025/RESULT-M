import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/result_cards/domain_cards.dart';

class ResultDetailScreen extends StatefulWidget {
  final String domainName;
  final IconData icon;
  final Map<String, dynamic> recordData;
  final String datasetName;

  const ResultDetailScreen({
    super.key,
    required this.domainName,
    required this.icon,
    required this.recordData,
    required this.datasetName,
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String _formatKey(String key) {
    // Convert camelCase or snake_case to Title Case
    String spaced = key.replaceAll(RegExp(r'(?<=[a-z])[A-Z]'), r' $0').replaceAll('_', ' ');
    if (spaced.isEmpty) return key;
    return spaced.trim().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildDomainCard() {
    final domain = widget.domainName.toUpperCase();
    
    if (domain.contains('ACADEMIC') || domain.contains('EDUCATION') || domain.contains('SCHOOL')) {
      return AcademicResultCard(data: widget.recordData);
    } else if (domain.contains('POLITICS') || domain.contains('ELECTION')) {
      return ElectionResultCard(data: widget.recordData);
    } else if (domain.contains('SPORT') || domain.contains('GAME')) {
      return SportsResultCard(data: widget.recordData);
    } else if (domain.contains('FINANCE') || domain.contains('MARKET') || domain.contains('ECONOM')) {
      return FinanceResultCard(data: widget.recordData);
    } else if (domain.contains('ENTERTAINMENT') || domain.contains('MEDIA') || domain.contains('MOVIE')) {
      return EntertainmentResultCard(data: widget.recordData);
    } else if (domain.contains('TECH') || domain.contains('INNOVATION') || domain.contains('SOFTWARE')) {
      return TechResultCard(data: widget.recordData);
    } else if (domain.contains('LAW') || domain.contains('GOVERNMENT') || domain.contains('JUDIC')) {
      return LawResultCard(data: widget.recordData);
    } else {
      // Fallback
      return Column(
        children: widget.recordData.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatKey(entry.key),
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('OFFICIAL RECORD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Screenshot(
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
                        Icon(widget.icon, size: 50, color: const Color(0xFF0F172A)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.domainName.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                              Text(widget.datasetName.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                              const SizedBox(height: 4),
                              const Text('VERIFIED DATA RECORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                    const SizedBox(height: 16),
                    _buildDomainCard(),
                    
                    const SizedBox(height: 24),
                    
                    const SizedBox(height: 24),

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
                  ],
                ),
              ),
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
                    [XFile.fromData(image, mimeType: 'image/png', name: 'record.png')],
                    text: 'My Official Record',
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
