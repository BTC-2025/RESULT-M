import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/domain_model.dart';
import '../providers/live_dataset_notifier.dart';
import '../services/api_service.dart';
import '../core/storage/secure_storage.dart';
import '../widgets/record_card_factory.dart';
import '../core/theme/app_theme.dart';
import 'admin/quick_score_entry_screen.dart';

class LocalWorkspaceScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String workspaceName;
  final ResultDomain? domain;
  final Subcategory? subcategory;

  const LocalWorkspaceScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
    this.domain,
    this.subcategory,
  });

  @override
  ConsumerState<LocalWorkspaceScreen> createState() => _LocalWorkspaceScreenState();
}

class _LocalWorkspaceScreenState extends ConsumerState<LocalWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _workspace;
  List<dynamic> _datasets = [];
  String? _selectedDatasetId;
  String? _currentWorkspaceRole;

  bool get _hasDataset => _selectedDatasetId != null;

  bool get _isBackendWorkspace {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(widget.workspaceId);
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _loadWorkspace();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkspace() async {
    if (!_isBackendWorkspace) {
      setState(() {
        _isLoading = false;
        _error = 'This listing is a category placeholder. Create or open a real workspace to view live records.';
      });
      return;
    }

    try {
      final api = ref.read(apiServiceProvider);
      final workspace = await api.fetchWorkspace(widget.workspaceId);
      final datasets = await api.fetchDatasets(widget.workspaceId);
      final role = await _loadCurrentUserRole(api);
      if (!mounted) return;
      setState(() {
        _workspace = workspace;
        _datasets = datasets;
        _selectedDatasetId = datasets.isNotEmpty ? datasets.first['id'].toString() : null;
        _currentWorkspaceRole = role;
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

  Future<String?> _loadCurrentUserRole(ApiService api) async {
    final userId = await SecureStorage().getUserId();
    if (userId == null || userId.isEmpty) return null;

    try {
      final members = await api.fetchWorkspaceMembers(widget.workspaceId);
      for (final member in members) {
        if (member is Map<String, dynamic> && member['userId']?.toString() == userId) {
          return member['role']?.toString();
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  bool get _canEditRecords {
    return _currentWorkspaceRole == 'OWNER' ||
        _currentWorkspaceRole == 'ADMIN' ||
        _currentWorkspaceRole == 'EDITOR';
  }

  Color _getDomainColor() {
    final ds = _selectedDatasetId != null 
        ? _datasets.firstWhere((d) => d['id'].toString() == _selectedDatasetId, orElse: () => null) 
        : null;
    final domainName = ds?['domainType']?.toString().toUpperCase() ?? '';
    
    switch (domainName) {
      case 'SPORTS': return const Color(0xFF10B981);
      case 'FINANCE': return const Color(0xFFF59E0B);
      case 'POLITICS': return const Color(0xFF3B82F6);
      case 'ENTERTAINMENT': return const Color(0xFFEC4899);
      case 'LAW': return const Color(0xFF14B8A6);
      default: return const Color(0xFF8B5CF6);
    }
  }

  void _showQuickUpdateBottomSheet(List<dynamic> records) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Record to Update', style: TextStyle(
                color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              const SizedBox(height: 16),
              if (records.isEmpty)
                Text('No records available in this dataset.', style: TextStyle(color: context.colors.inkMuted))
              else
                ...records.take(20).map((record) {
                  final title = record['recordTitle']?.toString() ?? record['recordKey']?.toString() ?? 'Record';
                  return ListTile(
                    leading: Icon(Icons.edit_rounded, color: _getDomainColor()),
                    title: Text(title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuickScoreEntryScreen(
                            workspaceId: widget.workspaceId,
                            datasetId: _selectedDatasetId!,
                            recordId: record['id'].toString(),
                          ),
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.orange))
          : _error != null
          ? _buildMessage(_error!)
          : _buildWorkspaceContent(),
    );
  }

  Widget _buildWorkspaceContent() {
    if (_datasets.isEmpty) {
      return _buildMessage('No datasets have been published in this workspace yet.');
    }

    final liveState = ref.watch(liveDatasetProvider('$_selectedDatasetId|${widget.workspaceId}'));
    final domainColor = _getDomainColor();
    final titleName = _workspace?['name']?.toString() ?? widget.subcategory?.name ?? widget.workspaceName;
    final description = _workspace?['description']?.toString() ?? 'Workspace Data Hub';

    return liveState.when(
      data: (records) => Scaffold(
        backgroundColor: context.colors.bg,
        body: CustomScrollView(
          slivers: [
            // ─── Hero Header ───────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: domainColor,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (_hasDataset)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => ref.read(liveDatasetProvider('$_selectedDatasetId|${widget.workspaceId}').notifier).refresh(),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [domainColor, domainColor.withValues(alpha: 0.6)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadii.full),
                                ),
                                child: const Text('WORKSPACE', style: TextStyle(
                                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                                )),
                              ),
                              const Spacer(),
                              FadeTransition(
                                opacity: _pulseController,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(AppRadii.full),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.circle, color: Color(0xFFEF4444), size: 8),
                                      SizedBox(width: 4),
                                      Text('LIVE', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(titleName, style: const TextStyle(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1,
                          )),
                          const SizedBox(height: 8),
                          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8), fontSize: 14,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Content ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dataset Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDatasetId,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.inkMuted),
                          dropdownColor: context.colors.surface,
                          style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w700),
                          items: _datasets.map((dataset) {
                            return DropdownMenuItem(
                              value: dataset['id'].toString(),
                              child: Text(dataset['name']?.toString() ?? 'Dataset'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedDatasetId = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Button
                    if (_selectedDatasetId != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final ds = _datasets.firstWhere((d) => d['id'].toString() == _selectedDatasetId);
                            context.push('/dataset/$_selectedDatasetId/search?name=${Uri.encodeComponent(ds['name']?.toString() ?? 'Dataset')}&domainType=${Uri.encodeComponent(ds['domainType']?.toString() ?? '')}');
                          },
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('SEARCH RECORDS / CHECK RESULT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: domainColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                            elevation: 8,
                            shadowColor: domainColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    Text('LIVE RECORDS', style: TextStyle(
                      color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 12),

                    if (records.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_rounded, size: 48, color: context.colors.borderBold),
                            const SizedBox(height: 16),
                            Text('No records found', style: TextStyle(color: context.colors.inkMuted, fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )
                    else
                      ...records.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecordCard(entry.key + 1, entry.value),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: records.isEmpty || !_canEditRecords
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showQuickUpdateBottomSheet(records),
                backgroundColor: context.colors.surfaceAlt,
                icon: const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B)),
                label: Text('Quick Update', style: TextStyle(
                  color: context.colors.ink, fontWeight: FontWeight.w900,
                )),
              ),
      ),
      loading: () => Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(child: CircularProgressIndicator(color: domainColor)),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: context.colors.bg,
        body: _buildMessage('Failed to load records: $err'),
      ),
    );
  }

  Widget _buildRecordCard(int index, dynamic record) {
    final data = record['data'] as Map<String, dynamic>? ?? {};
    final displayData = <String, dynamic>{
      if (record['recordTitle'] != null) 'title': record['recordTitle'],
      if (record['recordKey'] != null) 'recordKey': record['recordKey'],
      ...data,
    };

    return RecordCardFactory(
      domainType: _selectedDomainType(),
      record: displayData,
    );
  }

  DomainType _selectedDomainType() {
    Map<String, dynamic>? selectedDataset;
    for (final dataset in _datasets) {
      if (dataset is Map<String, dynamic> && dataset['id'].toString() == _selectedDatasetId) {
        selectedDataset = dataset;
        break;
      }
    }

    final domainName = selectedDataset?['domainType']?.toString().toUpperCase();

    switch (domainName) {
      case 'SPORTS': return DomainType.sport;
      case 'FINANCE': return DomainType.finance;
      case 'POLITICS': return DomainType.politics;
      case 'ENTERTAINMENT': return DomainType.entertainment;
      default: return widget.domain?.type ?? DomainType.academic;
    }
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, size: 48, color: context.colors.inkFaint),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(
              color: context.colors.inkMuted, fontSize: 16, height: 1.5,
            )),
          ],
        ),
      ),
    );
  }
}
