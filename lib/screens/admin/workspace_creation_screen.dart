import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/workspace_wizard_provider.dart';

class WorkspaceCreationScreen extends ConsumerStatefulWidget {
  const WorkspaceCreationScreen({super.key});

  @override
  ConsumerState<WorkspaceCreationScreen> createState() => _WorkspaceCreationScreenState();
}

class _WorkspaceCreationScreenState extends ConsumerState<WorkspaceCreationScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      ref.read(workspaceWizardProvider.notifier).updateLogo(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceWizardProvider);
    final notifier = ref.read(workspaceWizardProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text('Create Workspace', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (state.currentStep + 1) / 6,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Step ${state.currentStep + 1} of 6', style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: IndexedStack(
                index: state.currentStep,
                children: [
                  _buildStep1(context, state, notifier),
                  _buildStep2(context, state, notifier),
                  _buildStep3(context, state, notifier),
                  _buildStep4(context, state, notifier),
                  _buildStep5(context, state, notifier),
                  _buildStep6(context, state, notifier),
                ],
              ),
            ),
            // Navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.currentStep > 0)
                    TextButton(
                      onPressed: notifier.previousStep,
                      child: Text('Back', style: TextStyle(color: context.colors.inkMuted)),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  ElevatedButton(
                    onPressed: state.isSubmitting ? null : () async {
                      if (state.currentStep == 5) {
                        final success = await notifier.submit();
                        if (success && context.mounted) {
                          context.go('/admin/dashboard');
                        } else if (context.mounted && ref.read(workspaceWizardProvider).error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ref.read(workspaceWizardProvider).error!),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      } else {
                        notifier.nextStep();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: state.isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(state.currentStep == 5 ? 'Create Workspace' : 'Continue'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, WorkspaceCreationState state, WorkspaceWizardNotifier notifier) {
    if (_nameCtrl.text.isEmpty && state.organizationName.isNotEmpty) {
      _nameCtrl.text = state.organizationName;
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is the name of your organization?', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('This is usually the official name of your institution.', style: TextStyle(color: context.colors.inkMuted, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            onChanged: notifier.updateName,
            style: TextStyle(color: context.colors.ink, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g., Anna University',
              hintStyle: TextStyle(color: context.colors.inkFaint),
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, WorkspaceCreationState state, WorkspaceWizardNotifier notifier) {
    final types = ['Educational', 'Government', 'Sports', 'Business', 'Healthcare', 'Legal', 'Finance', 'Media', 'Technology', 'Community'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Organization Type', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: types.length,
              itemBuilder: (context, index) {
                final t = types[index];
                final isSelected = state.organizationType == t;
                return ListTile(
                  title: Text(t, style: TextStyle(color: context.colors.ink, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: context.colors.primary) : null,
                  onTap: () => notifier.updateType(t),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  tileColor: isSelected ? context.colors.primary.withValues(alpha: 0.1) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context, WorkspaceCreationState state, WorkspaceWizardNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workspace Slug', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('This determines your public URL (auto-generated).', style: TextStyle(color: context.colors.inkMuted, fontSize: 14)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Text('resulthub.com/', style: TextStyle(color: context.colors.inkMuted, fontSize: 16)),
                Expanded(child: Text(state.workspaceSlug, style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(BuildContext context, WorkspaceCreationState state, WorkspaceWizardNotifier notifier) {
    final opts = [
      {'val': 'Public', 'desc': 'Indexed globally, searchable by anyone.'},
      {'val': 'Password Protected', 'desc': 'Hidden from search. Requires a passcode.'},
      {'val': 'Private', 'desc': 'Viewable strictly by whitelisted team members.'},
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Visibility', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          RadioGroup<String>(
            groupValue: state.visibility,
            onChanged: (v) => notifier.updateVisibility(v!),
            child: Column(
              children: opts.map((o) {
                final isSelected = state.visibility == o['val'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isSelected ? context.colors.primary : context.colors.border, width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? context.colors.primary.withValues(alpha: 0.05) : context.colors.surface,
                  ),
                  child: RadioListTile<String>(
                    value: o['val'] as String,
                    title: Text(o['val']!, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold)),
                    subtitle: Text(o['desc']!, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    activeColor: context.colors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5(BuildContext context, WorkspaceCreationState state, WorkspaceWizardNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Logo', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.border, width: 2),
                ),
                child: state.logoPath != null
                  ? ClipOval(child: Icon(Icons.image, size: 60, color: context.colors.primary)) // Normally Image.file
                  : Icon(Icons.add_a_photo, size: 40, color: context.colors.inkMuted),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Tap to upload image', style: TextStyle(color: context.colors.inkMuted))),
        ],
      ),
    );
  }

  Widget _buildStep6(BuildContext context, WorkspaceCreationState state, WorkspaceWizardNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization Description', style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Tell users what this workspace is about.', style: TextStyle(color: context.colors.inkMuted, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            controller: _descCtrl,
            onChanged: notifier.updateDescription,
            maxLines: 5,
            style: TextStyle(color: context.colors.ink),
            decoration: InputDecoration(
              hintText: 'Description...',
              hintStyle: TextStyle(color: context.colors.inkFaint),
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
