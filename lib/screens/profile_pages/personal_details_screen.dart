import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import '../../services/user_service.dart';
import '../../providers/auth_provider.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _storage = SecureStorage();
  final _userService = UserService();
  bool _isLoading = true;
  
  String? _profilePictureBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStoredProfile();
  }

  Future<void> _loadStoredProfile() async {
    setState(() => _isLoading = true);

    // Load from local storage first for immediate display
    final name = await _storage.getName();
    final email = await _storage.getEmail();
    final cachedPic = await _storage.getProfilePicture();
    
    if (!mounted) return;
    setState(() {
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
      _profilePictureBase64 = cachedPic;
    });

    // Fetch full profile from API
    final profile = await _userService.getMyProfile();
    if (mounted && profile != null) {
      setState(() {
        _nameController.text = profile['name'] ?? name ?? '';
        _emailController.text = profile['email'] ?? email ?? '';
        _phoneController.text = profile['phoneNumber'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _websiteController.text = profile['website'] ?? '';
        if (profile['profilePictureBase64'] != null) {
          _profilePictureBase64 = profile['profilePictureBase64'];
        }
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        
        // Add data URI scheme
        final mimeType = image.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64String';
        
        setState(() {
          _profilePictureBase64 = dataUri;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Future<void> _saveDetails() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();
    final website = _websiteController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updateMyProfile(
        name: name, 
        phoneNumber: phone,
        profilePictureBase64: _profilePictureBase64,
        bio: bio,
        website: website,
      );
      
      // Update global auth state so the new picture propagates
      await ref.read(authProvider.notifier).checkAuthStatus();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully!')),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAvatar() {
    if (_profilePictureBase64 != null && _profilePictureBase64!.startsWith('data:image')) {
      try {
        final base64Str = _profilePictureBase64!.split(',').last;
        final bytes = base64Decode(base64Str);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        );
      } catch (e) {
        // Fallback on error
      }
    }
    
    return const Icon(
      Icons.person,
      size: 48,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Personal Details',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 4),
                      ),
                      child: _buildAvatar(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form
            _buildTextField('Full Name', Icons.person_outline, _nameController),
            const SizedBox(height: 16),
            _buildTextField(
              'Email Address',
              Icons.email_outlined,
              _emailController,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Phone Number',
              Icons.phone_outlined,
              _phoneController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Bio',
              Icons.info_outline,
              _bioController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Website',
              Icons.link_outlined,
              _websiteController,
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: readOnly
                ? Colors.grey.shade100
                : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
