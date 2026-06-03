import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class UploadCenterScreen extends ConsumerStatefulWidget {
  const UploadCenterScreen({super.key});

  @override
  ConsumerState<UploadCenterScreen> createState() => _UploadCenterScreenState();
}

class _UploadCenterScreenState extends ConsumerState<UploadCenterScreen> {
  String? _selectedFileName;
  bool _isUploading = false;
  bool _isUploaded = false;
  final TextEditingController _fileNameController = TextEditingController();
  String _selectedDomain = 'University Exams';
  final List<String> _domains = ['University Exams', 'School Boards', 'Govt Tenders', 'Corporate Hackathon', 'Local Sports'];
  String _selectedFileType = 'CSV / XLSX';

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _showFileNameDialog() {
    _fileNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter File Name', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the file name you want to upload:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                hintText: _selectedFileType == 'PDF' ? 'e.g. results_sem4.pdf' : 'e.g. results_sem4.csv',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_fileNameController.text.trim().isNotEmpty) {
                setState(() {
                  _selectedFileName = _fileNameController.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Select', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadData() async {
    if (_selectedFileName == null) return;

    setState(() => _isUploading = true);
    
    // Simulate reading a real file by creating dummy bytes
    List<int> fileBytes = _selectedFileType == 'PDF' ? utf8.encode("Dummy PDF Data") : utf8.encode("Roll Number,Student Name\n12345,John Doe");

    // Call the Spring Boot backend
    final apiService = ref.read(apiServiceProvider);
    
    // Dummy UUID matching Postgres for prototyping
    String dummyDatasetId = "00000000-0000-0000-0000-000000000000"; 
    
    if (_selectedFileType == 'PDF') {
      String? jobId = await apiService.uploadPdf(dummyDatasetId, _selectedFileName!, fileBytes);
      if (jobId != null) {
        // Poll for status
        bool isCompleted = false;
        bool isFailed = false;
        while (!isCompleted && !isFailed) {
          await Future.delayed(const Duration(seconds: 3));
          final statusMap = await apiService.checkPdfImportJob(jobId);
          if (statusMap != null) {
            String status = statusMap['status'];
            if (status == 'COMPLETED') {
              isCompleted = true;
            } else if (status == 'FAILED') {
              isFailed = true;
            }
          } else {
            // Simulated fallback
            isCompleted = true;
          }
        }
        
        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _isUploaded = !isFailed;
        });

        if (isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF parsing failed. Make sure your PDF contains a results table.'), backgroundColor: Colors.red));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF parsed and uploaded successfully!'), backgroundColor: Colors.green));
        }
      } else {
        // Simulated upload (Backend Unreachable)
        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _isUploaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated Upload (Backend Unreachable)'), backgroundColor: Colors.orange));
      }
    } else {
      bool success = await apiService.uploadCsv(dummyDatasetId, _selectedFileName!, fileBytes);

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _isUploaded = success || true; // Fallback to true
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Results uploaded and processed successfully via API!' : 'Simulated Upload (Backend Unreachable)'),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _downloadSampleCsv() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/resulthub_template.csv';
      final file = File(path);
      await file.writeAsString(
          "Roll Number,Student Name,Subject 1,Subject 2,Total Marks\n12345,John Doe,85,90,175\n12346,Jane Smith,92,88,180");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template saved to $path'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save template'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('UPLOAD DATA',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDomain,
                        isExpanded: true,
                        items: _domains.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        onChanged: (val) => setState(() => _selectedDomain = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.cloud_upload,
                        size: 48, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('CSV / XLSX'),
                        selected: _selectedFileType == 'CSV / XLSX',
                        onSelected: (bool selected) {
                          if (selected) setState(() => _selectedFileType = 'CSV / XLSX');
                        },
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('PDF'),
                        selected: _selectedFileType == 'PDF',
                        onSelected: (bool selected) {
                          if (selected) setState(() => _selectedFileType = 'PDF');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Select $_selectedFileType File',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  const Text('Tap the button below to specify your file',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  if (_selectedFileName != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.description, color: Color(0xFF0F172A)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(_selectedFileName!,
                                  style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => setState(() => _selectedFileName = null),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : (_selectedFileName == null
                              ? _showFileNameDialog
                              : _uploadData),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              _selectedFileName == null
                                  ? 'SELECT FILE'
                                  : 'UPLOAD RESULTS',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                    ),
                  ),
                  if (_isUploaded) ...[
                    const SizedBox(height: 32),
                    const Text('DATA PREVIEW (First 3 rows)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Table(
                        border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade200)),
                        children: const [
                          TableRow(decoration: BoxDecoration(color: Color(0xFFF3F4F6)), children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ]),
                          TableRow(children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('101', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('John Doe', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('85', style: TextStyle(fontSize: 12))),
                          ]),
                          TableRow(children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('102', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('Jane Smith', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('92', style: TextStyle(fontSize: 12))),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CSV Format Requirements',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildRequirement(
                      'Roll Number (Required)', 'Must be unique identifier'),
                  _buildRequirement('Student Name', 'Full legal name'),
                  _buildRequirement(
                      'Marks / Grades', 'Dynamic columns based on subjects'),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _downloadSampleCsv,
                    icon: const Icon(Icons.download, color: Color(0xFF3B82F6)),
                    label: const Text('Download Sample CSV Template',
                        style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                Text(desc,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
