import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../providers/feed_provider.dart';
import '../../application/create_post_validator.dart';
import '../../application/media_upload_policy.dart';
import '../../domain/create_post_tab.dart';

class ComposerActionSheet extends StatelessWidget {
  final ValueChanged<CreatePostTab?> onSelect;

  const ComposerActionSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.borderBold,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'What do you want to post?',
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _ComposerOption(
              icon: Icons.edit_note_rounded,
              title: 'Share an Update',
              subtitle: 'Text, photos or video',
              color: context.colors.teal,
              onTap: () => onSelect(CreatePostTab.update),
            ),
            _ComposerOption(
              icon: Icons.campaign_rounded,
              title: 'Raise a Complaint',
              subtitle: 'Report with media proof',
              color: context.colors.liveRed,
              onTap: () => onSelect(CreatePostTab.complaint),
            ),
            _ComposerOption(
              icon: Icons.poll_rounded,
              title: 'Create a Poll',
              subtitle: 'Ask your community',
              color: context.colors.purple,
              onTap: () => onSelect(CreatePostTab.poll),
            ),
            _ComposerOption(
              icon: Icons.bar_chart_rounded,
              title: 'Publish a Result',
              subtitle: 'Scores, marks, rankings',
              color: context.colors.purple,
              onTap: () => onSelect(null),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostSheet extends ConsumerStatefulWidget {
  final CreatePostTab initialTab;

  const CreatePostSheet({super.key, required this.initialTab});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  static const _validator = CreatePostValidator();
  static const _mediaPolicy = MediaUploadPolicy();

  late CreatePostTab _tab;
  final _updateText = TextEditingController();
  final _complaintTitle = TextEditingController();
  final _complaintDescription = TextEditingController();
  final _complaintLocation = TextEditingController();
  final _pollQuestion = TextEditingController();
  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<PlatformFile> _media = [];
  String _audience = 'Public';
  String? _location;
  String? _tag;
  String _complaintCategory = 'Infrastructure';
  bool _anonymousComplaint = false;
  bool _allowAnonymousVotes = true;
  String _pollVisibility = 'Public';
  bool _pollSettingsOpen = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _updateText.dispose();
    _complaintTitle.dispose();
    _complaintDescription.dispose();
    _complaintLocation.dispose();
    _pollQuestion.dispose();
    for (final controller in _pollOptions) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canPost {
    return _validator.canPost(
      CreatePostDraft(
        tab: _tab,
        updateText: _updateText.text,
        mediaCount: _media.length,
        complaintTitle: _complaintTitle.text,
        complaintDescription: _complaintDescription.text,
        complaintCategory: _complaintCategory,
        pollQuestion: _pollQuestion.text,
        pollOptions: _pollOptions.map((option) => option.text).toList(),
      ),
    );
  }

  bool get _hasContent {
    return _updateText.text.trim().isNotEmpty ||
        _complaintTitle.text.trim().isNotEmpty ||
        _complaintDescription.text.trim().isNotEmpty ||
        _pollQuestion.text.trim().isNotEmpty ||
        _pollOptions.any((option) => option.text.trim().isNotEmpty) ||
        _media.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _CreateTopBar(
                  tab: _tab,
                  canPost: _canPost && !_isSubmitting,
                  isSubmitting: _isSubmitting,
                  onClose: () => Navigator.pop(context),
                  onPost: _canPost && !_isSubmitting ? _submit : null,
                  onTab: _switchTab,
                ),
                _PublisherRow(audience: _audience, onAudience: _pickAudience),
                Expanded(
                  child: IndexedStack(
                    index: _tab.index,
                    children: [
                      _buildUpdateTab(),
                      _buildComplaintTab(),
                      _buildPollTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _switchTab(CreatePostTab tab) async {
    if (tab == _tab) return;
    if (_hasContent) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.colors.surface,
          title: Text(
            'Discard changes?',
            style: TextStyle(color: context.colors.ink),
          ),
          content: Text(
            'Switching post type will clear the current form.',
            style: TextStyle(color: context.colors.inkMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard != true) return;
      _clearForms();
    }
    setState(() => _tab = tab);
  }

  void _clearForms() {
    _updateText.clear();
    _complaintTitle.clear();
    _complaintDescription.clear();
    _complaintLocation.clear();
    _pollQuestion.clear();
    for (final option in _pollOptions) {
      option.clear();
    }
    _media.clear();
    _location = null;
    _tag = null;
    _anonymousComplaint = false;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final mediaPaths = _mediaPaths();
    final notifier = ref.read(feedProvider.notifier);
    try {
      switch (_tab) {
        case CreatePostTab.update:
          await notifier.addUpdatePost(
            text: _updateText.text.trim(),
            mediaUrls: mediaPaths,
            locationName: _location,
            category: _tag,
          );
          break;
        case CreatePostTab.complaint:
          await notifier.addComplaintPost(
            title: _complaintTitle.text.trim(),
            description: _complaintDescription.text.trim(),
            category: _complaintCategory,
            locationName: _complaintLocation.text.trim(),
            mediaUrls: mediaPaths,
            isAnonymous: _anonymousComplaint,
          );
          break;
        case CreatePostTab.poll:
          await notifier.addPollPost(
            question: _pollQuestion.text.trim(),
            options: _pollOptions
                .map((option) => option.text.trim())
                .where((text) => text.isNotEmpty)
                .toList(),
            mediaUrls: mediaPaths,
            allowAnonymous: _allowAnonymousVotes,
            visibility: _pollVisibility,
          );
          break;
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('${_tabLabel(_tab)} posted to feed.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post failed: $error')),
      );
    }
  }

  List<String> _mediaPaths() {
    return _media
        .map((file) => file.path)
        .whereType<String>()
        .where((path) => path.trim().isNotEmpty)
        .toList();
  }

  Widget _buildUpdateTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _updateText,
                autofocus: true,
                maxLength: 500,
                maxLines: null,
                minLines: 6,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: context.colors.inkMuted),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_location != null)
                    _RemovableChip(
                      label: _location!,
                      icon: Icons.location_on_rounded,
                      color: context.colors.teal,
                      onRemove: () => setState(() => _location = null),
                    ),
                  if (_tag != null)
                    _RemovableChip(
                      label: _tag!,
                      icon: Icons.sell_rounded,
                      color: context.colors.purple,
                      onRemove: () => setState(() => _tag = null),
                    ),
                ],
              ),
              if (_media.isNotEmpty) ...[
                const SizedBox(height: 14),
                _MediaPreviewStrip(media: _media, onRemove: _removeMedia),
              ],
            ],
          ),
        ),
        _UpdateToolbar(
          count: _updateText.text.length,
          onMedia: () => _pickMedia(4),
          onLocation: _addLocation,
          onTag: _pickTag,
        ),
      ],
    );
  }

  Widget _buildComplaintTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SheetTextField(
          controller: _complaintTitle,
          hint: 'Complaint title (required)',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 8),
        _SheetTextField(
          controller: _complaintDescription,
          hint: 'Describe the issue in detail...',
          minLines: 4,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _SheetSelectRow(
          label: 'Category',
          value: _complaintCategory,
          values: const [
            'Infrastructure',
            'Education',
            'Sports',
            'Politics',
            'Healthcare',
            'Environment',
            'Other',
          ],
          onChanged: (value) => setState(() => _complaintCategory = value),
        ),
        const SizedBox(height: 12),
        _InlineActionRow(
          icon: Icons.location_on_rounded,
          label: _complaintLocation.text.isEmpty
              ? 'Add location'
              : _complaintLocation.text,
          onTap: () async {
            final value = await _promptText('Add location name');
            if (value != null) setState(() => _complaintLocation.text = value);
          },
        ),
        const SizedBox(height: 12),
        _InlineActionRow(
          icon: Icons.add_photo_alternate_rounded,
          label: 'Add Photos/Videos',
          onTap: () => _pickMedia(5),
        ),
        if (_media.isNotEmpty) ...[
          const SizedBox(height: 12),
          _MediaPreviewStrip(media: _media, onRemove: _removeMedia),
        ],
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _anonymousComplaint,
          onChanged: (value) => setState(() => _anonymousComplaint = value),
          secondary: Icon(
            Icons.person_off_rounded,
            color: context.colors.inkMuted,
          ),
          title: Text(
            'Post Anonymously',
            style: TextStyle(
              color: context.colors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_anonymousComplaint)
          Text(
            'Your identity will be hidden from other users',
            style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
          ),
        const SizedBox(height: 12),
        const _InfoChip(text: 'Status will be set to Open automatically'),
      ],
    );
  }

  Widget _buildPollTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SheetTextField(
          controller: _pollQuestion,
          hint: 'Ask a question...',
          minLines: 2,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _InlineActionRow(
          icon: Icons.image_rounded,
          label: 'Add image (optional)',
          onTap: () => _pickMedia(1),
        ),
        const SizedBox(height: 16),
        Text(
          'Poll Options',
          style: TextStyle(
            color: context.colors.inkMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < _pollOptions.length; i++) ...[
          _PollOptionField(
            controller: _pollOptions[i],
            canRemove: _pollOptions.length > 2,
            onChanged: () => setState(() {}),
            onRemove: () => setState(() {
              final removed = _pollOptions.removeAt(i);
              removed.dispose();
            }),
          ),
          const SizedBox(height: 8),
        ],
        if (_pollOptions.length < 10)
          TextButton.icon(
            onPressed: () {
              setState(() => _pollOptions.add(TextEditingController()));
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add option'),
            style: TextButton.styleFrom(foregroundColor: context.colors.purple),
          ),
        const SizedBox(height: 12),
        _PollSettings(
          open: _pollSettingsOpen,
          allowAnonymous: _allowAnonymousVotes,
          visibility: _pollVisibility,
          onToggleOpen: () {
            setState(() => _pollSettingsOpen = !_pollSettingsOpen);
          },
          onAnonymous: (value) => setState(() => _allowAnonymousVotes = value),
          onVisibility: (value) => setState(() => _pollVisibility = value),
        ),
      ],
    );
  }

  Future<void> _pickMedia(int maxFiles) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: maxFiles > 1,
      type: FileType.media,
    );
    if (result == null) return;
    final validation = _mediaPolicy.validate(
      existingFiles: _media,
      selectedFiles: result.files,
      maxFiles: maxFiles,
    );
    setState(() {
      _media.addAll(validation.accepted);
    });
    if (validation.hasRejected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.rejected.take(2).join('\n')),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _removeMedia(PlatformFile file) {
    setState(() => _media.remove(file));
  }

  Future<void> _addLocation() async {
    final value = await _promptText('Add location name');
    if (value != null && value.trim().isNotEmpty) {
      setState(() => _location = value.trim());
    }
  }

  Future<void> _pickTag() async {
    final tags = ['Academic', 'Sports', 'Election', 'Finance', 'Local'];
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final tag in tags)
              ListTile(
                title: Text(tag, style: TextStyle(color: context.colors.ink)),
                onTap: () => Navigator.pop(context, tag),
              ),
          ],
        ),
      ),
    );
    if (value != null) setState(() => _tag = value);
  }

  Future<void> _pickAudience() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final audience in ['Public', 'Followers', 'Private'])
              ListTile(
                title: Text(
                  audience,
                  style: TextStyle(color: context.colors.ink),
                ),
                onTap: () => Navigator.pop(context, audience),
              ),
          ],
        ),
      ),
    );
    if (value != null) setState(() => _audience = value);
  }

  Future<String?> _promptText(String title) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(title, style: TextStyle(color: context.colors.ink)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: context.colors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  String _tabLabel(CreatePostTab tab) {
    switch (tab) {
      case CreatePostTab.update:
        return 'Update';
      case CreatePostTab.complaint:
        return 'Complaint';
      case CreatePostTab.poll:
        return 'Poll';
    }
  }
}

