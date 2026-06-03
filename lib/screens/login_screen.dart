import 'package:flutter/material.dart';
import 'admin/admin_scaffold.dart';
import 'signup_screen.dart';
import 'main_scaffold.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isStudent = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();

  final _orgCodeController = TextEditingController();
  final _orgEmailController = TextEditingController();
  final _orgPasswordController = TextEditingController();

  @override
  void dispose() {
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    _orgCodeController.dispose();
    _orgEmailController.dispose();
    _orgPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _isStudent ? _studentEmailController.text.trim() : _orgEmailController.text.trim();
    final password = _isStudent ? _studentPasswordController.text.trim() : _orgPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all credentials'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call Firebase Auth
    final error = await AuthService().login(email: email, password: password);

    if (!mounted) return;
    
    setState(() => _isLoading = false);

    if (error == null) {
      // Success! Route to respective dashboard
      if (_isStudent) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScaffold()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AdminScaffold()), (route) => false);
      }
    } else {
      // Show Error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    
    final error = await AuthService().signInWithGoogle();
    
    if (!mounted) return;
    
    setState(() => _isGoogleLoading = false);

    if (error == null) {
      // Success! Route to Student Dashboard (Assuming Google Sign-In is for students)
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScaffold()), (route) => false);
    } else {
      if (error != 'Sign-In canceled.') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                _isStudent ? 'Welcome Back' : 'Partner Portal',
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
              ),
              const SizedBox(height: 8),
              Text(
                _isStudent 
                    ? 'Login to track your results and save exams.' 
                    : 'Login to publish results and manage your organization.',
                style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              // Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isStudent = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isStudent ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isStudent ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Student',
                            style: TextStyle(
                              color: _isStudent ? const Color(0xFF0F172A) : Colors.grey,
                              fontWeight: _isStudent ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isStudent = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isStudent ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isStudent ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Organization',
                            style: TextStyle(
                              color: !_isStudent ? const Color(0xFF0F172A) : Colors.grey,
                              fontWeight: !_isStudent ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isStudent ? _buildStudentForm() : _buildOrgForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentForm() {
    return Column(
      key: const ValueKey('student'),
      children: [
        _buildTextField('Email', Icons.email_outlined, _studentEmailController),
        const SizedBox(height: 16),
        _buildTextField('Password', Icons.lock_outline, _studentPasswordController, isPassword: true),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
            },
            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton('Login'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade200)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            Expanded(child: Divider(color: Colors.grey.shade200)),
          ],
        ),
        const SizedBox(height: 24),
        _buildGoogleButton(),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
              children: [
                const TextSpan(text: "Don't have an account? "),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                    },
                    child: const Text('Sign up', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrgForm() {
    return Column(
      key: const ValueKey('org'),
      children: [
        _buildTextField('Organization ID / Code', Icons.business, _orgCodeController),
        const SizedBox(height: 16),
        _buildTextField('Admin Email', Icons.email_outlined, _orgEmailController),
        const SizedBox(height: 16),
        _buildTextField('Admin Password', Icons.lock_outline, _orgPasswordController, isPassword: true),
        const SizedBox(height: 32),
        _buildPrimaryButton('Access Dashboard'),
        const SizedBox(height: 24),
        const Center(
          child: Text('Want to register your organization?', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Contact Support', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900)),
        )
      ],
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
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
    );
  }

  Widget _buildPrimaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        child: _isGoogleLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('G', style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
                  SizedBox(width: 12),
                  Text('Continue with Google', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
      ),
    );
  }
}
