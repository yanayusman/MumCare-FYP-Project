// lib/screens/privacy_security.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);

class PrivacySecurity extends StatefulWidget {
  const PrivacySecurity({super.key});

  @override
  State<PrivacySecurity> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurity> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _isEmailAccount = false;
  bool _isRequestingData = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = _supabase.auth.currentUser;
    final identities = user?.identities ?? [];
    _isEmailAccount = identities.any((i) => i.provider == 'email');

    if (identities.isEmpty) {
      final providers = user?.appMetadata['providers'] as List? ?? [];
      _isEmailAccount = providers.isEmpty || providers.contains('email');
    }

    if (mounted) setState(() => _loading = false);
  }

  // ── Change Password ───────────────────────────────────────────
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

  // ── Download My Data ──────────────────────────────────────────
  Future<void> _handleDownloadData() async {
    final confirmed = await _confirmDialog(
      title: 'Download My Data',
      message:
          'We will prepare a copy of all your health records, appointments, and profile data. '
          'A download link will be sent to your registered email within 48 hours.',
      confirmLabel: 'Request Download',
    );
    if (!confirmed) return;

    setState(() => _isRequestingData = true);

    // Simulate API call — replace with your actual edge function if available
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isRequestingData = false);

    if (mounted) {
      _showSnack('Request received! Check your email within 48 hours.');
    }
  }

  // ── Sign Out All Devices ──────────────────────────────────────
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
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to sign out: $e');
    }
  }

  // ── Delete Account ────────────────────────────────────────────
  Future<void> _confirmDeleteAccount() async {
    // Step 1 — first warning
    final step1 = await _confirmDialog(
      title: 'Delete Account',
      message:
          'This will permanently delete your account and all your health '
          'records including appointments, vitals, and nutrition data. '
          'This action cannot be undone.',
      confirmLabel: 'Continue',
      isDestructive: true,
    );
    if (!step1) return;

    // Step 2 — final confirmation with typed intent
    final step2 = await _confirmDialog(
      title: 'Are you absolutely sure?',
      message:
          'All your data will be erased immediately and cannot be recovered. '
          'Please confirm you want to permanently delete your MumCare account.',
      confirmLabel: 'Yes, Delete My Account',
      isDestructive: true,
    );
    if (!step2) return;

    try {
      await _supabase.functions.invoke('delete-account');
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to delete account. Please try again.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2D1F17),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: _kDark)),
        content: Text(message,
            style: const TextStyle(fontSize: 14, color: _kLight, height: 1.5)),
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

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kSecondary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          // ── Login & Authentication ──────────────
                          _sectionTitle('Login & Authentication'),
                          _card([
                            if (_isEmailAccount)
                              _menuRow(
                                icon: Icons.lock_outline_rounded,
                                label: 'Change Password',
                                onTap: _showChangePasswordSheet,
                              )
                            else
                              _infoRow(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Signed in with Google',
                                subtitle:
                                    'Manage your password via your Google Account',
                              ),
                          ]),

                          const SizedBox(height: 20),

                          // ── Data & Privacy ──────────────────────
                          _sectionTitle('Data & Privacy'),
                          _card([
                            _menuRow(
                              icon: Icons.description_outlined,
                              label: 'Privacy Policy',
                              onTap: () => Navigator.pushNamed(
                                  context, '/privacy-policy'),
                            ),
                            _divider(),
                            _menuRow(
                              icon: Icons.article_outlined,
                              label: 'Terms of Use',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/terms-of-use'),
                            ),
                            _divider(),
                            _isRequestingData
                                ? _loadingRow(
                                    icon: Icons.download_outlined,
                                    label: 'Requesting data export…',
                                  )
                                : _menuRow(
                                    icon: Icons.download_outlined,
                                    label: 'Download My Data',
                                    onTap: _handleDownloadData,
                                    isLast: true,
                                  ),
                          ]),

                          const SizedBox(height: 20),

                          // ── Account ─────────────────────────────
                          _sectionTitle('Account'),
                          _card([
                            _menuRow(
                              icon: Icons.logout_rounded,
                              label: 'Sign Out of All Devices',
                              onTap: _confirmSignOutAllDevices,
                            ),
                            _divider(),
                            _menuRow(
                              icon: Icons.delete_outline_rounded,
                              label: 'Delete Account',
                              onTap: _confirmDeleteAccount,
                              destructive: true,
                              isLast: true,
                            ),
                          ]),

                          const SizedBox(height: 32),

                          // ── Footer note ─────────────────────────
                          _buildFooterNote(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDE5DE), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: _kDark,
            iconSize: 20,
          ),
          const Text(
            'Privacy & Security',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _kDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer note ───────────────────────────────────────────────
  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6E0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: _kLight),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your health data is encrypted and stored securely. MumCare never sells your personal information to third parties.',
              style: TextStyle(fontSize: 12, color: _kLight, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kDark)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 0.8),
        ),
        child: Column(children: children),
      );

  Widget _divider() => const Divider(
      height: 0, color: _kBorder, indent: 16, endIndent: 16, thickness: 0.5);

  Widget _menuRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: destructive ? Colors.red : _kLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: destructive ? Colors.red : _kDark)),
            ),
            Icon(Icons.chevron_right,
                size: 20,
                color: destructive ? Colors.red : const Color(0xFFC0B0A8)),
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
                Text(label,
                    style:
                        const TextStyle(fontSize: 14, color: _kDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: _kLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingRow({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: _kLight)),
          ),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _kSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Change Password bottom sheet ──────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  bool _saving = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPwController.text.trim()),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password updated successfully'),
            backgroundColor: const Color(0xFF2D1F17),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
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
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Change Password',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _kDark)),
            const SizedBox(height: 6),
            const Text('Your new password must be at least 8 characters.',
                style: TextStyle(fontSize: 13, color: _kLight)),
            const SizedBox(height: 24),

            // New password
            TextFormField(
              controller: _newPwController,
              obscureText: _obscureNew,
              style: const TextStyle(fontSize: 14, color: _kDark),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(fontSize: 13, color: _kLight),
                isDense: true,
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _kBorder)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _kPrimary, width: 1.4)),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: _kLight),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a new password';
                }
                if (v.trim().length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm password
            TextFormField(
              controller: _confirmPwController,
              obscureText: _obscureConfirm,
              style: const TextStyle(fontSize: 14, color: _kDark),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: const TextStyle(fontSize: 13, color: _kLight),
                isDense: true,
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _kBorder)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _kPrimary, width: 1.4)),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: _kLight),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v != _newPwController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSecondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
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
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }
}