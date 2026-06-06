import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/complaint_model.dart';
import '../../services/api_service.dart';
import '../../widgets/rich_text_content.dart';

class ComplaintModerationScreen extends ConsumerStatefulWidget {
  const ComplaintModerationScreen({super.key});

  @override
  ConsumerState<ComplaintModerationScreen> createState() =>
      _ComplaintModerationScreenState();
}

class _ComplaintModerationScreenState
    extends ConsumerState<ComplaintModerationScreen> {
  static const List<String> _statuses = ['OPEN', 'UNDER_REVIEW', 'RESOLVED'];
  static const List<String> _categories = [
    'All',
    'Infrastructure',
    'Education',
    'Sports',
    'Politics',
    'Other',
  ];

  String _selectedStatus = 'OPEN';
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _error;
  List<ComplaintModel> _complaints = [];
  final Set<String> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.fetchComplaints(
        sort: 'new',
        status: _selectedStatus,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        size: 50,
      );
      if (!mounted) return;
      setState(() {
        _complaints = data.map((item) => ComplaintModel.fromJson(item)).toList()
          ..sort((a, b) => b.flagCount.compareTo(a.flagCount));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(ComplaintModel complaint, String status) async {
    if (complaint.status == status || _updatingIds.contains(complaint.id)) {
      return;
    }

    setState(() => _updatingIds.add(complaint.id));

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateComplaintStatus(complaint.id, status);
      if (!mounted) return;

      setState(() {
        _complaints = _complaints
            .map(
              (item) => item.id == complaint.id
                  ? item.copyWith(status: status)
                  : item,
            )
            .where((item) => item.status == _selectedStatus)
            .toList();
        _updatingIds.remove(complaint.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${_formatStatus(status)}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _updatingIds.remove(complaint.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'COMPLAINTS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: _statuses
                      .map(
                        (status) => ButtonSegment(
                          value: status,
                          label: Text(_formatStatus(status)),
                        ),
                      )
                      .toList(),
                  selected: {_selectedStatus},
                  onSelectionChanged: (selection) {
                    setState(() => _selectedStatus = selection.first);
                    _loadComplaints();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category Queue',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (category) {
                    if (category == null) return;
                    setState(() => _selectedCategory = category);
                    _loadComplaints();
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadComplaints,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_complaints.isEmpty) {
      return Center(
        child: Text(
          'No ${_formatStatus(_selectedStatus).toLowerCase()} complaints.',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          final isUpdating = _updatingIds.contains(complaint.id);
          return _ModerationTile(
            complaint: complaint,
            isUpdating: isUpdating,
            onStatusSelected: (status) => _updateStatus(complaint, status),
          );
        },
      ),
    );
  }

  static String _formatStatus(String status) {
    return status.replaceAll('_', ' ');
  }
}

class _ModerationTile extends StatelessWidget {
  static const List<String> _statuses = ['OPEN', 'UNDER_REVIEW', 'RESOLVED'];

  final ComplaintModel complaint;
  final bool isUpdating;
  final ValueChanged<String> onStatusSelected;

  const _ModerationTile({
    required this.complaint,
    required this.isUpdating,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complaint.category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  avatar: const Icon(Icons.flag, size: 16),
                  label: Text('${complaint.flagCount}'),
                  backgroundColor: complaint.flagCount > 0
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  side: BorderSide(
                    color: complaint.flagCount > 0
                        ? Colors.red.shade100
                        : Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RichTextContent(
              text: complaint.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade800, height: 1.35),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: complaint.status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _statuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.replaceAll('_', ' ')),
                          ),
                        )
                        .toList(),
                    onChanged: isUpdating || complaint.status == 'RESOLVED'
                        ? null
                        : (status) {
                            if (status != null) onStatusSelected(status);
                          },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox.square(
                  dimension: 32,
                  child: isUpdating
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : Icon(
                          complaint.status == 'RESOLVED'
                              ? Icons.check_circle
                              : Icons.admin_panel_settings,
                          color: complaint.status == 'RESOLVED'
                              ? Colors.green
                              : const Color(0xFF0F172A),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
