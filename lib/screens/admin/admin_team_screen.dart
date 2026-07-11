import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class AdminTeamScreen extends ConsumerStatefulWidget {
  final String? workspaceId;

  const AdminTeamScreen({super.key, this.workspaceId});

  @override
  ConsumerState<AdminTeamScreen> createState() => _AdminTeamScreenState();
}

class _AdminTeamScreenState extends ConsumerState<AdminTeamScreen> {
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
    if (!mounted) return;
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
              backgroundColor: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colors.border),
              ),
              title: Text(
                'Invite Team Member',
                style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: context.colors.ink),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: TextStyle(color: context.colors.inkFaint),
                      filled: true,
                      fillColor: context.colors.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: context.colors.surface,
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.colors.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                    ),
                    items: _roles
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              _formatRole(role),
                              style: TextStyle(color: context.colors.ink),
                            ),
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
                  child: Text('Cancel', style: TextStyle(color: context.colors.inkMuted)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                  ),
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
      await api.inviteWorkspaceMember(
        _workspaceId!,
        invitation['email']!,
        invitation['role']!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite sent.')),
      );
      _loadMembers();
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
        backgroundColor: context.colors.surface,
        title: Text('Remove Member', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
        content: Text('Remove ${member['email']} from this workspace?', style: TextStyle(color: context.colors.inkMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: context.colors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.liveRed),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully.')),
      );
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
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: const Text(
          'MANAGE TEAM',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.ink,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _workspaceId == null ? null : _showInviteDialog,
        backgroundColor: context.colors.primary,
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
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted)),
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

    if (_members.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMembers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: Text(
              'No team members found.',
              style: TextStyle(color: context.colors.inkMuted, fontSize: 16),
            ),
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
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.colors.border),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                child: Text(
                  (member['name']?.toString().isNotEmpty == true
                          ? member['name'].toString()
                          : member['email'].toString())
                      .characters
                      .first
                      .toUpperCase(),
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member['name']?.toString() ?? 'Team Member',
                style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink),
              ),
              subtitle: Text(
                member['email']?.toString() ?? '',
                style: TextStyle(color: context.colors.inkMuted),
              ),
              trailing: isOwner
                  ? Chip(
                      backgroundColor: context.colors.surfaceAlt,
                      side: BorderSide(color: context.colors.border),
                      label: Text(
                        'OWNER',
                        style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold),
                      ),
                    )
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
                      child: Chip(
                        backgroundColor: context.colors.surfaceAlt,
                        side: BorderSide(color: context.colors.border),
                        label: Text(
                          _formatRole(role),
                          style: TextStyle(color: context.colors.ink),
                        ),
                      ),
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
