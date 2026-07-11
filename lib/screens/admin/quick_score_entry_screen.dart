import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class QuickScoreEntryScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String datasetId;
  final String recordId;

  const QuickScoreEntryScreen({
    super.key,
    required this.workspaceId,
    required this.datasetId,
    required this.recordId,
  });

  @override
  ConsumerState<QuickScoreEntryScreen> createState() =>
      _QuickScoreEntryScreenState();
}

class _QuickScoreEntryScreenState extends ConsumerState<QuickScoreEntryScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  Map<String, dynamic>? _originalRecord;
  int _currentVersion = 0;

  // We split data into editable numeric fields and read-only text fields
  final Map<String, dynamic> _numericFields = {};
  final Map<String, dynamic> _textFields = {};
  final List<String> _attachedVoteBoxIds = [];

  // Track if we have unsaved changes
  bool _hasUnsavedChanges = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
    _startAutoSaveTimer();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_hasUnsavedChanges && !_isSaving && _originalRecord != null) {
        _saveScore(isAutoSave: true);
      }
    });
  }

  Future<void> _fetchRecord() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final record = await ref
          .read(apiServiceProvider)
          .getDatasetRecord(widget.recordId);
      _initializeData(record);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _initializeData(Map<String, dynamic> record) {
    _numericFields.clear();
    _textFields.clear();
    _attachedVoteBoxIds.clear();

    _originalRecord = record;
    _currentVersion = record['version'] as int? ?? 0;

    final data = record['data'] as Map<String, dynamic>? ?? {};
    _attachedVoteBoxIds.addAll(_extractVoteBoxIds(data));

    data.forEach((key, value) {
      if (_isVoteBoxField(key)) return;

      // Try to parse as double or int
      if (value is int || value is double) {
        _numericFields[key] = value;
      } else if (value is String && double.tryParse(value) != null) {
        // Only treat as numeric if we actually want to edit it. In some cases Strings shouldn't be edited like numbers.
        // But for scores, let's allow it if it parses cleanly without being a weird format.
        _numericFields[key] = double.tryParse(value) ?? 0;
      } else {
        _textFields[key] = value;
      }
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = false;
      });
    }
  }

  bool _isVoteBoxField(String key) {
    return key == 'voteBoxId' ||
        key == 'voteBoxIds' ||
        key == 'pollId' ||
        key == 'pollIds';
  }

  List<String> _extractVoteBoxIds(Map<String, dynamic> data) {
    final raw =
        data['voteBoxIds'] ??
        data['voteBoxId'] ??
        data['pollIds'] ??
        data['pollId'];
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    }
    final value = raw.toString().trim();
    return value.isEmpty ? [] : [value];
  }

  void _incrementValue(String key, num amount) {
    setState(() {
      num current = _numericFields[key] ?? 0;
      _numericFields[key] = current + amount;
      _hasUnsavedChanges = true;
    });
  }

  void _setValue(String key, String val) {
    num? parsed = num.tryParse(val);
    if (parsed != null) {
      setState(() {
        _numericFields[key] = parsed;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveScore({bool isAutoSave = false}) async {
    if (!mounted || _isSaving) return;

    setState(() {
      if (!isAutoSave) _isSaving = true;
    });

    try {
      final updatedData = Map<String, dynamic>.from(_numericFields);
      // We only send numeric fields; backend will merge into JSONB

      final updatedRecord = await ref
          .read(apiServiceProvider)
          .updateDatasetRecord(
            widget.datasetId,
            widget.recordId,
            updatedData,
            _currentVersion,
          );

      _initializeData(
        updatedRecord,
      ); // Resets _hasUnsavedChanges and updates version

      if (!isAutoSave && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (e.toString().contains('Conflict')) {
        if (mounted) {
          _showConflictDialog();
        }
      } else if (!isAutoSave && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _attachVoteBox(String voteBoxId) async {
    final cleanId = voteBoxId.trim();
    if (cleanId.isEmpty || _attachedVoteBoxIds.contains(cleanId)) return;
    await _saveRecordData({
      'voteBoxIds': [..._attachedVoteBoxIds, cleanId],
    });
  }

  Future<void> _removeVoteBox(String voteBoxId) async {
    final updatedIds = _attachedVoteBoxIds
        .where((attachedId) => attachedId != voteBoxId)
        .toList();
    await _saveRecordData({'voteBoxIds': updatedIds});
  }

  Future<void> _saveRecordData(Map<String, dynamic> data) async {
    if (!mounted || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updatedRecord = await ref
          .read(apiServiceProvider)
          .updateDatasetRecord(
            widget.datasetId,
            widget.recordId,
            data,
            _currentVersion,
          );
      _initializeData(updatedRecord);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record poll links updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (e.toString().contains('Conflict')) {
        if (mounted) _showConflictDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to update poll links: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showAttachVoteBoxDialog() async {
    final controller = TextEditingController();
    final voteBoxId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Attach Poll',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Vote Box ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, controller.text),
            icon: const Icon(Icons.link),
            label: const Text('Attach'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (voteBoxId != null) {
      await _attachVoteBox(voteBoxId);
    }
  }

  void _showConflictDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Conflict Detected',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Score was updated by someone else. Reload?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _fetchRecord(); // Reload fresh data
              },
              child: const Text(
                'Reload',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatKey(String key) {
    // Basic title case formatter
    return key
        .replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ')
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'QUICK UPDATE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasUnsavedChanges)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Unsaved',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _isLoading || _error != null
          ? null
          : _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchRecord,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _originalRecord?['recordTitle'] ?? 'Record Data',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ..._textFields.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatKey(e.key)}: ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${e.value}',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildVoteBoxAttachmentPanel(),
        const SizedBox(height: 32),
        const Text(
          'EDIT SCORES',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        if (_numericFields.isEmpty)
          const Text(
            'No numeric fields available to edit.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ..._numericFields.entries.map((e) => _buildNumericRow(e.key, e.value)),
      ],
    );
  }

  Widget _buildVoteBoxAttachmentPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'EMBEDDED POLLS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Attach poll',
                onPressed: _isSaving ? null : _showAttachVoteBoxDialog,
                icon: const Icon(Icons.add_link),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_attachedVoteBoxIds.isEmpty)
            const Text(
              'No polls attached to this record.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _attachedVoteBoxIds
                  .map(
                    (id) => InputChip(
                      avatar: const Icon(Icons.how_to_vote, size: 16),
                      label: Text(id),
                      onDeleted: _isSaving ? null : () => _removeVoteBox(id),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNumericRow(String key, num value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatKey(key),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildControlButton(
                Icons.remove,
                () => _incrementValue(key, -1),
                onLongPress: () => _incrementValue(key, -10),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: TextEditingController(text: value.toString())
                      ..selection = TextSelection.collapsed(
                        offset: value.toString().length,
                      ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => _setValue(key, val),
                  ),
                ),
              ),
              _buildControlButton(
                Icons.add,
                () => _incrementValue(key, 1),
                onLongPress: () => _incrementValue(key, 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onTap, {
    VoidCallback? onLongPress,
  }) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56, // Large touch target
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFF0F172A), size: 28),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            minimumSize: const Size(double.infinity, 56), // Large touch target
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: _isSaving ? null : () => _saveScore(isAutoSave: false),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Update Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
