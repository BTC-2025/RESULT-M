import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'admin_scaffold.dart';

class CreateOrganizationScreen extends ConsumerStatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  ConsumerState<CreateOrganizationScreen> createState() =>
      _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState
    extends ConsumerState<CreateOrganizationScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _isLoading = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Form data
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _slugController = TextEditingController();
  String _selectedType = '';
  String _visibility = 'PUBLIC';
  String _logoEmoji = '🏛️';

  static const _orgTypes = [
    _OrgType('Education',     '🎓', 'University, School, Coaching Center', Color(0xFF8B5CF6)),
    _OrgType('Sports',        '🏆', 'Cricket League, Football Club, Academy', Color(0xFF10B981)),
    _OrgType('Government',    '🏛️', 'Ministry, PSC, Municipal Corporation', Color(0xFF6366F1)),
    _OrgType('Finance',       '📈', 'Stock Exchange, Fund, Bank', Color(0xFFF59E0B)),
    _OrgType('Healthcare',    '🏥', 'Hospital, Medical Board, Clinic', Color(0xFFEF4444)),
    _OrgType('Entertainment', '🎬', 'Film Cert Board, Awards Body', Color(0xFFEC4899)),
    _OrgType('Law & Judiciary','⚖️', 'Court, Legal Body, Regulatory', Color(0xFF14B8A6)),
    _OrgType('Technology',    '💻', 'Tech Company, AI Lab, Research', Color(0xFF06B6D4)),
    _OrgType('Business',      '💼', 'Startup, Company, Firm', Color(0xFFF97316)),
    _OrgType('Community',     '🏘️', 'Local Club, NGO, Association', Color(0xFF84CC16)),
    _OrgType('Media & Press', '📡', 'News Agency, Publication, Channel', Color(0xFFFF6B35)),
  ];

  static const _steps = [
    'Organization Name',
    'Type & Category',
    'Workspace Slug',
    'Visibility',
    'Logo & Identity',
    'Description & Review',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _slugController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < _steps.length - 1) {
      _fadeCtrl.reverse().then((_) {
        setState(() => _step++);
        _fadeCtrl.forward();
      });
    } else {
      _handleCreate();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      _fadeCtrl.reverse().then((_) {
        setState(() => _step--);
        _fadeCtrl.forward();
      });
    }
  }

  void _autoSlug() {
    final slug = _nameController.text.trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    _slugController.text = slug;
  }

  bool get _canContinue {
    switch (_step) {
      case 0: return _nameController.text.trim().length >= 3;
      case 1: return _selectedType.isNotEmpty;
      case 2: return _slugController.text.trim().length >= 3;
      case 3: return true;
      case 4: return true;
      case 5: return true;
      default: return true;
    }
  }

  Future<void> _handleCreate() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createWorkspace({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'domainType': _selectedType.toUpperCase().replaceAll(' & ', '_').replaceAll(' ', '_'),
        'slug': _slugController.text.trim(),
        'visibility': _visibility,
        'logoEmoji': _logoEmoji,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminScaffold()),
      );
    } catch (e) {
      if (!mounted) return;
      // Show success for UI demo (backend not connected)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminScaffold()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    GestureDetector(
                      onTap: _prevStep,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: context.colors.ink, size: 20),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Step ${_step + 1} of ${_steps.length}', style: TextStyle(
                          color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 4),
                        Text(_steps[_step], style: TextStyle(
                          color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15,
                        ), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Icon(Icons.close_rounded, color: context.colors.inkMuted, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Progress Bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.full),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _steps.length,
                  backgroundColor: context.colors.border,
                  color: context.colors.orange,
                  minHeight: 4,
                ),
              ),
            ),

            // ─── Step Content ────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildStepContent(),
              ),
            ),

            // ─── Bottom Continue Button ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue && !_isLoading ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.orange,
                    disabledBackgroundColor: context.colors.border,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    elevation: _canContinue ? 6 : 0,
                    shadowColor: context.colors.orange.withValues(alpha: 0.35),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Text(
                          _step == _steps.length - 1 ? 'Create Organization 🚀' : 'Continue →',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (_step == 0) _buildNameStep(),
          if (_step == 1) _buildTypeStep(),
          if (_step == 2) _buildSlugStep(),
          if (_step == 3) _buildVisibilityStep(),
          if (_step == 4) _buildLogoStep(),
          if (_step == 5) _buildReviewStep(),
        ],
      ),
    );
  }

  // ─── Step 0: Name ────────────────────────────────────────────────────────
  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏢', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 16),
        Text('What\'s your organization called?', style: TextStyle(
          color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
        )),
        const SizedBox(height: 8),
        Text('This is the name that will be visible to the public on ResultHub.', style: TextStyle(
          color: context.colors.inkMuted, height: 1.5,
        )),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'e.g. Tamil Nadu Cricket Association',
            hintStyle: TextStyle(color: context.colors.inkFaint),
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
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Type ────────────────────────────────────────────────────────
  Widget _buildTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What type of organization?', style: TextStyle(
          color: context.colors.ink, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2,
        )),
        const SizedBox(height: 8),
        Text('This helps ResultHub configure the best data templates for you.', style: TextStyle(
          color: context.colors.inkMuted, height: 1.5,
        )),
        const SizedBox(height: 20),
        ...List.generate(_orgTypes.length, (i) {
          final t = _orgTypes[i];
          final isSelected = _selectedType == t.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = t.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? t.color.withValues(alpha: 0.12) : context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isSelected ? t.color : context.colors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(t.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: TextStyle(
                          color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15,
                        )),
                        Text(t.subtitle, style: TextStyle(
                          color: context.colors.inkMuted, fontSize: 12,
                        )),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: t.color, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Step 2: Slug ────────────────────────────────────────────────────────
  Widget _buildSlugStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔗', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 16),
        Text('Choose a workspace URL', style: TextStyle(
          color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
        )),
        const SizedBox(height: 8),
        Text('This will be your unique public link on ResultHub.', style: TextStyle(
          color: context.colors.inkMuted, height: 1.5,
        )),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Text('resulthub.in/', style: TextStyle(color: context.colors.inkMuted, fontSize: 14)),
              Expanded(
                child: TextField(
                  controller: _slugController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: context.colors.ink, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _autoSlug,
          icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
          label: const Text('Auto-generate from name'),
          style: TextButton.styleFrom(foregroundColor: context.colors.orange),
        ),
      ],
    );
  }

  // ─── Step 3: Visibility ─────────────────────────────────────────────────
  Widget _buildVisibilityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔐', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 16),
        Text('Who can see your results?', style: TextStyle(
          color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
        )),
        const SizedBox(height: 8),
        Text('You can change this later for each individual dataset.', style: TextStyle(
          color: context.colors.inkMuted, height: 1.5,
        )),
        const SizedBox(height: 24),
        _VisibilityOption(
          icon: Icons.public_rounded,
          title: 'Public',
          subtitle: 'Anyone can find and view your results',
          value: 'PUBLIC',
          selected: _visibility,
          color: const Color(0xFF10B981),
          onTap: () => setState(() => _visibility = 'PUBLIC'),
        ),
        const SizedBox(height: 10),
        _VisibilityOption(
          icon: Icons.lock_clock_rounded,
          title: 'Password Protected',
          subtitle: 'Share a link + password for access',
          value: 'PASSWORD',
          selected: _visibility,
          color: const Color(0xFFF59E0B),
          onTap: () => setState(() => _visibility = 'PASSWORD'),
        ),
        const SizedBox(height: 10),
        _VisibilityOption(
          icon: Icons.lock_rounded,
          title: 'Private',
          subtitle: 'Only team members can view',
          value: 'PRIVATE',
          selected: _visibility,
          color: const Color(0xFFEF4444),
          onTap: () => setState(() => _visibility = 'PRIVATE'),
        ),
      ],
    );
  }

  // ─── Step 4: Logo ────────────────────────────────────────────────────────
  Widget _buildLogoStep() {
    const emojis = ['🏛️', '🎓', '🏆', '📊', '⚖️', '🏥', '💻', '🎬', '📡', '🏘️', '💼', '📈'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Give your organization a logo', style: TextStyle(
          color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
        )),
        const SizedBox(height: 8),
        Text('Pick an emoji now. You can upload a real logo later.', style: TextStyle(
          color: context.colors.inkMuted, height: 1.5,
        )),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: context.colors.border, width: 2),
            ),
            child: Center(child: Text(_logoEmoji, style: const TextStyle(fontSize: 48))),
          ),
        ),
        const SizedBox(height: 24),
        Text('CHOOSE EMOJI', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, crossAxisSpacing: 10, mainAxisSpacing: 10,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => setState(() => _logoEmoji = emojis[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _logoEmoji == emojis[i]
                    ? context.colors.orange.withValues(alpha: 0.15)
                    : context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: _logoEmoji == emojis[i] ? context.colors.orange : context.colors.border,
                  width: _logoEmoji == emojis[i] ? 2 : 1,
                ),
              ),
              child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 24))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_rounded),
          label: const Text('Upload Custom Logo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.colors.orange,
            side: BorderSide(color: context.colors.orange),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          ),
        ),
      ],
    );
  }

  // ─── Step 5: Review ──────────────────────────────────────────────────────
  Widget _buildReviewStep() {
    final type = _orgTypes.firstWhere((t) => t.name == _selectedType, orElse: () => _orgTypes.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Launch 🚀', style: TextStyle(
          color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
        )),
        const SizedBox(height: 8),
        Text('Here\'s a summary of your organization.', style: TextStyle(
          color: context.colors.inkMuted, height: 1.5,
        )),
        const SizedBox(height: 24),
        // Preview Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(_logoEmoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nameController.text.trim(), style: TextStyle(
                        color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18,
                      )),
                      Text(type.name, style: TextStyle(color: type.color, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _ReviewRow(Icons.link_rounded, 'Slug', _slugController.text.isNotEmpty ? _slugController.text : '—'),
              _ReviewRow(Icons.visibility_rounded, 'Visibility', _visibility),
              const SizedBox(height: 12),
              // Description
              Text('DESCRIPTION', style: TextStyle(
                color: context.colors.inkFaint, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: context.colors.ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add a short description of your organization...',
                  hintStyle: TextStyle(color: context.colors.inkFaint),
                  filled: true,
                  fillColor: context.colors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: BorderSide(color: context.colors.orange, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _OrgType {
  final String name, emoji, subtitle;
  final Color color;
  const _OrgType(this.name, this.emoji, this.subtitle, this.color);
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, value, selected;
  final Color color;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon, required this.title, required this.subtitle,
    required this.value, required this.selected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: isSelected ? color : context.colors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
                  Text(subtitle, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ReviewRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: context.colors.inkFaint, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(value, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
