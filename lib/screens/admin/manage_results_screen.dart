import 'package:flutter/material.dart';

class ManageResultsScreen extends StatefulWidget {
  const ManageResultsScreen({super.key});

  @override
  State<ManageResultsScreen> createState() => _ManageResultsScreenState();
}

class _ManageResultsScreenState extends State<ManageResultsScreen> {
  final List<Map<String, dynamic>> _liveExams = [
    {'title': 'B.E Semester 4 Results', 'subtitle': '12,450 records', 'isLive': true, 'version': 0},
    {'title': 'B.Tech Semester 6 Results', 'subtitle': '8,120 records', 'isLive': true, 'version': 0},
  ];

  final List<Map<String, dynamic>> _draftExams = [
    {'title': 'M.E Final Semester', 'subtitle': 'Draft - 1,200 records', 'isLive': false, 'version': 0},
    {'title': 'Ph.D Entrance Test', 'subtitle': 'Draft - Pending Approval', 'isLive': false, 'version': 0},
  ];

  // Helper to show the conflict dialog
  void _showConflictDialog(BuildContext context, VoidCallback onReload) {
    showDialog(
      context: context,
      barrierDismissible: false, // non-dismissable dialog
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Conflict Detected', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('Someone else edited this record. Reload the latest version?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Cancel, keeps unsaved changes
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                Navigator.pop(ctx);
                onReload(); // Fetch fresh data and reopen
              },
              child: const Text('Reload', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteExam(bool isLive, int index) {
    setState(() {
      if (isLive) {
        _liveExams.removeAt(index);
      } else {
        _draftExams.removeAt(index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam removed successfully'), backgroundColor: Colors.red));
  }

  void _editExam(bool isLive, int index) {
    final Map<String, dynamic> exam = isLive ? _liveExams[index] : _draftExams[index];
    final titleController = TextEditingController(text: exam['title']);
    final subtitleController = TextEditingController(text: exam['subtitle']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Record', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(
                  labelText: 'Subtitle',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                // Simulate an API PUT request passing the version
                // final currentVersion = exam['version'];
                
                // Simulate a 409 Conflict conditionally (e.g. if title contains "Conflict")
                // In real app: catch DioException -> e.response?.statusCode == 409
                bool is409Conflict = titleController.text.toLowerCase().contains('conflict');

                if (is409Conflict) {
                  _showConflictDialog(context, () {
                    // Reload action: close current editor, simulate fetching fresh data, reopen
                    Navigator.pop(context); // Close editor
                    // Simulate fetching fresh data by incrementing version behind the scenes
                    setState(() {
                      if (isLive) {
                        _liveExams[index]['version'] = (_liveExams[index]['version'] as int) + 1;
                        _liveExams[index]['title'] = 'Fresh Title from Server';
                      } else {
                        _draftExams[index]['version'] = (_draftExams[index]['version'] as int) + 1;
                        _draftExams[index]['title'] = 'Fresh Title from Server';
                      }
                    });
                    _editExam(isLive, index); // Reopen with fresh data
                  });
                  return; // Stop saving, leave editor open so they don't lose work
                }

                setState(() {
                  if (isLive) {
                    _liveExams[index]['title'] = titleController.text;
                    _liveExams[index]['subtitle'] = subtitleController.text;
                    _liveExams[index]['version'] = (_liveExams[index]['version'] as int) + 1;
                  } else {
                    _draftExams[index]['title'] = titleController.text;
                    _draftExams[index]['subtitle'] = subtitleController.text;
                    _draftExams[index]['version'] = (_draftExams[index]['version'] as int) + 1;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully'), backgroundColor: Colors.green));
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('MANAGE RESULTS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('LIVE EXAMS'),
          const SizedBox(height: 16),
          if (_liveExams.isEmpty) const Text('No live exams', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ..._liveExams.asMap().entries.map((e) => _buildExamCard(e.value['title'], e.value['subtitle'], e.value['isLive'], e.key)),
          const SizedBox(height: 32),
          _buildSectionTitle('UPCOMING / DRAFT'),
          const SizedBox(height: 16),
          if (_draftExams.isEmpty) const Text('No draft exams', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ..._draftExams.asMap().entries.map((e) => _buildExamCard(e.value['title'], e.value['subtitle'], e.value['isLive'], e.key)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5));
  }

  Widget _buildExamCard(String title, String subtitle, bool isLive, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(isLive ? Icons.sensors : Icons.edit_document, color: isLive ? const Color(0xFF10B981) : Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteExam(isLive, index);
              } else if (value == 'edit') {
                _editExam(isLive, index);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Data')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
