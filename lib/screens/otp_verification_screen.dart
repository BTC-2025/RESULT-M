import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import 'reset_password_screen.dart';

enum OtpFlow { signup, forgotPassword }

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final OtpFlow flow;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.flow = OtpFlow.forgotPassword,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the 6-digit OTP')));
      return;
    }

    setState(() => _isLoading = true);
    
    String? error;
    if (widget.flow == OtpFlow.signup) {
      error = await AuthService().verifySignupOtp(email: widget.email, otp: otp);
    } else {
      error = await AuthService().verifyOtp(email: widget.email, otp: otp);
    }
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      if (widget.flow == OtpFlow.signup) {
        await ref.read(authProvider.notifier).checkAuthStatus();
        if (mounted) context.go('/');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: widget.email, otp: otp)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    
    String? error;
    if (widget.flow == OtpFlow.signup) {
      // NOTE: For signup, there currently isn't a dedicated resend endpoint.
      // But we can just call signUp again to regenerate and resend the OTP.
      // However, we don't have the original password here. So we just show an error.
      error = "Resend not supported during signup yet. Please go back and sign up again.";
    } else {
      error = await AuthService().forgotPassword(widget.email);
    }
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP resent! Check the console output.'),
        backgroundColor: Colors.green,
      ));
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text('Verify OTP', style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink)),
        backgroundColor: context.colors.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read_outlined, size: 80, color: context.colors.orange),
                const SizedBox(height: 24),
                Text(
                  'Enter the 6-digit code sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.ink),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _otpController,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold, color: context.colors.ink),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: context.colors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.orange, width: 2)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('VERIFY OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive code? ", style: TextStyle(color: context.colors.inkMuted)),
                    if (_secondsRemaining > 0)
                      Text("Resend in ${_secondsRemaining}s", style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.ink))
                    else
                      TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        child: Text('Resend OTP', style: TextStyle(color: context.colors.orange, fontWeight: FontWeight.bold)),
                      )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