class _ComposerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ComposerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _CreateTopBar extends StatelessWidget {
  final CreatePostTab tab;
  final bool canPost;
  final bool isSubmitting;
  final VoidCallback onClose;
  final VoidCallback? onPost;
  final ValueChanged<CreatePostTab> onTab;

  const _CreateTopBar({
    required this.tab,
    required this.canPost,
    this.isSubmitting = false,
    required this.onClose,
    required this.onPost,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 12, 8),
      child: Row(
        children: [
          IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in CreatePostTab.values)
                    Expanded(
                      child: _CreateTabButton(
                        label: _label(item),
                        active: item == tab,
                        onTap: () => onTab(item),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onPost,
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.purple,
              disabledBackgroundColor: context.colors.surfaceAlt,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }

  String _label(CreatePostTab tab) {
    switch (tab) {
      case CreatePostTab.update:
        return 'Update';
      case CreatePostTab.complaint:
        return 'Complaint';
      case CreatePostTab.poll:
        return 'Poll';
    }
  }
}

class _CreateTabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CreateTabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        height: 32,
        decoration: BoxDecoration(
          color: active ? context.colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : context.colors.inkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PublisherRow extends StatelessWidget {
  final String audience;
  final VoidCallback onAudience;

  const _PublisherRow({required this.audience, required this.onAudience});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: context.colors.surfaceAlt,
            child: Icon(Icons.person_rounded, color: context.colors.inkMuted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ResultHub User',
              style: TextStyle(
                color: context.colors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onAudience,
            style: TextButton.styleFrom(foregroundColor: context.colors.purple),
            child: Text('$audience v'),
          ),
        ],
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final VoidCallback onChanged;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      onChanged: (_) => onChanged(),
      style: TextStyle(
        color: context.colors.ink,
        fontSize: minLines == 1 ? 15 : 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.inkMuted),
        filled: true,
        fillColor: context.colors.surfaceAlt,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SheetSelectRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _SheetSelectRow({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: context.colors.inkMuted)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: context.colors.surface,
              style: TextStyle(color: context.colors.ink),
              items: values
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InlineActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.colors.purple, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.colors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.add_rounded, color: context.colors.inkMuted),
          ],
        ),
      ),
    );
  }
}

