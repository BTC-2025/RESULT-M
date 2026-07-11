import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';

import '../services/api_service.dart';
import '../providers/auth_provider.dart';

enum LoginRole { personal, organization }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  LoginRole _selectedRole = LoginRole.personal;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _mfaRequired = false;
  String? _mfaToken;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mfaCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? get _returnTo {
    final value = GoRouterState.of(context).uri.queryParameters['returnTo'];
    return value == null || value.trim().isEmpty ? null : value;
  }

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_mfaRequired) {
      final code = _mfaCodeController.text.trim();
      if (code.isEmpty) {
        _showError('Please enter the MFA verification code');
        return;
      }

      setState(() => _isLoading = true);
      final error = await AuthService().verifyMfaLogin(
        mfaToken: _mfaToken!,
        code: code,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error == null) {
        await _onLoginSuccess();
      } else {
        _showError(error);
      }
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all credentials');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService().login(email: email, password: password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      await _onLoginSuccess();
    } else if (result is Map && result['mfaRequired'] == true) {
      setState(() {
        _mfaRequired = true;
        _mfaToken = result['mfaToken'];
      });
    } else if (result is String) {
      _showError(result);
    } else {
      _showError('An unknown error occurred.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.liveRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onLoginSuccess() async {
    await ref.read(authProvider.notifier).checkAuthStatus();
    if (!mounted) return;

    final authState = ref.read(authProvider);
    final userRole = authState.role;

    if (_selectedRole == LoginRole.personal) {
      if (userRole == 'ORGANIZATION') {
        await ref.read(authProvider.notifier).logout();
        _showError('Access Denied: Organization accounts cannot log in as personal users.');
        return;
      }

      final returnTo = _returnTo;
      if (returnTo != null) {
        if (GoRouter.of(context).canPop()) {
          context.pop(true);
        } else {
          context.go(returnTo);
        }
        return;
      }
      context.go('/');
    } else {
      if (userRole == 'USER') {
        await ref.read(authProvider.notifier).logout();
        _showError('Access Denied: Standard user accounts cannot log in as organizations.');
        return;
      }

      final returnTo = _returnTo;
      if (returnTo != null) {
        if (GoRouter.of(context).canPop()) {
          context.pop(true);
        } else {
          context.go(returnTo);
        }
        return;
      }

      try {
        final apiService = ref.read(apiServiceProvider);
        final workspaces = await apiService.fetchMyWorkspaces();

        if (!mounted) return;
        if (workspaces.isEmpty) {
          context.go('/create-organization');
        } else {
          context.go('/admin/dashboard');
        }
      } catch (e) {
        if (!mounted) return;
        _showError('Error loading profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final isVeryNarrow = constraints.maxWidth < 400;
          return Stack(
            children: [
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: isWide ? _buildWideLayout() : _buildNarrowLayout(isVeryNarrow),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(bool isVeryNarrow) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isVeryNarrow ? 16.0 : 24.0,
            vertical: isVeryNarrow ? 24.0 : 40.0,
          ),
          child: _buildFormContent(isWide: false, isVeryNarrow: isVeryNarrow),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left Branding Side
        Expanded(
          child: Container(
            color: context.colors.surfaceAlt,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'auth_icon',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.orange.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 96,
                        color: context.colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ResultHub',
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your academic success, simplified.',
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right Form Side
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                child: _buildFormContent(isWide: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent({required bool isWide, bool isVeryNarrow = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
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
                if (mounted) {
                  context.go(done ? '/' : '/onboarding');
                }
              }
            },
          ),
        ),
        const SizedBox(height: 24),

        if (!isWide) ...[
          // Premium glowing graphic for narrow/mobile
          Center(
            child: Hero(
              tag: 'auth_icon',
              child: Container(
                height: isVeryNarrow ? 110 : 140,
                width: isVeryNarrow ? 110 : 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.colors.orange.withValues(alpha: 0.3),
                      context.colors.orange.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: isVeryNarrow ? 65 : 85,
                      width: isVeryNarrow ? 65 : 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.orange.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.orange.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.emoji_events_rounded,
                      size: isVeryNarrow ? 36 : 48,
                      color: context.colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isVeryNarrow ? 16 : 24),
        ],

        Text(
          'Welcome Back',
          style: TextStyle(
            color: context.colors.ink,
            fontSize: isVeryNarrow ? 28 : 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to access your dashboard.',
          style: TextStyle(
            color: context.colors.inkMuted,
            fontSize: isVeryNarrow ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isVeryNarrow ? 24 : 48),

        // Role Selector
        _buildRoleSelector(),
        const SizedBox(height: 32),

        // Glassmorphic Form Card
        ClipRRect(
          borderRadius: BorderRadius.circular(isVeryNarrow ? 16 : 24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(isVeryNarrow ? 16 : 24),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: context.colors.border.withValues(alpha: 0.5),
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
                  if (!_mfaRequired) ...[
                    _buildTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      isVeryNarrow: isVeryNarrow,
                    ),
                    SizedBox(height: isVeryNarrow ? 12 : 20),
                    _buildTextField(
                      label: 'Password',
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVeryNarrow: isVeryNarrow,
                    ),
                    SizedBox(height: isVeryNarrow ? 12 : 16),
                    
                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() => _rememberMe = val ?? false);
                                },
                                activeColor: context.colors.orange,
                                side: BorderSide(color: context.colors.inkMuted),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                color: context.colors.ink,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: context.colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildTextField(
                      label: 'MFA Verification Code',
                      controller: _mfaCodeController,
                      icon: Icons.security,
                      isVeryNarrow: isVeryNarrow,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code from your authenticator app.',
                      style: TextStyle(
                        color: context.colors.inkMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  SizedBox(height: isVeryNarrow ? 16 : 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: isVeryNarrow ? 48 : 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: context.colors.orange.withValues(alpha: 0.4),
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
                          : Text(
                              _mfaRequired ? 'VERIFY OTP' : 'SIGN IN',
                              style: const TextStyle(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account?',
              style: TextStyle(
                color: context.colors.inkMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: () {
                if (_selectedRole == LoginRole.personal) {
                  context.push('/signup');
                } else {
                  context.push('/signup/organization');
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: context.colors.orange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildRoleTab('Personal', LoginRole.personal),
          _buildRoleTab('Organization', LoginRole.organization),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String title, LoginRole role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? context.colors.ink : context.colors.inkMuted,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isVeryNarrow = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: TextStyle(
        color: context.colors.ink, 
        fontWeight: FontWeight.w600,
        fontSize: isVeryNarrow ? 14 : 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.colors.inkMuted,
          fontWeight: FontWeight.w500,
          fontSize: isVeryNarrow ? 14 : 16,
        ),
        contentPadding: isVeryNarrow 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12) 
            : null,
        prefixIcon: Icon(icon, color: context.colors.inkMuted, size: isVeryNarrow ? 20 : 24),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: context.colors.inkMuted,
                  size: isVeryNarrow ? 20 : 24,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: context.colors.bg.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isVeryNarrow ? 12 : 16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isVeryNarrow ? 12 : 16),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isVeryNarrow ? 12 : 16),
          borderSide: BorderSide(color: context.colors.orange, width: 2),
        ),
      ),
    );
  }
}
