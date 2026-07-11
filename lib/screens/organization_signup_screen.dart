import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class OrganizationSignupScreen extends ConsumerStatefulWidget {
  const OrganizationSignupScreen({super.key});

  @override
  ConsumerState<OrganizationSignupScreen> createState() =>
      _OrganizationSignupScreenState();
}

class _OrganizationSignupScreenState
    extends ConsumerState<OrganizationSignupScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedOrgType = 'School / College';

  final List<String> _orgTypes = [
    'School / College',
    'Coaching Center / Tuition',
    'Sports Club / Tournament',
    'Corporate / Company',
    'Government Body',
    'Media / News',
    'Other',
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();
    final website = _websiteController.text.trim();
    final city = _cityController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an email and password.'),
          backgroundColor: context.colors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match.'),
          backgroundColor: context.colors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService().signUpOrganization(
      name: _nameController.text.trim(),
      organizationType: _selectedOrgType,
      email: email,
      password: password,
      phoneNumber: phone.isNotEmpty ? phone : null,
      website: website.isNotEmpty ? website : null,
      city: city.isNotEmpty ? city : null,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      await ref.read(authProvider.notifier).checkAuthStatus();
      if (!mounted) return;
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: context.colors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: context.colors.ink,
                        ),
                        onPressed: () async {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            final done = prefs.getBool('onboarding_done') ?? false;
                            if (context.mounted) {
                              context.go(done ? '/' : '/onboarding');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Hero(
                      tag: 'auth_icon_org',
                      child: Icon(
                        Icons.business_center,
                        size: 64,
                        color: context.colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Organization Signup',
                      style: TextStyle(
                        color: context.colors.ink,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publish results and manage your community.',
                      style: TextStyle(
                        color: context.colors.inkMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Form Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.colors.surface.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: context.colors.border.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'Organization Name',
                                controller: _nameController,
                                icon: Icons.business,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: context.colors.border.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedOrgType,
                                    isExpanded: true,
                                    dropdownColor: context.colors.surface,
                                    style: TextStyle(
                                      color: context.colors.ink,
                                      fontSize: 16,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: context.colors.inkMuted,
                                    ),
                                    items: _orgTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedOrgType = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Official Email',
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Website / Social Link (Optional)',
                                controller: _websiteController,
                                icon: Icons.link,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'City / Location',
                                controller: _cityController,
                                icon: Icons.location_city,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Password',
                                controller: _passwordController,
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: context.colors.orange
                                        .withValues(alpha: 0.4),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Text(
                                          'CREATE ACCOUNT',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'By signing up, you agree to our ',
                          style: TextStyle(
                            color: context.colors.inkMuted,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: context.colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.colors.inkMuted,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: context.colors.inkMuted),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: context.colors.inkMuted,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: context.colors.bg.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colors.orange, width: 2),
        ),
      ),
    );
  }
}
