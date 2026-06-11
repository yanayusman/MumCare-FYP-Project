import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({super.key});

  @override
  State<RegisterEmail> createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _isEmailValid = false;
  String _emailFeedback = '';
  Color _emailFeedbackColor = const Color(0xFF9B8070);

  // ── Password strength ──
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color _strengthColor = const Color(0xFFE8DDD6);

  @override
  void initState() {
    super.initState();
    _email.addListener(_updateEmailValidation);
    _password.addListener(_updatePasswordStrength);
  }

  void _updateEmailValidation() {
    final value = _email.text.trim();

    String feedback = '';
    Color feedbackColor = const Color(0xFF9B8070);
    bool isEmailValid = false;

    if (value.isNotEmpty) {
      isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
      feedback = isEmailValid ? 'Email looks good' : 'Please enter a valid email';
      feedbackColor = isEmailValid ? const Color(0xFF81C784) : const Color(0xFFE57373);
    }

    setState(() {
      _isEmailValid = isEmailValid;
      _emailFeedback = feedback;
      _emailFeedbackColor = feedbackColor;
    });
  }

  void _updatePasswordStrength() {
    final value = _password.text;
    int score = 0;

    if (value.length >= 6) score++;
    if (value.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=]').hasMatch(value)) score++;

    String label;
    Color color;
    double strength;

    if (value.isEmpty) {
      label = '';
      color = const Color(0xFFE8DDD6);
      strength = 0;
    } else if (score <= 1) {
      label = 'Weak';
      color = const Color(0xFFE57373);
      strength = 0.25;
    } else if (score <= 2) {
      label = 'Fair';
      color = const Color(0xFFFFB74D);
      strength = 0.5;
    } else if (score <= 3) {
      label = 'Good';
      color = const Color(0xFFE8A0A0);
      strength = 0.75;
    } else {
      label = 'Strong';
      color = const Color(0xFF81C784);
      strength = 1.0;
    }

    setState(() {
      _passwordStrength = strength;
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  @override
  void dispose() {
    _email.removeListener(_updateEmailValidation);
    _password.removeListener(_updatePasswordStrength);
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await AuthService.instance.signUpWithEmail(
        _email.text.trim(),
        _password.text,
      );

      if (!mounted) return;

      // Email confirmation required — send user to login with instructions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created! Please check ${_email.text.trim()} '
            'for a confirmation link, then log in.',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back Button ──
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    size: 18, color: Color(0xFF4A3728)),
              ),

              const SizedBox(height: 24),

              // ── Title ──
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign up to start your pregnancy journey',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9B8070),
                ),
              ),

              const SizedBox(height: 36),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Email Field ──
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    if (_emailFeedback.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _isEmailValid
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            size: 16,
                            color: _emailFeedbackColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _emailFeedback,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _emailFeedbackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ── Password Field ──
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
                        final hasNumber = RegExp(r'[0-9]').hasMatch(v);
                        if (!hasLetter || !hasNumber) {
                          return 'Password must contain both letters and numbers';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'At least 6 characters, letters & numbers',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF9B8070),
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Password Strength Indicator ──
                    if (_password.text.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                minHeight: 5,
                                backgroundColor: const Color(0xFFE8DDD6),
                                valueColor:
                                    AlwaysStoppedAnimation(_strengthColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tip: use 8+ characters with uppercase, numbers & symbols',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9B8070),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ── Confirm Password Field ──
                    TextFormField(
                      controller: _confirmPassword,
                      obscureText: _obscureConfirm,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF9B8070),
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Continue Button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8A0A0),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Login Link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an Account? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9B8070),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8C6A55),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon, size: 20, color: const Color(0xFF9B8070)) : null,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9B8070)),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFC0B0A8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8A0A0), width: 1.5),
      ),
    );
  }
}