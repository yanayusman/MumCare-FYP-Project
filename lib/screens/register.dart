import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      await AuthService.instance.signInWithGoogle();
      if (!context.mounted) return;
      Navigator.pushNamed(context, '/profile-setup'); // ← changed
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Illustration ──
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFE8E0),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/mumcare_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── App Name ──
                const Text(
                  'MumCare',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3728),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Tagline ──
                const Text(
                  'Welcome to MumCare',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9B8070),
                  ),
                ),
                const Text(
                  'Your pregnancy journey companion',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9B8070),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Continue with Email ──
                _AuthButton(
                  label: 'Continue with E-Mail',
                  icon: Icons.email_outlined,
                  onTap: () => Navigator.pushNamed(context, '/profile-setup'),
                ),

                const SizedBox(height: 14),

                // ── Continue with Google ──
                _AuthButton(
                  label: 'Continue with Google',
                  customIcon: Image.asset(
                    'assets/images/google_logo.png',
                    width: 20,
                    height: 20,
                  ),
                  onTap: () {
                    _handleGoogleSignIn(context);
                  },
                ),

                const SizedBox(height: 28),

                // ── Sign Up Link ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9B8070),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Sign in',
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
        ),
      ),
    );
  }
}

// ── Reusable Auth Button ──────────────────────────────────────
class _AuthButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A3728),
          side: const BorderSide(color: Color(0xFFD4C4B8), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null) customIcon!
            else Icon(icon, size: 20, color: const Color(0xFF9B8070)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}