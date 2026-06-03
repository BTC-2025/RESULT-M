import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/workspace_unlock_provider.dart';

class PasswordUnlockScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String workspaceName;

  const PasswordUnlockScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
  });

  @override
  ConsumerState<PasswordUnlockScreen> createState() => _PasswordUnlockScreenState();
}

class _PasswordUnlockScreenState extends ConsumerState<PasswordUnlockScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submitUnlock() async {
    final code = _passwordController.text.trim();
    if (code.isEmpty) return;

    final success = await ref
        .read(workspaceUnlockProvider.notifier)
        .unlockWorkspace(widget.workspaceId, code);

    if (success && mounted) {
      // Pop this screen, signaling success
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceUnlockProvider);
    final isLoading = state.status == WorkspaceUnlockState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.workspaceName, 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, size: 56, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Private Workspace', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A))
              ),
              const SizedBox(height: 8),
              const Text(
                'This workspace is password protected.\nEnter the access passcode to continue.', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 4),
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Enter Access Code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: state.status == WorkspaceUnlockState.error ? state.errorMessage : null,
                ),
                onSubmitted: (_) => _submitUnlock(),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    disabledBackgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          'UNLOCK', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
