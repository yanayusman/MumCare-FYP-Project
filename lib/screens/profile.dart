import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/auth_service.dart';
import '../models/maternal_health.dart';

// ── Palette ───────────────────────────────────────────────────
const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);
const _kCardBg = Colors.white;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PersonalInfo? _personalInfo;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  String? _error;

  static const List<_MenuItem> _menuItems = [
    _MenuItem(label: 'Personal Information',   route: '/personal-info',        icon: Icons.person_outline_rounded),
    _MenuItem(label: 'Medical History',        route: '/medical-history',       icon: Icons.medical_information_outlined),
    _MenuItem(label: 'Healthcare Provider',    route: '/healthcare-provider',   icon: Icons.local_hospital_outlined),
    _MenuItem(label: 'Privacy & Security',     route: '/privacy-security',      icon: Icons.shield_outlined),
    _MenuItem(label: 'Help & Support',         route: '/help-support',          icon: Icons.help_outline_rounded),
    _MenuItem(label: 'Terms of Use',           route: '/terms-of-use',          icon: Icons.article_outlined),
    _MenuItem(label: 'About Us',               route: '/about-us',              icon: Icons.info_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() { _error = 'User not logged in.'; _isLoading = false; });
        return;
      }
      _email = user.email;
      final response = await supabase
          .from('user_profiles').select().eq('id', user.id).single();
      setState(() {
        _personalInfo = PersonalInfo.fromMap(response);
        _avatarUrl = response['avatar_url'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load profile: $e'; _isLoading = false; });
    }
  }

  // ── Pregnancy helpers ─────────────────────────────────────────
  int? get _currentWeek {
    final edd = _personalInfo?.edd;
    if (edd == null) return null;
    final daysUntilDue = edd.difference(DateTime.now()).inDays;
    return (40 - (daysUntilDue / 7).ceil()).clamp(1, 40);
  }

  int? get _daysRemaining {
    final edd = _personalInfo?.edd;
    if (edd == null) return null;
    return edd.difference(DateTime.now()).inDays.clamp(0, 280);
  }

  String get _trimester {
    final w = _currentWeek;
    if (w == null) return '—';
    if (w <= 13) return '1st Trimester';
    if (w <= 26) return '2nd Trimester';
    return '3rd Trimester';
  }

  // ── Photo picker ──────────────────────────────────────────────
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: _kBorder, borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Profile Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kDark)),
              const SizedBox(height: 20),
              _sheetOption(icon: Icons.camera_alt_outlined, label: 'Take Photo',
                  onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); }),
              const Divider(height: 1, color: Color(0xFFF0E8E2)),
              _sheetOption(icon: Icons.photo_library_outlined, label: 'Choose from Gallery',
                  onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); }),
              if (_avatarUrl != null) ...[
                const Divider(height: 1, color: Color(0xFFF0E8E2)),
                _sheetOption(icon: Icons.delete_outline, label: 'Remove Photo',
                    color: _kSecondary,
                    onTap: () { Navigator.pop(ctx); _removePhoto(); }),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({required IconData icon, required String label,
      required VoidCallback onTap, Color color = _kDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 15, color: color)),
        ]),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
          source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (picked == null) return;
      setState(() => _isUploadingPhoto = true);
      await _uploadPhoto(await picked.readAsBytes());
    } catch (e) {
      if (mounted) _showSnack('Could not pick image. Please try again.');
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _uploadPhoto(Uint8List bytes) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final filePath = '${user.id}/avatar.jpg';
      await supabase.storage.from('avatars').uploadBinary(filePath, bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      final bust = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      await supabase.from('user_profiles').update({'avatar_url': publicUrl}).eq('id', user.id);
      setState(() { _avatarUrl = bust; _isUploadingPhoto = false; });
      if (mounted) _showSnack('Profile photo updated!');
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) _showSnack(kDebugMode ? 'Upload failed: $e' : 'Upload failed. Try again.');
    }
  }

  Future<void> _removePhoto() async {
    try {
      setState(() => _isUploadingPhoto = true);
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.storage.from('avatars').remove(['${user.id}/avatar.jpg']);
      await supabase.from('user_profiles').update({'avatar_url': null}).eq('id', user.id);
      setState(() { _avatarUrl = null; _isUploadingPhoto = false; });
      if (mounted) _showSnack('Profile photo removed.');
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) _showSnack('Could not remove photo. Try again.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: _kDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kPrimary))
                  : SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Only show these if data loaded successfully
                          if (_error == null) ...[
                            _buildHeroCard(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  _buildPregnancyCard(),
                                  const SizedBox(height: 16),
                                  _buildQuickStats(),
                                  const SizedBox(height: 20),
                                  _buildMenuSection(),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],

                          // Show error message if there is one
                          if (_error != null) _buildError(),

                          // ✅ Logout always visible regardless of error
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                _buildLogoutButton(context),
                                const SizedBox(height: 28),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEDE5DE), width: 0.8))),
      child: const Text('Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _kDark)),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────
  Widget _buildHeroCard() {
    final name = _personalInfo?.fullName ?? '—';
    final colourCode = _personalInfo?.antenatal_colour_code ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9D0D8), Color(0xFFFDE8EE), Color(0xFFFAF6F3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Avatar with glow ring
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _showPhotoOptions,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _kPrimary.withOpacity(0.4), width: 3),
                  ),
                ),
                Container(
                  width: 84, height: 84,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: _isUploadingPhoto
                        ? Container(
                            color: const Color(0xFFF5E6E0),
                            child: const Center(
                              child: SizedBox(width: 26, height: 26,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: _kSecondary)),
                            ))
                        : _avatarUrl != null
                            ? Image.network(_avatarUrl!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarPlaceholder())
                            : _avatarPlaceholder(),
                  ),
                ),
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: _kSecondary, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: _kDark, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text(_email ?? '—',
              style: const TextStyle(fontSize: 13, color: _kLight)),

          if (colourCode.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kBorder, width: 0.8),
                boxShadow: [BoxShadow(
                    color: _kDark.withOpacity(0.04),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _parseColour(colourCode),
                      border: Border.all(color: _kBorder, width: 0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Antenatal: $colourCode',
                      style: const TextStyle(
                          fontSize: 12, color: _kDark, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() => Container(
      color: const Color(0xFFF5E6E0),
      child: const Icon(Icons.person_outline, size: 36, color: Color(0xFFC4857A)));

  // ── Pregnancy progress card ───────────────────────────────────
  Widget _buildPregnancyCard() {
    final week = _currentWeek;
    final daysLeft = _daysRemaining;
    final edd = _personalInfo?.edd;
    final progress = week != null ? week / 40.0 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4537E), Color(0xFFE8748A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: _kSecondary.withOpacity(0.28),
            blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pregnancy Journey',
                    style: TextStyle(fontSize: 12, color: Colors.white70,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(_trimester,
                    style: const TextStyle(fontSize: 17, color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  week != null ? 'Week $week / 40' : '—',
                  style: const TextStyle(fontSize: 14, color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress, minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                week != null ? '${(progress * 100).toInt()}% complete' : 'Set your due date',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              if (daysLeft != null)
                Text('$daysLeft days to go',
                    style: const TextStyle(fontSize: 12, color: Colors.white,
                        fontWeight: FontWeight.w600)),
            ],
          ),

          if (edd != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 0, thickness: 0.6),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.white70),
              const SizedBox(width: 6),
              Text('Due ${edd.day} ${_monthName(edd.month)} ${edd.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ],
        ],
      ),
    );
  }

  // ── Quick stats ───────────────────────────────────────────────
  Widget _buildQuickStats() {
    final week = _currentWeek ?? 0;
    final daysLeft = _daysRemaining ?? 0;
    final tri = week <= 13 ? '1st' : week <= 26 ? '2nd' : '3rd';

    return Row(children: [
      _statChip(icon: Icons.favorite_rounded, value: '$week',
          label: 'Weeks', iconColor: _kSecondary, bgColor: const Color(0xFFFDE8EE)),
      const SizedBox(width: 10),
      _statChip(icon: Icons.hourglass_bottom_rounded, value: '$daysLeft',
          label: 'Days left', iconColor: const Color(0xFF7B86CB),
          bgColor: const Color(0xFFEEEFF9)),
      const SizedBox(width: 10),
      _statChip(icon: Icons.auto_awesome_rounded, value: tri,
          label: 'Trimester', iconColor: const Color(0xFF5BB89A),
          bgColor: const Color(0xFFE6F5F0)),
    ]);
  }

  Widget _statChip({required IconData icon, required String value,
      required String label, required Color iconColor, required Color bgColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder, width: 0.8),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(height: 7),
          Text(value, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: _kDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: _kLight)),
        ]),
      ),
    );
  }

  // ── Menu section ──────────────────────────────────────────────
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: Column(
        children: _menuItems.asMap().entries.map((e) {
          final isLast = e.key == _menuItems.length - 1;
          return Column(children: [
            _menuRow(context, e.value),
            if (!isLast)
              const Divider(height: 0, thickness: 0.5,
                  indent: 52, endIndent: 16, color: Color(0xFFF0E8E2)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _menuRow(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 17, color: _kSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(item.label,
              style: const TextStyle(fontSize: 14, color: _kDark))),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFC0B0A8), size: 20),
        ]),
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Logout',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFDE8EE),
          foregroundColor: _kSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _kDark)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(fontSize: 14, color: _kLight)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _kLight))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut(); 
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
            },
            child: const Text('Logout',
                style: TextStyle(color: _kSecondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                color: Color(0xFFFDE8EE), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded,
                color: _kSecondary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(_error!,
              style: const TextStyle(color: _kLight, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() { _isLoading = true; _error = null; });
              _loadProfileData();
            },
            child: const Text('Retry', style: TextStyle(color: _kSecondary)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Color _parseColour(String code) {
    final named = {'red': Colors.red, 'yellow': Colors.yellow,
        'green': Colors.green, 'white': Colors.white};
    final lower = code.trim().toLowerCase();
    if (named.containsKey(lower)) return named[lower]!;
    final hex = lower.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    return const Color(0xFFF5E6E0);
  }

  String _monthName(int m) => ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}

// ── Model ──────────────────────────────────────────────────────
class _MenuItem {
  final String label;
  final String route;
  final IconData icon;
  const _MenuItem({required this.label, required this.route, required this.icon});
}