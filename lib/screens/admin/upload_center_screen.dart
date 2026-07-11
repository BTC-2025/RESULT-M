import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/domain_model.dart';
import '../../services/api_service.dart';

class UploadCenterScreen extends ConsumerStatefulWidget {
  const UploadCenterScreen({super.key});

  @override
  ConsumerState<UploadCenterScreen> createState() => _UploadCenterScreenState();
}

class _UploadCenterScreenState extends ConsumerState<UploadCenterScreen> {
  final List<String> _domains = const [
    'University Exams',
    'School Boards',
    'Govt Tenders',
    'Corporate Hackathon',
    'Local Sports',
  ];

  String _selectedDomain = 'University Exams';
  String _selectedFileType = 'CSV';
  String? _selectedWorkspaceId;
  String? _selectedDatasetId;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  List<String> _csvHeaders = [];
  List<Map<String, String>> _csvPreviewRows = [];
  String? _recordKeyColumn;
  String? _csvPreviewError;
  List<dynamic> _workspaces = [];
  List<dynamic> _datasets = [];
  bool _isLoadingTargets = true;
  bool _isUploading = false;
  bool _isUploaded = false;

  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    try {
      final workspaces = await ref.read(apiServiceProvider).fetchMyWorkspaces();
      if (!mounted) return;
      setState(() {
        _workspaces = workspaces;
        _selectedWorkspaceId = workspaces.isNotEmpty
            ? workspaces.first['id'].toString()
            : null;
        _isLoadingTargets = false;
      });
      if (_selectedWorkspaceId != null) {
        await _loadDatasets(_selectedWorkspaceId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTargets = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load workspaces: $e')));
    }
  }

  Future<void> _loadDatasets(String workspaceId) async {
    final datasets = await ref
        .read(apiServiceProvider)
        .fetchDatasets(workspaceId);
    if (!mounted) return;
    setState(() {
      _datasets = datasets;
      _selectedDatasetId = datasets.isNotEmpty
          ? datasets.first['id'].toString()
          : null;
    });
  }

  Future<String> _ensureDataset() async {
    if (_selectedDatasetId != null) return _selectedDatasetId!;
    if (_selectedWorkspaceId == null) {
      throw Exception('Create or select a workspace before uploading.');
    }

    final name = _selectedDomain.trim().isEmpty
        ? 'Uploaded Results'
        : _selectedDomain;
    final slug =
        '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final dataset = await ref
        .read(apiServiceProvider)
        .createDataset(_selectedWorkspaceId!, {
          'name': name,
          'slug': slug,
          'description': 'Uploaded via admin console',
          'domainType': _backendDomainForUploadCategory(_selectedDomain),
        });
    await _loadDatasets(_selectedWorkspaceId!);
    return dataset['id'].toString();
  }

  String _backendDomainForUploadCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('university') || normalized.contains('school')) {
      return backendDomainTypeFor(DomainType.academic)!;
    }
    if (normalized.contains('sport')) {
      return backendDomainTypeFor(DomainType.sport)!;
    }
    if (normalized.contains('hackathon')) {
      return backendDomainTypeFor(DomainType.tech)!;
    }
    return backendDomainTypeFor(DomainType.hyperLocal)!;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _selectedFileType == 'PDF' ? ['pdf'] : ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    List<int>? bytes = picked.bytes;
    if (bytes == null && picked.path != null) {
      bytes = await File(picked.path!).readAsBytes();
    }
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read the selected file')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _selectedFileName = picked.name;
      _selectedFileBytes = bytes;
      _isUploaded = false;
      _csvHeaders = [];
      _csvPreviewRows = [];
      _recordKeyColumn = null;
      _csvPreviewError = null;
    });

    if (_selectedFileType == 'CSV') {
      _buildCsvPreview(bytes);
    }
  }

  Future<void> _uploadData() async {
    if (_selectedFileName == null || _selectedFileBytes == null) return;

    setState(() => _isUploading = true);
    final apiService = ref.read(apiServiceProvider);

    try {
      final datasetId = await _ensureDataset();
      if (_selectedFileType == 'PDF') {
        final jobId = await apiService.uploadPdf(
          datasetId,
          _selectedFileName!,
          _selectedFileBytes!,
        );
        if (jobId == null) {
          throw Exception('PDF upload failed');
        }

        var completed = false;
        var failed = false;
        while (!completed && !failed) {
          await Future.delayed(const Duration(seconds: 3));
          final statusMap = await apiService.checkPdfImportJob(jobId);
          final status = statusMap?['status']?.toString();
          completed = status == 'COMPLETED';
          failed = status == 'FAILED';
        }

        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _isUploaded = completed;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              completed
                  ? 'PDF parsed and uploaded successfully!'
                  : 'PDF parsing failed.',
            ),
            backgroundColor: completed ? Colors.green : Colors.red,
          ),
        );
      } else {
        final success = await apiService.uploadCsv(
          datasetId,
          _selectedFileName!,
          _selectedFileBytes!,
          recordKeyColumn: _recordKeyColumn,
        );
        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _isUploaded = success;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Results uploaded and processed successfully!'
                  : 'Upload failed. Check file format and permissions.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _buildCsvPreview(List<int> bytes) {
    try {
      final csvText = utf8.decode(bytes);
      final lines = const LineSplitter()
          .convert(csvText)
          .where((line) => line.trim().isNotEmpty)
          .toList();
      if (lines.isEmpty) {
        throw Exception('CSV file is empty.');
      }

      final headers = _parseCsvLine(lines.first);
      if (headers.isEmpty) {
        throw Exception('CSV header row is missing.');
      }

      final previewRows = <Map<String, String>>[];
      for (final line in lines.skip(1).take(5)) {
        final values = _parseCsvLine(line);
        final row = <String, String>{};
        for (var i = 0; i < headers.length; i++) {
          row[headers[i]] = i < values.length ? values[i] : '';
        }
        previewRows.add(row);
      }

      setState(() {
        _csvHeaders = headers;
        _csvPreviewRows = previewRows;
        _recordKeyColumn = _suggestRecordKeyColumn(headers);
      });
    } catch (e) {
      setState(() => _csvPreviewError = e.toString());
    }
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      final nextChar = i + 1 < line.length ? line[i + 1] : null;

      if (char == '"' && inQuotes && nextChar == '"') {
        buffer.write('"');
        i++;
      } else if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString().trim());
    return values;
  }

  String? _suggestRecordKeyColumn(List<String> headers) {
    final normalized = {
      for (final header in headers) header.toLowerCase(): header,
    };
    for (final candidate in ['recordkey', 'rollnumber', 'id', 'studentid']) {
      if (normalized.containsKey(candidate)) return normalized[candidate];
    }
    return headers.isNotEmpty ? headers.first : null;
  }

  Future<void> _downloadSampleCsv() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/resulthub_template.csv';
      final file = File(path);
      await file.writeAsString(
        'rollNumber,name,score\n1001,John Doe,95.5\n1002,Jane Smith,88.0',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template saved to $path'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save template'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpload =
        !_isUploading &&
        _selectedWorkspaceId != null &&
        _selectedFileName != null &&
        _selectedFileBytes != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'UPLOAD DATA',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoadingTargets)
                    const LinearProgressIndicator()
                  else if (_workspaces.isEmpty)
                    const Text(
                      'Create a workspace before uploading results.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWorkspaceId,
                      decoration: InputDecoration(
                        labelText: 'Workspace',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _workspaces.map((workspace) {
                        return DropdownMenuItem(
                          value: workspace['id'].toString(),
                          child: Text(
                            workspace['name']?.toString() ?? 'Workspace',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() {
                          _selectedWorkspaceId = value;
                          _selectedDatasetId = null;
                          _datasets = [];
                        });
                        await _loadDatasets(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDatasetId,
                      decoration: InputDecoration(
                        labelText: 'Dataset',
                        hintText: 'A dataset will be created if none exists',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _datasets.map((dataset) {
                        return DropdownMenuItem(
                          value: dataset['id'].toString(),
                          child: Text(dataset['name']?.toString() ?? 'Dataset'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedDatasetId = value),
                    ),
                  ],
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDomain,
                    decoration: InputDecoration(
                      labelText: 'Result Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _domains
                        .map(
                          (domain) => DropdownMenuItem(
                            value: domain,
                            child: Text(domain),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDomain = value!),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'CSV', label: Text('CSV')),
                      ButtonSegment(value: 'PDF', label: Text('PDF')),
                    ],
                    selected: {_selectedFileType},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedFileType = selection.first;
                        _selectedFileName = null;
                        _selectedFileBytes = null;
                        _isUploaded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _selectedFileName ?? 'Select $_selectedFileType File',
                    ),
                  ),
                  if (_selectedFileType == 'CSV' &&
                      (_csvHeaders.isNotEmpty || _csvPreviewError != null)) ...[
                    const SizedBox(height: 16),
                    _buildCsvPreviewPanel(),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: canUpload ? _uploadData : null,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      _isUploading ? 'Uploading...' : 'Upload Results',
                    ),
                  ),
                  if (_isUploaded) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Upload completed. Records are now available in the selected dataset.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CSV Format Requirements',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Include a unique rollNumber/record key and dynamic score columns.',
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _downloadSampleCsv,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Sample CSV Template'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCsvPreviewPanel() {
    if (_csvPreviewError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Text(
          _csvPreviewError!,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CSV PREVIEW',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _recordKeyColumn,
            decoration: const InputDecoration(
              labelText: 'Record Key Column',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _csvHeaders
                .map(
                  (header) =>
                      DropdownMenuItem(value: header, child: Text(header)),
                )
                .toList(),
            onChanged: (value) => setState(() => _recordKeyColumn = value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 44,
              columns: _csvHeaders
                  .take(6)
                  .map((header) => DataColumn(label: Text(header)))
                  .toList(),
              rows: _csvPreviewRows
                  .map(
                    (row) => DataRow(
                      cells: _csvHeaders
                          .take(6)
                          .map(
                            (header) => DataCell(
                              Text(
                                row[header] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
