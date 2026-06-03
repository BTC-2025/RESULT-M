import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import 'guest/local_workspace_screen.dart';
import 'guest/password_unlock_screen.dart';
import '../../core/network/api_client.dart';

class WorkspaceResolverScreen extends ConsumerStatefulWidget {
  final String slug;
  final String? initialCode;

  const WorkspaceResolverScreen({super.key, required this.slug, this.initialCode});

  @override
  ConsumerState<WorkspaceResolverScreen> createState() => _WorkspaceResolverScreenState();
}

class _WorkspaceResolverScreenState extends ConsumerState<WorkspaceResolverScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveWorkspace();
  }

  Future<void> _resolveWorkspace() async {
    try {
      final dio = ref.read(apiClientProvider).client;
      final response = await dio.get('/workspaces/slug/${widget.slug}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final visibility = data['visibility'];
        final workspaceId = data['id'];
        final workspaceName = data['name'];

        if (!mounted) return;

        if (visibility == 'PUBLIC') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LocalWorkspaceScreen(workspaceId: workspaceId, workspaceName: workspaceName),
            ),
          );
        } else if (visibility == 'PASSWORD_PROTECTED') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordUnlockScreen(
                workspaceId: workspaceId,
                workspaceName: workspaceName,
                initialCode: widget.initialCode,
              ),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _error = 'Private workspaces cannot be accessed via link.';
          });
        }
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.response?.data?['message'] ?? 'Workspace not found.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'An unexpected error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  Text(_error ?? 'Unknown Error', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    child: const Text('Go Home'),
                  )
                ],
              ),
      ),
    );
  }
}
