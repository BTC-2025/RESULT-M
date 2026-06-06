import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';

class ManageTeamScreen extends ConsumerStatefulWidget {
  final String? workspaceId;

  const ManageTeamScreen({super.key, this.workspaceId});

  @override
  ConsumerState<ManageTeamScreen> createState() => _ManageTeamScreenState();
}

class _ManageTeamScreenState extends ConsumerState<ManageTeamScreen> {
  static const List<String> _roles = ['ADMIN', 'EDITOR', 'VIEWER'];

  String? _workspaceId;
  List<dynamic> _members = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final workspaceId = widget.workspaceId ?? await _resolveWorkspaceId(api);
      if (workspaceId == null) {
        throw Exception('Create a workspace before managing team access.');
      }
      final members = await api.fetchWorkspaceMembers(workspaceId);
      if (!mounted) return;
      setState(() {
        _workspaceId = workspaceId;
        _members = members;
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

  Future<String?> _resolveWorkspaceId(ApiService api) async {
    final workspaces = await api.fetchMyWorkspaces(size: 1);
    if (workspaces.isEmpty) return null;
    return workspaces.first['id']?.toString();
  }

  Future<void> _showInviteDialog() async {
    final emailController = TextEditingController();
    String selectedRole = 'EDITOR';

    final invitation = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Invite Team Member',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _roles
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(_formatRole(role)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedRole = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    if (email.isEmpty) return;
                    Navigator.pop(context, {
                      'email': email,
                      'role': selectedRole,
                    });
                  },
                  child: const Text('Send Invite'),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
    if (invitation == null || _workspaceId == null) return;

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.inviteWorkspaceMember(
        _workspaceId!,
        invitation['email']!,
        invitation['role']!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite token: ${response['token']}'),
          duration: const Duration(seconds: 8),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite failed: $e')),
      );
    }
  }

  Future<void> _changeRole(Map<String, dynamic> member, String role) async {
    final oldMembers = List<dynamic>.from(_members);
    setState(() {
      _members = _members
          .map(
            (item) => item['id'] == member['id'] ? {...item, 'role': role} : item,
          )
          .toList();
    });

    try {
      await ref
          .read(apiServiceProvider)
          .updateWorkspaceMemberRole(member['id'].toString(), role);
    } catch (e) {
      if (!mounted) return;
      setState(() => _members = oldMembers);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role update failed: $e')),
      );
    }
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member['email']} from this workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(apiServiceProvider)
          .removeWorkspaceMember(member['id'].toString());
      if (!mounted) return;
      setState(() {
        _members = _members
            .where((item) => item['id'].toString() != member['id'].toString())
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'MANAGE TEAM',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _workspaceId == null ? null : _showInviteDialog,
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Invite Member',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
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
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadMembers,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMembers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index] as Map<String, dynamic>;
          final role = member['role']?.toString() ?? 'VIEWER';
          final isOwner = role == 'OWNER';
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color(0xFF0F172A).withValues(alpha: 0.1),
                child: Text(
                  (member['name']?.toString().isNotEmpty == true
                          ? member['name'].toString()
                          : member['email'].toString())
                      .characters
                      .first
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member['name']?.toString() ?? 'Team Member',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(member['email']?.toString() ?? ''),
              trailing: isOwner
                  ? const Chip(label: Text('OWNER'))
                  : PopupMenuButton<String>(
                      initialValue: role,
                      onSelected: (value) {
                        if (value == 'REMOVE') {
                          _removeMember(member);
                        } else {
                          _changeRole(member, value);
                        }
                      },
                      itemBuilder: (context) => [
                        ..._roles.map(
                          (role) => PopupMenuItem(
                            value: role,
                            child: Text(_formatRole(role)),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'REMOVE',
                          child: Text(
                            'Remove',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      child: Chip(label: Text(_formatRole(role))),
                    ),
            ),
          );
        },
      ),
    );
  }

  String _formatRole(String role) {
    return role.replaceAll('_', ' ');
  }
}
