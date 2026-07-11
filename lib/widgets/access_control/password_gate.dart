import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/access_state_provider.dart';

class PasswordGate extends ConsumerStatefulWidget {
  final String datasetId;
  final Widget child; // The screen to show if unlocked

  const PasswordGate({super.key, required this.datasetId, required this.child});

  @override
  ConsumerState<PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends ConsumerState<PasswordGate> {
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _unlock() async {
    if (_passwordCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    final notifier = ref.read(accessStateProvider(widget.datasetId).notifier);
    final success = await notifier.unlockWithPassword(_passwordCtrl.text);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Clear password for security
        _passwordCtrl.clear();
      }
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessState = ref.watch(accessStateProvider(widget.datasetId));

    if (accessState.isUnlocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.colors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: context.colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_rounded, size: 40, color: context.colors.orange),
              ),
              const SizedBox(height: 24),
              Text(
                'Protected Dataset',
                style: TextStyle(
                  color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the access code provided by the administrator to view these results.',
                style: TextStyle(color: context.colors.inkMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              if (accessState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(accessState.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),

              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  hintStyle: TextStyle(color: context.colors.inkFaint, fontWeight: FontWeight.normal, letterSpacing: 0),
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
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _unlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Unlock Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
