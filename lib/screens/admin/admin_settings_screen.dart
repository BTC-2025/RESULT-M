import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'manage_team_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _obscureCode = true;
  String _accessCode = 'X7K2PQ'; // Dummy code for UI
  String _shareLink = 'https://resulthub.app/w/putlur-local-cricket-finals?code=X7K2PQ';

  void _regenerateCode() {
    // In a real app, call POST /api/v1/workspaces/{id}/regenerate-code
    setState(() {
      _accessCode = 'NEW842';
      _shareLink = 'https://resulthub.app/w/putlur-local-cricket-finals?code=$_accessCode';
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access code regenerated!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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
            _buildSettingsTile(context, 'Billing & Subscription', Icons.payment),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SHARE WORKSPACE', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
                  const Text('Access Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(
                        _obscureCode ? '••••••' : _accessCode,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 2),
                      ),
                      IconButton(
                        icon: Icon(_obscureCode ? Icons.visibility : Icons.visibility_off, size: 20, color: Colors.grey),
                        onPressed: () => setState(() => _obscureCode = !_obscureCode),
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Link'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Share.share(_shareLink, subject: 'Join my ResultHub Workspace!'),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _regenerateCode,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text('Regenerate Code', style: TextStyle(color: Colors.red)),
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
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {
        if (title == 'Manage Team Access') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageTeamScreen()));
        }
      },
    );
  }
}
