import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/workspace_wizard_provider.dart';

class MyWorkspacesScreen extends ConsumerStatefulWidget {
  const MyWorkspacesScreen({super.key});

  @override
  ConsumerState<MyWorkspacesScreen> createState() =>
      _MyWorkspacesScreenState();
}

class _MyWorkspacesScreenState extends ConsumerState<MyWorkspacesScreen> {
  late Future<List<dynamic>> _workspacesFuture;

  @override
  void initState() {
    super.initState();
    _refreshWorkspaces();
  }

  void _refreshWorkspaces() {
    setState(() {
      _workspacesFuture = ref.read(apiServiceProvider).fetchMyWorkspaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: const Text(
          'MY WORKSPACES',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: false,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.ink,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.colors.ink),
            onPressed: _refreshWorkspaces,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _workspacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 60, color: context.colors.liveRed),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load workspaces',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.colors.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.colors.inkMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshWorkspaces,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final workspaces = snapshot.data ?? [];

          if (workspaces.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspaces_outline,
                        size: 80,
                        color: context.colors.inkMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 20),
                    Text(
                      'No Workspaces Found',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: context.colors.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first workspace to start publishing results and datasets.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.colors.inkMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Workspace'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: context.colors.primary,
            onRefresh: () async => _refreshWorkspaces(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                final w = workspaces[index] as Map<String, dynamic>;
                return _buildWorkspaceCard(context, w);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/create'),
        backgroundColor: context.colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Workspace',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWorkspaceCard(
      BuildContext context, Map<String, dynamic> workspace) {
    final name = workspace['name']?.toString() ?? 'Unnamed Workspace';
    final slug = workspace['slug']?.toString() ?? '';
    final description = workspace['description']?.toString() ?? '';
    final visibility = workspace['visibility']?.toString() ?? 'PUBLIC';
    final createdAtStr = workspace['createdAt']?.toString() ?? '';
    final logoEmoji = workspace['logoEmoji']?.toString();
    final logoBase64 = workspace['logoBase64']?.toString();

    // ── Formatted date ───────────────────────────────────────────
    String formattedDate = 'Created recently';
    if (createdAtStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(createdAtStr);
        formattedDate =
            'Created ${parsed.day}/${parsed.month}/${parsed.year}';
      } catch (_) {
        if (createdAtStr.contains('T')) {
          formattedDate = 'Created ${createdAtStr.split('T')[0]}';
        }
      }
    }

    // ── Visibility metadata ──────────────────────────────────────
    final IconData visibilityIcon;
    final Color visibilityColor;
    final String visibilityLabel;

    switch (visibility) {
      case 'PRIVATE':
        visibilityIcon = Icons.lock;
        visibilityColor = context.colors.inkMuted;
        visibilityLabel = 'Private';
        break;
      case 'PASSWORD_PROTECTED':
        visibilityIcon = Icons.lock_open;
        visibilityColor = context.colors.amber;
        visibilityLabel = 'Password Protected';
        break;
      default:
        visibilityIcon = Icons.public;
        visibilityColor = context.colors.green;
        visibilityLabel = 'Public';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo avatar
                _WorkspaceLogo(
                  logoEmoji: logoEmoji,
                  logoBase64: logoBase64,
                  primaryColor: context.colors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: context.colors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(visibilityIcon,
                              size: 12, color: visibilityColor),
                          const SizedBox(width: 4),
                          Text(
                            visibilityLabel,
                            style: TextStyle(
                              color: visibilityColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          if (slug.isNotEmpty) ...[
                            Text(
                              '  ·  @$slug',
                              style: TextStyle(
                                color: context.colors.inkFaint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Quick-manage icon
                IconButton(
                  icon: Icon(Icons.open_in_new,
                      size: 18, color: context.colors.inkMuted),
                  onPressed: () {
                    ref
                        .read(workspaceWizardProvider.notifier)
                        .selectWorkspace(
                          id: workspace['id']?.toString() ?? '',
                          name: name,
                          slug: slug,
                          visibility: visibility,
                          description: description,
                        );
                    context.push('/admin/dashboard');
                  },
                  tooltip: 'Open Dashboard',
                ),
              ],
            ),
          ),

          // ── Description ─────────────────────────────────────────────────
          if (description.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: context.colors.inkMuted, fontSize: 13, height: 1.5),
              ),
            ),
          ],

          // ── Footer ─────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: context.colors.inkFaint),
                    const SizedBox(width: 5),
                    Text(
                      formattedDate,
                      style: TextStyle(
                          color: context.colors.inkFaint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    ref
                        .read(workspaceWizardProvider.notifier)
                        .selectWorkspace(
                          id: workspace['id']?.toString() ?? '',
                          name: name,
                          slug: slug,
                          visibility: visibility,
                          description: description,
                        );
                    context.push('/admin/dashboard');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Manage',
                          style: TextStyle(
                            color: context.colors.blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 14, color: context.colors.blue),
                      ],
                    ),
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

// ─── Logo avatar widget ──────────────────────────────────────────────────────
class _WorkspaceLogo extends StatelessWidget {
  final String? logoEmoji;
  final String? logoBase64;
  final Color primaryColor;

  const _WorkspaceLogo({
    this.logoEmoji,
    this.logoBase64,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Priority: logoBase64 > logoEmoji > fallback icon
    if (logoBase64 != null && logoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(logoBase64!.split(',').last);
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(bytes, width: 56, height: 56, fit: BoxFit.cover),
        );
      } catch (_) {
        // Fall through
      }
    }

    if (logoEmoji != null && logoEmoji!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        ),
        alignment: Alignment.center,
        child: Text(logoEmoji!, style: const TextStyle(fontSize: 28)),
      );
    }

    // Generic fallback
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.workspaces_outlined, color: primaryColor, size: 26),
    );
  }
}
