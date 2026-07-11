import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class AdminRecordsScreen extends ConsumerStatefulWidget {
  const AdminRecordsScreen({super.key});

  @override
  ConsumerState<AdminRecordsScreen> createState() => _AdminRecordsScreenState();
}

class _AdminRecordsScreenState extends ConsumerState<AdminRecordsScreen> {
  bool _isLoadingWorkspaces = true;
  bool _isLoadingRecords = false;
  String? _error;

  List<dynamic> _datasets = [];
  Map<String, dynamic>? _selectedDataset;
  List<dynamic> _records = [];
  Map<String, dynamic>? _selectedDatasetMeta;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWorkspaces = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final workspaces = await apiService.fetchMyWorkspaces(size: 1);
      
      if (workspaces.isEmpty) {
        throw Exception('No workspace found. Create a workspace in Settings or login first.');
      }
      
      final workspaceId = workspaces.first['id'].toString();
      final datasets = await apiService.fetchDatasets(workspaceId);

      if (!mounted) return;
      setState(() {
        _datasets = datasets;
        _isLoadingWorkspaces = false;
        if (datasets.isNotEmpty) {
          _selectedDataset = datasets.first;
        }
      });

      if (_selectedDataset != null) {
        await _loadDatasetMetaAndRecords();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingWorkspaces = false;
      });
    }
  }

  Future<void> _loadDatasetMetaAndRecords() async {
    if (_selectedDataset == null) return;
    if (!mounted) return;

    setState(() {
      _isLoadingRecords = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final datasetId = _selectedDataset!['id'].toString();

      // Fetch dataset metadata for schema generation
      final meta = await apiService.fetchDatasetMeta(datasetId);
      
      // Fetch records for this dataset
      final records = await apiService.fetchDatasetRecords(
        datasetId,
        query: _searchController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _selectedDatasetMeta = meta;
        _records = records;
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingRecords = false;
      });
    }
  }

  void _onDatasetChanged(Map<String, dynamic>? newDataset) {
    if (newDataset == null) return;
    setState(() {
      _selectedDataset = newDataset;
      _selectedDatasetMeta = null;
      _records = [];
    });
    _loadDatasetMetaAndRecords();
  }

  void _showConflictDialog(BuildContext context, VoidCallback onReload) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colors.border),
          ),
          title: Text(
            'Conflict Detected',
            style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink),
          ),
          content: Text(
            'Someone else has updated this record in the meantime. Would you like to reload the latest version?',
            style: TextStyle(color: context.colors.inkMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.inkMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
              onPressed: () {
                Navigator.pop(ctx);
                onReload();
              },
              child: const Text('Reload', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord(String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('Delete Record', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this record?', style: TextStyle(color: context.colors.inkMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: context.colors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.liveRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteDatasetRecord(recordId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully.')),
      );
      _loadDatasetMetaAndRecords();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _showAddOrEditDialog([Map<String, dynamic>? record]) async {
    if (_selectedDataset == null) return;

    final isEdit = record != null;
    final keyController = TextEditingController(text: isEdit ? (record['recordKey'] ?? '') : '');
    final titleController = TextEditingController(text: isEdit ? (record['recordTitle'] ?? '') : '');
    
    // Parse existing JSON data or start empty
    final Map<String, dynamic> initialData = isEdit ? Map<String, dynamic>.from(record['data'] ?? {}) : {};
    
    // Schema fields derived from metadata
    final List<String> schemaKeys = [];
    if (_selectedDatasetMeta != null) {
      final searchFields = _selectedDatasetMeta!['search_fields'] as List<dynamic>? ?? [];
      for (final sf in searchFields) {
        if (sf['key'] != null) schemaKeys.add(sf['key'].toString());
      }
      final displayFields = _selectedDatasetMeta!['display_fields'] as List<dynamic>? ?? [];
      for (final df in displayFields) {
        schemaKeys.add(df.toString());
      }
    }
    
    // Deduplicate schema keys
    final schemaKeysSet = schemaKeys.toSet().toList();
    
    // Map to hold controllers for schema fields
    final Map<String, TextEditingController> schemaControllers = {};
    for (final sk in schemaKeysSet) {
      schemaControllers[sk] = TextEditingController(text: initialData[sk]?.toString() ?? '');
    }

    // List of custom key-value controllers
    final List<MapEntry<TextEditingController, TextEditingController>> customFields = [];
    initialData.forEach((k, v) {
      if (!schemaKeysSet.contains(k)) {
        customFields.add(MapEntry(
          TextEditingController(text: k),
          TextEditingController(text: v?.toString() ?? ''),
        ));
      }
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (statefulCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colors.border),
              ),
              title: Text(
                isEdit ? 'Edit Record' : 'Add Record',
                style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IDENTIFIERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.inkMuted, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: keyController,
                        style: TextStyle(color: context.colors.ink),
                        decoration: InputDecoration(
                          labelText: 'Record Key (e.g. Roll No / Symbol)',
                          labelStyle: TextStyle(color: context.colors.inkMuted),
                          filled: true,
                          fillColor: context.colors.surfaceAlt,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        style: TextStyle(color: context.colors.ink),
                        decoration: InputDecoration(
                          labelText: 'Record Title (e.g. Candidate Name)',
                          labelStyle: TextStyle(color: context.colors.inkMuted),
                          filled: true,
                          fillColor: context.colors.surfaceAlt,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (schemaControllers.isNotEmpty) ...[
                        Text('SCHEMA FIELDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.inkMuted, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        ...schemaControllers.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextField(
                              controller: e.value,
                              style: TextStyle(color: context.colors.ink),
                              decoration: InputDecoration(
                                labelText: e.key.replaceAll('_', ' ').toUpperCase(),
                                labelStyle: TextStyle(color: context.colors.inkMuted),
                                filled: true,
                                fillColor: context.colors.surfaceAlt,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                      Text('CUSTOM FIELDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.inkMuted, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      ...customFields.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final controllers = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controllers.key,
                                  style: TextStyle(color: context.colors.ink),
                                  decoration: InputDecoration(
                                    hintText: 'Key',
                                    hintStyle: TextStyle(color: context.colors.inkFaint),
                                    filled: true,
                                    fillColor: context.colors.surfaceAlt,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: controllers.value,
                                  style: TextStyle(color: context.colors.ink),
                                  decoration: InputDecoration(
                                    hintText: 'Value',
                                    hintStyle: TextStyle(color: context.colors.inkFaint),
                                    filled: true,
                                    fillColor: context.colors.surfaceAlt,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setDialogState(() {
                                    customFields.removeAt(idx);
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            customFields.add(MapEntry(TextEditingController(), TextEditingController()));
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Field'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Dispose controllers
                    keyController.dispose();
                    titleController.dispose();
                    for (final c in schemaControllers.values) {
                      c.dispose();
                    }
                    for (final entry in customFields) {
                      entry.key.dispose();
                      entry.value.dispose();
                    }
                    Navigator.pop(dialogCtx);
                  },
                  child: Text('Cancel', style: TextStyle(color: context.colors.inkMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  onPressed: () async {
                    final key = keyController.text.trim();
                    final title = titleController.text.trim();
                    if (key.isEmpty || title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Record Key and Title are required.')),
                      );
                      return;
                    }

                    // Package data map
                    final Map<String, dynamic> dataMap = {};
                    schemaControllers.forEach((k, ctrl) {
                      final val = ctrl.text.trim();
                      if (val.isNotEmpty) {
                        dataMap[k] = val;
                      }
                    });

                    for (final entry in customFields) {
                      final k = entry.key.text.trim();
                      final v = entry.value.text.trim();
                      if (k.isNotEmpty && v.isNotEmpty) {
                        dataMap[k] = v;
                      }
                    }

                    try {
                      final apiService = ref.read(apiServiceProvider);
                      if (isEdit) {
                        final recordId = record['id'].toString();
                        final version = (record['version'] as num?)?.toInt() ?? 0;
                        await apiService.updateDatasetRecord(
                          _selectedDataset!['id'].toString(),
                          recordId,
                          dataMap,
                          version,
                        );
                      } else {
                        await apiService.createDatasetRecord(
                          _selectedDataset!['id'].toString(),
                          {
                            'recordKey': key,
                            'recordTitle': title,
                            'data': dataMap,
                          },
                        );
                      }

                      // Close Dialog
                      keyController.dispose();
                      titleController.dispose();
                      for (final c in schemaControllers.values) {
                        c.dispose();
                      }
                      for (final entry in customFields) {
                        entry.key.dispose();
                        entry.value.dispose();
                      }
                      
                      // Check mounted before pop/scaffold
                      if (!mounted || !dialogCtx.mounted) return;
                      Navigator.pop(dialogCtx);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Record updated.' : 'Record added.'),
                          backgroundColor: context.colors.green,
                        ),
                      );
                      _loadDatasetMetaAndRecords();
                    } catch (e) {
                      if (!mounted) return;
                      if (e.toString().contains('Conflict')) {
                        if (!dialogCtx.mounted) return;
                        _showConflictDialog(context, () {
                          // Dismiss the add/edit dialog and reload records
                          keyController.dispose();
                          titleController.dispose();
                          for (final c in schemaControllers.values) {
                            c.dispose();
                          }
                          for (final entry in customFields) {
                            entry.key.dispose();
                            entry.value.dispose();
                          }
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                          _loadDatasetMetaAndRecords();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Operation failed: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingWorkspaces) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _datasets.isEmpty) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: TextStyle(color: context.colors.liveRed), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loadInitialData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_datasets.isEmpty) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppBar(
          title: const Text('MANAGE RECORDS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.ink,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, size: 64, color: context.colors.inkMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'No datasets found',
                style: TextStyle(color: context.colors.inkMuted, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a dataset in the "Datasets" tab first.',
                style: TextStyle(color: context.colors.inkMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: const Text('MANAGE RECORDS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.ink,
        elevation: 0,
        actions: [
          // Dataset Selector Dropdown
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: _selectedDataset,
                dropdownColor: context.colors.surface,
                hint: Text('Select Dataset', style: TextStyle(color: context.colors.inkMuted)),
                style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold),
                items: _datasets.map((ds) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: Map<String, dynamic>.from(ds),
                    child: Text(ds['name'] ?? 'Unnamed'),
                  );
                }).toList(),
                onChanged: _onDatasetChanged,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: 'Search records by key...',
                hintStyle: TextStyle(color: context.colors.inkFaint),
                prefixIcon: Icon(Icons.search, color: context.colors.inkMuted),
                filled: true,
                fillColor: context.colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadDatasetMetaAndRecords();
                  },
                ),
              ),
              onSubmitted: (_) => _loadDatasetMetaAndRecords(),
            ),
          ),
          
          Expanded(child: _buildRecordsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedDataset == null ? null : () => _showAddOrEditDialog(),
        backgroundColor: context.colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_isLoadingRecords) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 48, color: context.colors.inkMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No records found', style: TextStyle(color: context.colors.inkMuted, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Manually insert or upload a CSV first.', style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDatasetMetaAndRecords,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index] as Map<String, dynamic>;
          final data = record['data'] as Map<String, dynamic>? ?? {};

          // Extract up to 3 values as preview tags
          final previews = data.entries
              .where((e) => e.value != null && e.value.toString().isNotEmpty)
              .take(3)
              .map((e) => '${e.key.replaceAll('_', ' ')}: ${e.value}')
              .toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.colors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      record['recordTitle'] ?? 'Unnamed Record',
                      style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'KEY: ${record['recordKey'] ?? 'N/A'}',
                      style: TextStyle(color: context.colors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: previews.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(color: context.colors.inkMuted, fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: context.colors.inkMuted),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddOrEditDialog(record);
                  } else if (value == 'delete') {
                    _deleteRecord(record['id'].toString());
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Record')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
