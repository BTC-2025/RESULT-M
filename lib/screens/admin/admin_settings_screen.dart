import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'admin_team_screen.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _obscureCode = true;
  String? _workspaceId;
  String? _workspaceName;
  String? _workspaceDescription;
  String? _workspaceSlug;
  String _accessCode = '------';
  String _shareLink = '';
  bool _isLoadingWorkspace = true;
  bool _isRegenerating = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadWorkspace();
  }

  Future<void> _loadWorkspace() async {
    try {
      final api = ref.read(apiServiceProvider);
      final workspaces = await api.fetchMyWorkspaces(size: 1);
      if (!mounted) return;
      if (workspaces.isEmpty) {
        setState(() => _isLoadingWorkspace = false);
        return;
      }
      final workspace = workspaces.first as Map<String, dynamic>;
      final workspaceId = workspace['id']?.toString();
      final slug = workspace['slug']?.toString() ?? workspaceId;
      setState(() {
        _workspaceId = workspaceId;
        _workspaceName = workspace['name']?.toString();
        _workspaceDescription = workspace['description']?.toString();
        _workspaceSlug = slug;
        _shareLink = 'https://resulthub.app/w/$slug';
        _isLoadingWorkspace = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingWorkspace = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load workspace settings: $e')),
      );
    }
  }

  Future<void> _regenerateCode() async {
    if (_workspaceId == null || _isRegenerating) return;
    setState(() => _isRegenerating = true);
    try {
      final response = await ref
          .read(apiServiceProvider)
          .regenerateWorkspaceCode(_workspaceId!);
      final link = response['link']?.toString() ?? '';
      final code = Uri.tryParse(link)?.queryParameters['code'];
      if (!mounted) return;
      setState(() {
        _shareLink = link;
        _accessCode = code ?? 'UPDATED';
        _isRegenerating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Access code regenerated!'),
          backgroundColor: context.colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to regenerate code: $e')),
      );
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text('Log Out',
            style: TextStyle(
                fontWeight: FontWeight.w900, color: context.colors.ink)),
        content: Text(
          'Are you sure you want to log out of your admin account?',
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
                backgroundColor: context.colors.liveRed,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  // ─── Profile edit dialog ──────────────────────────────────────────────────
  Future<void> _showProfileDialog() async {
    final nameCtrl =
        TextEditingController(text: _workspaceName ?? '');
    final descCtrl =
        TextEditingController(text: _workspaceDescription ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border),
        ),
        title: Text('Profile Details',
            style: TextStyle(
                fontWeight: FontWeight.w900, color: context.colors.ink)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Workspace Name'),
              const SizedBox(height: 12),
              _dialogField(descCtrl, 'Description', maxLines: 3),
              if (_workspaceSlug != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 16, color: context.colors.inkMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'resulthub.app/w/$_workspaceSlug',
                          style: TextStyle(
                              color: context.colors.inkMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
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
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted || _workspaceId == null) return;

    try {
      await ref.read(apiServiceProvider).updateDatasetMetadata(
        _workspaceId!,
        {
          'name': nameCtrl.text.trim(),
          'description': descCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      setState(() {
        _workspaceName = nameCtrl.text.trim();
        _workspaceDescription = descCtrl.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated!'),
          backgroundColor: context.colors.green,
        ),
      );
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

  // ─── API Integrations — coming soon ─────────────────────────────────────
  void _showApiKeyDialog() {
    _showComingSoonSheet(
      icon: Icons.code_rounded,
      title: 'API Integrations',
      description:
          'Generate and manage API keys to connect external services directly to your workspace.',
    );
  }

  // ─── Billing — coming soon ────────────────────────────────────────────────
  void _showBillingSheet() {
    _showComingSoonSheet(
      icon: Icons.payment_rounded,
      title: 'Billing & Subscription',
      description:
          'Manage your plan, view usage, and handle invoices — all from one place.',
    );
  }

  // ─── Webhooks — coming soon ───────────────────────────────────────────────
  void _showWebhookSheet() {
    _showComingSoonSheet(
      icon: Icons.webhook_rounded,
      title: 'Webhooks',
      description:
          'Get real-time HTTP callbacks whenever records are updated, uploaded, or searched in your workspace.',
    );
  }

  // ─── Shared "Coming Soon" bottom sheet ────────────────────────────────────
  void _showComingSoonSheet({
    required IconData icon,
    required String title,
    required String description,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colors.primary, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: context.colors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.inkMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      color: context.colors.inkMuted, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'This feature is coming soon.',
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.surface,
                  foregroundColor: context.colors.ink,
                  elevation: 0,
                  side: BorderSide(color: context.colors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Got it',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper: text field for dialogs ───────────────────────────────────────
  Widget _dialogField(TextEditingController ctrl, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: context.colors.ink),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.colors.inkMuted),
        filled: true,
        fillColor: context.colors.surfaceAlt,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: false,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.ink,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          // ── Workspace summary card ─────────────────────────────────────
          if (_workspaceName != null)
            _buildWorkspaceCard(),
          if (_workspaceName != null) const SizedBox(height: 24),

          _buildShareSection(),
          const SizedBox(height: 24),

          _buildSettingsGroup('ORGANIZATION', [
            _buildSettingsTile(
              'Profile Details',
              Icons.business_outlined,
              onTap: _showProfileDialog,
            ),
            _buildSettingsTile(
              'Manage Team Access',
              Icons.group_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminTeamScreen()),
              ),
            ),
            _buildSettingsTile(
              'Billing & Subscription',
              Icons.payment_outlined,
              trailing: _buildBadge('Free'),
              onTap: _showBillingSheet,
            ),
          ]),

          const SizedBox(height: 24),

          _buildSettingsGroup('DEVELOPER', [
            _buildSettingsTile(
              'API Integrations',
              Icons.code_outlined,
              onTap: _showApiKeyDialog,
            ),
            _buildSettingsTile(
              'Webhooks',
              Icons.webhook_outlined,
              trailing: _buildBadge('Pro'),
              onTap: _showWebhookSheet,
            ),
            _buildSettingsTile(
              'Documentation',
              Icons.book_outlined,
              onTap: () async {
                final uri =
                    Uri.parse('https://docs.resulthub.app');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
          ]),

          const SizedBox(height: 32),

          // ── Logout button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              icon: _isLoggingOut
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.liveRed,
                      ),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(
                _isLoggingOut ? 'Logging out...' : 'LOG OUT',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    context.colors.liveRed.withValues(alpha: 0.1),
                foregroundColor: context.colors.liveRed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: context.colors.liveRed.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Workspace summary card ───────────────────────────────────────────────
  Widget _buildWorkspaceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.corporate_fare_rounded,
                color: context.colors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _workspaceName ?? '',
                  style: TextStyle(
                      color: context.colors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 16),
                ),
                if (_workspaceSlug != null)
                  Text(
                    '@$_workspaceSlug',
                    style: TextStyle(
                        color: context.colors.inkMuted, fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: context.colors.green.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                  color: context.colors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Share section ────────────────────────────────────────────────────────
  Widget _buildShareSection() {
    if (_isLoadingWorkspace) {
      return Center(
          child: CircularProgressIndicator(color: context.colors.primary));
    }

    if (_workspaceId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Text(
          'Create a workspace to manage share settings.',
          style: TextStyle(color: context.colors.inkMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHARE WORKSPACE',
          style: TextStyle(
            color: context.colors.inkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              // Share link row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _shareLink.isNotEmpty
                            ? _shareLink
                            : 'resulthub.app/w/$_workspaceSlug',
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Access code row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Access Code:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: context.colors.ink),
                  ),
                  Row(
                    children: [
                      Text(
                        _obscureCode ? '••••••' : _accessCode,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: context.colors.ink,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _obscureCode
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                          color: context.colors.inkMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCode = !_obscureCode),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(color: context.colors.border),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Link copied!'),
                            backgroundColor: context.colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Link'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.ink,
                        side: BorderSide(color: context.colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          text: _shareLink,
                          subject: 'Join my ResultHub Workspace!',
                        ),
                      ),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _isRegenerating ? null : _regenerateCode,
                  icon: _isRegenerating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.liveRed),
                        )
                      : Icon(Icons.refresh, color: context.colors.liveRed),
                  label: Text(
                    'Regenerate Code',
                    style: TextStyle(color: context.colors.liveRed),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Settings group ───────────────────────────────────────────────────────
  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.inkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    final isPro = label == 'Pro';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isPro ? context.colors.amber : context.colors.green)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: (isPro ? context.colors.amber : context.colors.green)
                .withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPro ? context.colors.amber : context.colors.green,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon, {
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colors.ink, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: context.colors.ink,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[trailing, const SizedBox(width: 8)],
          Icon(Icons.arrow_forward_ios,
              size: 14, color: context.colors.inkFaint),
        ],
      ),
      onTap: onTap,
    );
  }
}
