import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/api_service.dart';
import 'manage_team_screen.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _obscureCode = true;
  String? _workspaceId;
  String _accessCode = '------';
  String _shareLink = '';
  bool _isLoadingWorkspace = true;
  bool _isRegenerating = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access code regenerated!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to regenerate code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildShareSection(),
          const SizedBox(height: 24),
          _buildSettingsGroup('ORGANIZATION', [
            _buildSettingsTile(context, 'Profile Details', Icons.business),
            _buildSettingsTile(context, 'Manage Team Access', Icons.group),
            _buildSettingsTile(
              context,
              'Billing & Subscription',
              Icons.payment,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsGroup('DEVELOPER', [
            _buildSettingsTile(context, 'API Integrations', Icons.code),
            _buildSettingsTile(context, 'Webhooks', Icons.webhook),
            _buildSettingsTile(context, 'Documentation', Icons.book),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    if (_isLoadingWorkspace) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workspaceId == null) {
      return const Text('Create a workspace before managing share settings.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SHARE WORKSPACE',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Access Code:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        _obscureCode ? '••••••' : _accessCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _obscureCode
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCode = !_obscureCode),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Link'),
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
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _isRegenerating ? null : _regenerateCode,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text(
                    'Regenerate Code',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0F172A)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () {
        if (title == 'Manage Team Access') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageTeamScreen()),
          );
        }
      },
    );
  }
}
