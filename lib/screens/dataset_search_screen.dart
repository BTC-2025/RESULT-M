import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/models/dataset_meta.dart';
import '../core/providers/dataset_meta_provider.dart';
import '../core/providers/access_state_provider.dart';
import '../services/api_service.dart';
import '../widgets/access_control/password_gate.dart';
import '../widgets/access_control/private_blocked_view.dart';
import 'result_detail_screen.dart';
import 'results/academic_result_screen.dart';
import 'results/election_result_screen.dart';
import 'results/entertainment_result_screen.dart';
import 'results/finance_result_screen.dart';

import 'results/law_result_screen.dart';
import 'results/school_result_screen.dart';
import 'results/business_result_screen.dart';
import 'results/government_result_screen.dart';
import 'results/healthcare_result_screen.dart';
import 'results/hyperlocal_result_screen.dart';
import 'results/tech_result_screen.dart';

import '../core/providers/recently_viewed_provider.dart';

class DatasetSearchScreen extends ConsumerStatefulWidget {
  final String datasetId;
  final String datasetName;
  final String domainType;

  const DatasetSearchScreen({
    super.key,
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
  });

  @override
  ConsumerState<DatasetSearchScreen> createState() => _DatasetSearchScreenState();
}

class _DatasetSearchScreenState extends ConsumerState<DatasetSearchScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  String? _loadingMessage;
  String? _error;

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  IconData _getIconForDomain(String domain) {
    final d = domain.toUpperCase();
    if (d.contains('ACADEMIC') || d.contains('EDU')) return Icons.school_rounded;
    if (d.contains('POLITIC') || d.contains('ELECTION')) return Icons.how_to_vote_rounded;
    if (d.contains('SPORT') || d.contains('GAME')) return Icons.sports_esports_rounded;
    if (d.contains('FINANCE') || d.contains('MARKET')) return Icons.trending_up_rounded;
    if (d.contains('LAW') || d.contains('COURT')) return Icons.gavel_rounded;
    if (d.contains('ENTERTAIN') || d.contains('MOVIE')) return Icons.movie_rounded;
    if (d.contains('HEALTH')) return Icons.local_hospital_rounded;
    return Icons.search_rounded;
  }

  Future<void> _performSearch(DatasetMeta meta) async {
    // Validate required fields
    for (var field in meta.searchFields) {
      if (field.required && (_controllers[field.key]?.text.trim().isEmpty ?? true)) {
        setState(() => _error = 'Please enter your ${field.label}');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _loadingMessage = 'Authenticating Request...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _loadingMessage = 'Fetching Records...');

      final api = ref.read(apiServiceProvider);

      // Map form field keys to the lookup API params (rollNumber / dateOfBirth)
      String? rollNumber;
      String? dateOfBirth;
      for (var field in meta.searchFields) {
        final value = _controllers[field.key]?.text.trim() ?? '';
        final key = field.key.toLowerCase();
        if (key.contains('roll') || key.contains('register') || key.contains('id') || key.contains('application') ||
            key.contains('voter') || key.contains('patient') || key.contains('ticket') || key.contains('case') ||
            key.contains('account') || key.contains('policy') || key.contains('tracking') || key.contains('booking') ||
            key.contains('employee') || key.contains('pan') || key.contains('no') || key.contains('number') ||
            key.contains('athlete') || key.contains('ticker') || key.contains('pass') || key.contains('team') || key.contains('art')) {
          rollNumber = value.isNotEmpty ? value : null;
        } else if (key.contains('dob') || key.contains('birth') || key.contains('date')) {
          dateOfBirth = value.isNotEmpty ? value : null;
        } else if (rollNumber == null && value.isNotEmpty) {
          // fallback: first non-date field treated as rollNumber
          rollNumber = value;
        }
      }

      // Retrieve workspace token if needed
      final accessState = ref.read(accessStateProvider(widget.datasetId));
      final workspaceToken = accessState.isUnlocked ? accessState.accessToken : null;

      final record = await api.lookupRecord(
        widget.datasetId,
        rollNumber: rollNumber,
        dateOfBirth: dateOfBirth,
        workspaceToken: workspaceToken,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });

      // Log successful lookup to Recently Viewed History
      ref.read(recentlyViewedProvider.notifier).addView(
            widget.datasetId,
            widget.datasetName,
            widget.domainType,
          );

      // Build display data from record
      final data = record['data'] as Map<String, dynamic>? ?? {};
      final displayData = <String, dynamic>{
        if (record['recordTitle'] != null) 'Title': record['recordTitle'],
        if (record['recordKey'] != null) 'ID': record['recordKey'],
        ...data,
      };

      _routeToDomainResult(displayData, meta);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _error = msg.isNotEmpty ? msg : 'No result found. Please check your details.';
      });
    }
  }

  void _routeToDomainResult(Map<String, dynamic> data, DatasetMeta meta) {
    Widget destinationScreen;
    final domain = widget.domainType.toUpperCase();
    
    if (domain.contains('ACADEMIC') || domain.contains('EDU')) {
      if (domain.contains('SCHOOL')) {
        destinationScreen = SchoolResultScreen(data: data, title: widget.datasetName);
      } else {
        destinationScreen = AcademicResultScreen(data: data, title: widget.datasetName);
      }
    } else if (domain.contains('POLITICS') || domain.contains('ELECTION')) {
      destinationScreen = ElectionResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('FINANCE') || domain.contains('MARKET') || domain.contains('ECONOM')) {
      destinationScreen = FinanceResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('ENTERTAIN') || domain.contains('MEDIA') || domain.contains('MOVIE')) {
      destinationScreen = EntertainmentResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('GOVERNMENT') || domain.contains('GOV')) {
      destinationScreen = GovernmentResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('LAW') || domain.contains('COURT')) {
      destinationScreen = LawResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('HEALTH')) {
      destinationScreen = HealthcareResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('BUSINESS') || domain.contains('JOB') || domain.contains('WORK')) {
      destinationScreen = BusinessResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('TECH') || domain.contains('INNOVATION') || domain.contains('SOFTWARE')) {
      destinationScreen = TechResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('HYPERLOCAL') || domain.contains('LOCAL')) {
      destinationScreen = HyperLocalResultScreen(data: data, title: widget.datasetName);
    } else if (domain.contains('SPORT') || domain.contains('GAME')) {
      destinationScreen = ResultDetailScreen(
        domainName: widget.domainType,
        icon: _getIconForDomain(widget.domainType),
        recordData: data,
        datasetName: widget.datasetName,
      );
    } else {
      destinationScreen = ResultDetailScreen(
        domainName: widget.domainType,
        icon: _getIconForDomain(widget.domainType),
        recordData: data,
        datasetName: widget.datasetName,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destinationScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(datasetMetaProvider(widget.datasetId));

    return metaAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.colors.bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(child: Text('Failed to load dataset schema: $err')),
      ),
      data: (meta) {
        // Initialize access state if not done
        final accessNotifier = ref.read(accessStateProvider(widget.datasetId).notifier);
        // We only initialize once, avoid infinite rebuilds by checking current state
        final currentState = ref.read(accessStateProvider(widget.datasetId));
        if (currentState.isPasswordProtected == false && currentState.isPrivateBlocked == false && currentState.isUnlocked == false) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
              accessNotifier.initializeForDataset(
                meta.datasetType == DatasetType.protectedLookup,
                meta.datasetType == DatasetType.privateInternal,
              );
           });
        }

        final accessState = ref.watch(accessStateProvider(widget.datasetId));

        if (accessState.isPrivateBlocked) {
          return const PrivateBlockedView();
        }

        if (accessState.isPasswordProtected && !accessState.isUnlocked) {
          return PasswordGate(
            datasetId: widget.datasetId,
            child: _buildSearchForm(meta),
          );
        }

        return _buildSearchForm(meta);
      },
    );
  }

  Widget _buildSearchForm(DatasetMeta meta) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.ink),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildFormContent(meta),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: context.colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: context.colors.orange, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _loadingMessage ?? 'Loading...',
            style: TextStyle(
              color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(DatasetMeta meta) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(_getIconForDomain(widget.domainType), size: 48, color: context.colors.orange),
          const SizedBox(height: 24),
          Text(
            widget.datasetName,
            style: TextStyle(
              color: context.colors.ink, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2, letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your details below to check your result.',
            style: TextStyle(color: context.colors.inkMuted, fontSize: 15),
          ),
          const SizedBox(height: 40),

          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_error!, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

          // Dynamic Fields
          ...meta.searchFields.map((field) {
            _controllers.putIfAbsent(field.key, () => TextEditingController());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel(field.label),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _controllers[field.key]!,
                  hint: 'Enter ${field.label}',
                  icon: field.type == FieldType.date ? Icons.calendar_today_rounded : Icons.badge_outlined,
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          const SizedBox(height: 24),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _performSearch(meta),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                elevation: 4,
              ),
              child: const Text('Search Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, IconData? icon}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w400),
        prefixIcon: icon != null ? Icon(icon, color: context.colors.inkMuted) : null,
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: context.colors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
