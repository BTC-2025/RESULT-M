import 'package:flutter/material.dart';

class AcademicResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const AcademicResultScreen({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    // Extract Student Info
    final studentName = data['student_name'] ?? data['Title'] ?? 'Mohammed Faiz';
    final regNo = data['register_number'] ?? data['ID'] ?? '22BCS105';
    final course = data['course'] ?? data['department'] ?? 'B.Sc Computer Science';
    final college = data['college'] ?? 'Mazharul Uloom College';
    final semester = data['semester'] ?? 'IV';

    // Extract Status & CGPA
    final status = data['status'] ?? data['result'] ?? 'PASS';
    final isPass = status.toString().toUpperCase() == 'PASS';
    final cgpa = data['cgpa'] ?? data['overall_gpa'] ?? '8.45';

    // Extract Subjects
    final List<dynamic> subjects = data['subjects'] is List
        ? data['subjects']
        : [
            {'code': 'CS401', 'name': 'Java Programming', 'credits': '4', 'grade': 'A', 'result': 'Pass'},
            {'code': 'CS402', 'name': 'DBMS', 'credits': '4', 'grade': 'A+', 'result': 'Pass'},
            {'code': 'CS403', 'name': 'Computer Networks', 'credits': '4', 'grade': 'B+', 'result': 'Pass'},
            {'code': 'CS404', 'name': 'Lab', 'credits': '2', 'grade': 'O', 'result': 'Pass'},
          ];

    // Extract Stats
    final totalMarks = data['total_marks'] ?? '465/600';
    final percentage = data['percentage'] ?? '77.5%';
    final sgpa = data['sgpa'] ?? '8.4';
    final resultClass = data['class'] ?? 'First Class';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Card Header
            _buildStudentCard(studentName, regNo, course, college, semester, isPass, status.toString(), cgpa.toString()),
            
            const SizedBox(height: 24),
            
            // Subjects Table
            const Text('Subjects & Grades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildSubjectsTable(subjects),
            
            const SizedBox(height: 24),
            
            // Statistics & Overall
            const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildStatisticsSection(totalMarks, percentage, sgpa, cgpa, resultClass),
            
            const SizedBox(height: 32),
            
            // Actions
            const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildActionsRow(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(String name, String regNo, String course, String college, String sem, bool isPass, String status, String cgpa) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Card', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(name.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          
          _buildInfoRow('Register No', regNo),
          const SizedBox(height: 8),
          _buildInfoRow('Course', course),
          const SizedBox(height: 8),
          _buildInfoRow('College', college),
          const SizedBox(height: 8),
          _buildInfoRow('Semester', sem),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isPass ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isPass ? Colors.green.shade200 : Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Text('Status:', style: TextStyle(color: isPass ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('$status ${isPass ? '✅' : '❌'}', style: TextStyle(color: isPass ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Text('CGPA:', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(cgpa, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14))),
        const Text(':', style: TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14))),
      ],
    );
  }

  Widget _buildSubjectsTable(List<dynamic> subjects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
          columnSpacing: 24,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 48,
          columns: const [
            DataColumn(label: Text('Subject Code', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
            DataColumn(label: Text('Subject Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
            DataColumn(label: Text('Credits/Marks', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
            DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
            DataColumn(label: Text('Result', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
          ],
          rows: subjects.map((sub) {
            return DataRow(cells: [
              DataCell(Text(sub['code']?.toString() ?? '-')),
              DataCell(Text(sub['name']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(sub['credits']?.toString() ?? '-')),
              DataCell(_buildGradeText(sub['grade']?.toString() ?? '-')),
              DataCell(Text(sub['result']?.toString() ?? '-', style: TextStyle(color: sub['result'].toString().toLowerCase() == 'pass' ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGradeText(String grade) {
    Color c = Colors.black87;
    if (grade == 'O' || grade == 'A+' || grade == 'A') c = Colors.green.shade700;
    if (grade == 'B+' || grade == 'B') c = Colors.orange.shade700;
    if (grade == 'U' || grade == 'F') c = Colors.red.shade700;
    return Text(grade, style: TextStyle(color: c, fontWeight: FontWeight.w900));
  }

  Widget _buildStatisticsSection(String totalMarks, String percentage, String sgpa, String cgpa, String resultClass) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildInfoRow('Total Marks', totalMarks),
          const SizedBox(height: 12),
          _buildInfoRow('Percentage', percentage),
          const SizedBox(height: 12),
          _buildInfoRow('SGPA', sgpa),
          const SizedBox(height: 12),
          _buildInfoRow('CGPA', cgpa),
          const SizedBox(height: 12),
          _buildInfoRow('Class', resultClass),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(Icons.download, 'Download PDF', Colors.blue),
        _buildActionButton(Icons.print, 'Print Result', Colors.blueGrey),
        _buildActionButton(Icons.share, 'Share Result', Colors.orange),
        _buildActionButton(Icons.security, 'Verify Authenticity', Colors.green),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.shade700, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