class _MediaPreviewStrip extends StatelessWidget {
  final List<PlatformFile> media;
  final ValueChanged<PlatformFile> onRemove;

  const _MediaPreviewStrip({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final file = media[index];
          return Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                clipBehavior: Clip.hardEdge,
                child: file.path == null
                    ? Icon(Icons.image_rounded, color: context.colors.inkMuted)
                    : Image.file(
                        File(file.path!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_rounded,
                          color: context.colors.inkMuted,
                        ),
                      ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: GestureDetector(
                  onTap: () => onRemove(file),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: context.colors.ink,
                    child: Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: context.colors.surface,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UpdateToolbar extends StatelessWidget {
  final int count;
  final VoidCallback onMedia;
  final VoidCallback onLocation;
  final VoidCallback onTag;

  const _UpdateToolbar({
    required this.count,
    required this.onMedia,
    required this.onLocation,
    required this.onTag,
  });

  @override
  Widget build(BuildContext context) {
    final warning = count >= 450;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMedia,
            icon: Icon(Icons.photo_library_rounded, color: context.colors.teal),
          ),
          IconButton(
            onPressed: onLocation,
            icon: Icon(Icons.location_on_rounded, color: context.colors.purple),
          ),
          IconButton(
            onPressed: onTag,
            icon: Icon(Icons.sell_rounded, color: context.colors.amber),
          ),
          const Spacer(),
          Text(
            '$count/500',
            style: TextStyle(
              color: warning ? context.colors.liveRed : context.colors.inkMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onRemove;

  const _RemovableChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      onDeleted: onRemove,
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: context.colors.ink,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.colors.inkMuted,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: context.colors.inkMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollOptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _PollOptionField({
    required this.controller,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Icon(Icons.drag_indicator_rounded, color: context.colors.inkMuted),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: TextStyle(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: 'Option',
                hintStyle: TextStyle(color: context.colors.inkMuted),
                filled: true,
                fillColor: context.colors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, color: context.colors.inkMuted),
            ),
        ],
      ),
    );
  }
}

class _PollSettings extends StatelessWidget {
  final bool open;
  final bool allowAnonymous;
  final String visibility;
  final VoidCallback onToggleOpen;
  final ValueChanged<bool> onAnonymous;
  final ValueChanged<String> onVisibility;

  const _PollSettings({
    required this.open,
    required this.allowAnonymous,
    required this.visibility,
    required this.onToggleOpen,
    required this.onAnonymous,
    required this.onVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Poll Settings',
              style: TextStyle(
                color: context.colors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: Icon(
              open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
            onTap: onToggleOpen,
          ),
          if (open) ...[
            SwitchListTile(
              value: allowAnonymous,
              onChanged: onAnonymous,
              title: Text(
                'Allow anonymous votes',
                style: TextStyle(color: context.colors.ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SheetSelectRow(
                label: 'Visibility',
                value: visibility,
                values: const ['Public', 'Password Protected', 'Private'],
                onChanged: onVisibility,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
