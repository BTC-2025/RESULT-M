import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';


class AdminDatasetsScreen extends ConsumerStatefulWidget {
  const AdminDatasetsScreen({super.key});

  @override
  ConsumerState<AdminDatasetsScreen> createState() =>
      _AdminDatasetsScreenState();
}

class _AdminDatasetsScreenState extends ConsumerState<AdminDatasetsScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _datasets = [];
  String? _workspaceId;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  Future<void> _loadDatasets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final workspaces = await apiService.fetchMyWorkspaces(size: 1);

      if (workspaces.isEmpty) {
        throw Exception('No workspace found. Please create a workspace first.');
      }

      final workspaceId = workspaces.first['id'].toString();
      final datasets = await apiService.fetchDatasets(workspaceId);

      if (!mounted) return;
      setState(() {
        _workspaceId = workspaceId;
        _datasets = datasets;
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

  // ─── Edit Metadata Dialog ─────────────────────────────────────────────────
  Future<void> _showEditDialog(Map<String, dynamic> dataset) async {
    final nameCtrl =
        TextEditingController(text: dataset['name']?.toString() ?? '');
    final descCtrl =
        TextEditingController(text: dataset['description']?.toString() ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text(
          'Edit Dataset',
          style: TextStyle(
              fontWeight: FontWeight.w900, color: context.colors.ink),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: context.colors.ink),
                decoration: InputDecoration(
                  labelText: 'Dataset Name',
                  labelStyle: TextStyle(color: context.colors.inkMuted),
                  filled: true,
                  fillColor: context.colors.surfaceAlt,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: context.colors.ink),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: context.colors.inkMuted),
                  filled: true,
                  fillColor: context.colors.surfaceAlt,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: context.colors.inkMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateDatasetMetadata(
        dataset['id'].toString(),
        {
          'name': nameCtrl.text.trim(),
          'description': descCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dataset updated successfully.'),
          backgroundColor: context.colors.green,
        ),
      );
      _loadDatasets();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      nameCtrl.dispose();
      descCtrl.dispose();
    }
  }

  // ─── Delete Confirmation ──────────────────────────────────────────────────
  Future<void> _deleteDataset(Map<String, dynamic> dataset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: context.colors.liveRed, size: 22),
            const SizedBox(width: 8),
            Text(
              'Delete Dataset',
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: context.colors.ink),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${dataset['name']}"? '
          'All records inside will be lost.',
          style: TextStyle(color: context.colors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: context.colors.inkMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.liveRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteDataset(dataset['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${dataset['name']}" deleted.'),
          backgroundColor: context.colors.liveRed,
        ),
      );
      _loadDatasets();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  // ─── Manage Search Keys Sheet ─────────────────────────────────────────────
  Future<void> _showManageKeysSheet(Map<String, dynamic> dataset) async {
    final datasetId = dataset['id'].toString();
    final datasetName = dataset['name']?.toString() ?? 'Dataset';

    // Fetch current schema
    Map<String, dynamic>? meta;
    try {
      meta = await ref.read(apiServiceProvider).fetchDatasetMeta(datasetId);
    } catch (_) {}

    if (!mounted) return;

    final List<String> searchKeys = [];
    if (meta != null) {
      final sf = meta['search_fields'] as List<dynamic>? ?? [];
      for (final f in sf) {
        if (f['key'] != null) searchKeys.add(f['key'].toString());
      }
    }
    final newKeyCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (sheetCtx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.vpn_key_rounded,
                        color: context.colors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Search Keys — $datasetName',
                      style: TextStyle(
                          color: context.colors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'These fields are required when users look up a result in this dataset.',
                  style: TextStyle(
                      color: context.colors.inkMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                if (searchKeys.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No search keys configured yet. Add one below.',
                      style: TextStyle(
                          color: context.colors.inkMuted, fontSize: 13),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: searchKeys
                        .map((key) => Chip(
                              label: Text(key,
                                  style: TextStyle(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                              backgroundColor: context.colors.primary
                                  .withValues(alpha: 0.1),
                              side: BorderSide(
                                  color: context.colors.primary
                                      .withValues(alpha: 0.3)),
                              deleteIcon: Icon(Icons.close,
                                  size: 14, color: context.colors.primary),
                              onDeleted: () {
                                setSheetState(() => searchKeys.remove(key));
                              },
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newKeyCtrl,
                        style: TextStyle(color: context.colors.ink),
                        decoration: InputDecoration(
                          hintText: 'Add new key (e.g. register_number)',
                          hintStyle:
                              TextStyle(color: context.colors.inkFaint),
                          filled: true,
                          fillColor: context.colors.surfaceAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: context.colors.border),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final v = newKeyCtrl.text.trim();
                        if (v.isNotEmpty && !searchKeys.contains(v)) {
                          setSheetState(() {
                            searchKeys.add(v);
                            newKeyCtrl.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(apiServiceProvider).updateDatasetMetadata(
                          datasetId,
                          {'searchKeys': searchKeys},
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Search keys saved.'),
                            backgroundColor: context.colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Save failed: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Keys',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
    newKeyCtrl.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: const Text('MANAGE DATASETS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.ink,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.colors.ink),
            onPressed: _loadDatasets,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/dataset/create'),
        backgroundColor: context.colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Dataset',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: context.colors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: context.colors.liveRed),
              const SizedBox(height: 16),
              Text(_error!,
                  style: TextStyle(color: context.colors.liveRed),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadDatasets,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open,
                size: 64,
                color: context.colors.inkMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No datasets found',
                style: TextStyle(
                    color: context.colors.inkMuted,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Create your first dataset to start uploading records.',
                style: TextStyle(color: context.colors.inkMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.colors.primary,
      onRefresh: _loadDatasets,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: _datasets.length,
        itemBuilder: (context, index) {
          final dataset = _datasets[index] as Map<String, dynamic>;
          return _buildDatasetCard(dataset);
        },
      ),
    );
  }

  Widget _buildDatasetCard(Map<String, dynamic> dataset) {
    final domainType = dataset['domainType']?.toString() ?? 'Unknown';
    final status = dataset['status']?.toString() ?? 'DRAFT';
    final isPublished = status == 'PUBLISHED';

    final statusColor =
        isPublished ? context.colors.green : context.colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.dataset_outlined,
                      color: context.colors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dataset['name']?.toString() ?? 'Unnamed Dataset',
                        style: TextStyle(
                            color: context.colors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 17),
                      ),
                      if ((dataset['description']?.toString() ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            dataset['description'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: context.colors.inkMuted, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
                // ── Popup menu ─────────────────────────────────────
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: context.colors.inkMuted),
                  color: context.colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: context.colors.border),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(dataset);
                    } else if (value == 'keys') {
                      _showManageKeysSheet(dataset);
                    } else if (value == 'delete') {
                      _deleteDataset(dataset);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: context.colors.ink),
                          const SizedBox(width: 10),
                          Text('Edit Metadata',
                              style: TextStyle(color: context.colors.ink)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'keys',
                      child: Row(
                        children: [
                          Icon(Icons.vpn_key_outlined,
                              size: 18, color: context.colors.ink),
                          const SizedBox(width: 10),
                          Text('Manage Search Keys',
                              style: TextStyle(color: context.colors.ink)),
                        ],
                      ),
                    ),
                    PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: context.colors.liveRed),
                          const SizedBox(width: 10),
                          Text('Delete',
                              style:
                                  TextStyle(color: context.colors.liveRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Footer chips ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _Chip(
                  label: domainType,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: status,
                  color: statusColor,
                ),
                const Spacer(),
                // Quick access: go to records
                if (_workspaceId != null)
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to records tab (AdminScaffold index 2)
                      Navigator.pop(context); // pop if pushed as standalone
                    },
                    icon: Icon(Icons.table_rows_outlined,
                        size: 14, color: context.colors.blue),
                    label: Text('Records',
                        style: TextStyle(
                            color: context.colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper chip widget ──────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
