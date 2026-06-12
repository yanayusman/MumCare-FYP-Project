// lib/screens/privacy_security_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);

const _kBiometricPrefKey = 'biometric_login_enabled';

class PrivacySecurity extends StatefulWidget {
  const PrivacySecurity({super.key});

  @override
  State<PrivacySecurity> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurity> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _biometricEnabled = false;
  bool _isEmailAccount = true; // email/password vs Google OAuth

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool(_kBiometricPrefKey) ?? false;

    final user = _supabase.auth.currentUser;
    final providers = user?.appMetadata['providers'] as List? ?? const [];
    _isEmailAccount = providers.isEmpty || providers.contains('email');

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricPrefKey, value);
    setState(() => _biometricEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Biometric login enabled'
              : 'Biometric login disabled'),
        ),
      );
    }
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _ChangePasswordSheet(),
    );
  }

  Future<void> _confirmSignOutAllDevices() async {
    final confirmed = await _confirmDialog(
      title: 'Sign Out All Devices',
      message:
          'This will sign you out from this device and any other device '
          'where you are currently logged in. Continue?',
      confirmLabel: 'Sign Out All',
    );
    if (!confirmed) return;

    try {
      await _supabase.auth.signOut(scope: SignOutScope.global);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await _confirmDialog(
      title: 'Delete Account',
      message:
          'This will permanently delete your account and all your health '
          'records. This action cannot be undone. Are you sure?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      // Account deletion requires elevated privileges, so this should call
      // a Supabase Edge Function (e.g. "delete-account") using a service role key.
      await _supabase.functions.invoke('delete-account');
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: _kDark)),
        content: Text(message,
            style: const TextStyle(fontSize: 14, color: _kLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _kLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive ? Colors.red : _kSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDark),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: _kDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kSecondary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Login & Authentication'),
                    _card([
                      if (_isEmailAccount)
                        _menuRow(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: _showChangePasswordSheet,
                        )
                      else
                        _infoRow(
                          icon: Icons.g_mobiledata,
                          label: 'Signed in with Google',
                          subtitle:
                              'Manage your password via your Google Account',
                        ),
                      const Divider(
                          height: 0, color: _kBorder, indent: 16, endIndent: 16),
                      _switchRow(
                        icon: Icons.fingerprint,
                        label: 'Biometric Login',
                        subtitle: 'Use Face ID / fingerprint to unlock app',
                        value: _biometricEnabled,
                        onChanged: _toggleBiometric,
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle('Data & Privacy'),
                    _card([
                      _menuRow(
                        icon: Icons.description_outlined,
                        label: 'Privacy Policy',
                        onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                      ),
                      const Divider(
                          height: 0, color: _kBorder, indent: 16, endIndent: 16),
                      _menuRow(
                        icon: Icons.article_outlined,
                        label: 'Terms of Service',
                        onTap: () => Navigator.pushNamed(context, '/terms-of-service'),
                      ),
                      const Divider(
                          height: 0, color: _kBorder, indent: 16, endIndent: 16),
                      _menuRow(
                        icon: Icons.download_outlined,
                        label: 'Download My Data',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'We will email you a copy of your data within 48 hours.'),
                            ),
                          );
                        },
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle('Account'),
                    _card([
                      _menuRow(
                        icon: Icons.logout,
                        label: 'Sign Out of All Devices',
                        onTap: _confirmSignOutAllDevices,
                      ),
                      const Divider(
                          height: 0, color: _kBorder, indent: 16, endIndent: 16),
                      _menuRow(
                        icon: Icons.delete_outline,
                        label: 'Delete Account',
                        onTap: _confirmDeleteAccount,
                        destructive: true,
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Shared widgets ───────────────────────────────────────────
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _kDark,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 0.8),
        ),
        child: Column(children: children),
      );

  Widget _menuRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
    bool isLast = false,
  }) {
    final color = destructive ? Colors.red : _kDark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isLast ? 16 : 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: destructive ? Colors.red : _kLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 14, color: color)),
            ),
            Icon(Icons.chevron_right,
                size: 20, color: destructive ? Colors.red : const Color(0xFFC0B0A8)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: _kDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: _kLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLast ? 8 : 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: _kDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: _kLight)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _kSecondary),
        ],
      ),
    );
  }
}

// ── Change Password bottom sheet ─────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: _kDark),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscure,
              style: const TextStyle(fontSize: 14, color: _kDark),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(fontSize: 13, color: _kLight),
                isDense: true,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: _kBorder),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: _kPrimary, width: 1.4),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: _kLight,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscure,
              style: const TextStyle(fontSize: 14, color: _kDark),
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(fontSize: 13, color: _kLight),
                isDense: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: _kBorder),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _kPrimary, width: 1.4),
                ),
              ),
              validator: (v) {
                if (v != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Password',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}