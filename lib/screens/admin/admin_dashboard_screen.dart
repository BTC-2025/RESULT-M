import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'quick_score_entry_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;
  String? _error;
  
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic>? _currentWorkspace;
  List<dynamic> _datasets = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Fetch global analytics
      final analyticsData = await apiService.fetchGlobalAnalytics();
      
      // Fetch workspaces
      final workspaces = await apiService.fetchMyWorkspaces();
      Map<String, dynamic>? primaryWorkspace;
      List<dynamic> datasets = [];
      
      if (workspaces.isNotEmpty) {
        primaryWorkspace = workspaces.first as Map<String, dynamic>;
        // Fetch datasets for the primary workspace
        datasets = await apiService.fetchDatasets(primaryWorkspace['id']);
      }

      if (!mounted) return;
      setState(() {
        _analytics = analyticsData;
        _currentWorkspace = primaryWorkspace;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(
          'DASHBOARD',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: context.colors.ink),
        ),
        centerTitle: false,
        backgroundColor: context.colors.bg,
        foregroundColor: context.colors.ink,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: context.colors.ink),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.blue,
        backgroundColor: context.colors.surface,
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 120), // Padding for floating nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partner Header
              _buildPartnerHeader(context),
              const SizedBox(height: 32),

              Text(
                'ANALYTICS OVERVIEW',
                style: TextStyle(
                  color: context.colors.inkMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_error != null)
                _buildErrorWidget(_error!)
              else
                _buildBentoGrid(context),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVE CAMPAIGNS',
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'View all',
                    style: TextStyle(
                      color: context.colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_datasets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'No active campaigns found.',
                      style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _datasets.length,
                  itemBuilder: (context, index) {
                    final dataset = _datasets[index];
                    return _buildLiveDatasetItem(
                      context,
                      dataset['name'] ?? 'Unnamed Dataset',
                      dataset['description'] ?? 'No description provided',
                      dataset['id'] ?? '',
                      // We don't have a specific record ID to jump to by default, so we pass empty or let the quick entry handle it
                      "", 
                      context.colors.orange,
                    );
                  },
                ),
              
              const SizedBox(height: 32),
              Text(
                'SYSTEM ALERTS',
                style: TextStyle(
                  color: context.colors.inkMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildAlertItem(
                context,
                'High Traffic Detected',
                'Recent campaigns are driving increased lookups/min. Infrastructure scaled automatically.',
                Icons.speed,
                context.colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentWorkspace?['name'] ?? (_isLoading ? 'Loading Workspace...' : 'No Workspace Found'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: context.colors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                if (_currentWorkspace != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: context.colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Partner',
                          style: TextStyle(
                            color: context.colors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      context.push('/create-organization');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.orange, foregroundColor: Colors.white),
                    child: const Text('Create Organization'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        StaggeredGridTile.fit(
          crossAxisCellCount: 2,
          child: _buildFlatStatCard(
            context,
            'Total Records',
            _formatMetric(_analytics['totalRecords']),
            Icons.dns_outlined,
            context.colors.blue,
            isMainCard: true,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildFlatStatCard(
            context,
            'Views',
            _formatMetric(_analytics['totalViews']),
            Icons.visibility_outlined,
            context.colors.purple,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildFlatStatCard(
            context,
            'Uploads',
            _formatMetric(_analytics['totalUploads']),
            Icons.cloud_upload_outlined,
            context.colors.green,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildFlatStatCard(
            context,
            'Workspaces',
            _formatMetric(_analytics['totalWorkspaces']),
            Icons.dashboard_customize_outlined,
            context.colors.orange,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildFlatStatCard(
            context,
            'Searches',
            _formatMetric(_analytics['totalSearches']),
            Icons.search_outlined,
            context.colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildFlatStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isMainCard = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMainCard ? 24 : 20),
      decoration: BoxDecoration(
        color: isMainCard ? color : context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isMainCard ? color : context.colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: isMainCard ? color.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
            blurRadius: isMainCard ? 20 : 10,
            offset: Offset(0, isMainCard ? 10 : 5),
          ),
        ],
      ),
      child: isMainCard
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    Icon(Icons.arrow_outward, color: context.colors.inkFaint, size: 16),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: context.colors.ink,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: context.colors.inkMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLiveDatasetItem(
    BuildContext context,
    String title,
    String subtitle,
    String datasetId,
    String recordId,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, val, _) {
                  return Container(
                    width: 48 + (val * 16),
                    height: 48 + (val * 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: (1 - val) * 0.2),
                    ),
                  );
                },
                onEnd: () {
                  // Pulse approximation
                },
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sensors, color: accentColor, size: 24),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: context.colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: context.colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: context.colors.border),
            ),
            icon: Icon(Icons.flash_on, color: accentColor, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuickScoreEntryScreen(
                    workspaceId: _currentWorkspace?['id'] ?? "dummy-workspace",
                    datasetId: datasetId,
                    recordId: recordId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: context.colors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: context.colors.inkMuted,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMsg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.liveRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.liveRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.colors.liveRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMsg,
              style: TextStyle(
                color: context.colors.liveRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadDashboardData,
            icon: Icon(Icons.refresh, color: context.colors.liveRed),
          ),
        ],
      ),
    );
  }

  String _formatMetric(dynamic value) {
    final number = value is num ? value : num.tryParse(value?.toString() ?? '');
    if (number == null) return '0';
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
