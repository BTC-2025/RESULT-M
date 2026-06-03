import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateWorkspaceScreen extends StatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  State<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends State<CreateWorkspaceScreen> {
  int _selectedVisibility = 0; // 0=Public, 1=Password, 2=Private
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCategory = 'Sports';
  bool _isCreating = false;

  final List<String> _categories = ['Sports', 'Education', 'Corporate', 'Gaming', 'Elections', 'Other'];

  final List<Map<String, dynamic>> _visibilityOptions = [
    {'icon': Icons.public, 'label': 'Public', 'desc': 'Anyone can search and view this workspace', 'color': const Color(0xFF10B981)},
    {'icon': Icons.lock_open, 'label': 'Password Protected', 'desc': 'Share link + passcode for access', 'color': const Color(0xFFF59E0B)},
    {'icon': Icons.lock, 'label': 'Private', 'desc': 'Only whitelisted users can view', 'color': const Color(0xFFEF4444)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a workspace title')));
      return;
    }
    setState(() => _isCreating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isCreating = false);

    // Generate a shareable link
    final link = 'resulthub.app/w/${_titleController.text.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Workspace Created! 🎉', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your shareable link:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(child: Text(link, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Link copied!')));
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('CREATE WORKSPACE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text('WORKSPACE DETAILS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildTextField(_titleController, 'Workspace Title', 'e.g. Putlur Local Cricket Finals', Icons.title),
            const SizedBox(height: 12),
            _buildTextField(_descController, 'Description (optional)', 'Brief description of results...', Icons.description, maxLines: 2),
            const SizedBox(height: 12),
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: const Text('Select Category'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Visibility Selector
            const Text('VISIBILITY & ACCESS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ..._visibilityOptions.asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final isSelected = _selectedVisibility == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedVisibility = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? (opt['color'] as Color).withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? opt['color'] as Color : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (opt['color'] as Color).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt['label'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? opt['color'] as Color : const Color(0xFF0F172A))),
                            Text(opt['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: opt['color'] as Color),
                    ],
                  ),
                ),
              );
            }),

            // Password field if protected
            if (_selectedVisibility == 1) ...[
              const SizedBox(height: 8),
              _buildTextField(_passwordController, 'Set Access Passcode', 'e.g. CRICKET2026', Icons.key, obscure: true),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isCreating ? null : _createWorkspace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isCreating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.rocket_launch, color: Colors.white),
                label: Text(_isCreating ? 'Creating...' : 'CREATE WORKSPACE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {int maxLines = 1, bool obscure = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F172A))),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
