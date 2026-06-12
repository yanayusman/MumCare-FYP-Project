import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/auth_service.dart';
import '../models/maternal_health.dart'; 

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PersonalInfo? _personalInfo;
  String? _email;
  bool _isLoading = true;
  String? _error;

  static const List<_MenuItem> _menuItems = [
    _MenuItem(label: 'Personal Information', route: '/personal-info'),
    _MenuItem(label: 'Medical History', route: '/medical-history'),
    _MenuItem(label: 'Healthcare Provider', route: '/healthcare-provider'),
    // _MenuItem(label: 'Notifications', route: '/notifications'),
    _MenuItem(label: 'Privacy & Security', route: '/privacy-security'),
    _MenuItem(label: 'Help & Support', route: '/help-support'),
    _MenuItem(label: 'About Us', route: '/about-us'),
    _MenuItem(label: 'Terms of Use', route: '/terms-of-use'),
    _MenuItem(label: 'Privacy Policy', route: '/privacy-policy'),];

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
        setState(() {
          _error = 'User not logged in.';
          _isLoading = false;
        });
        return;
      }

      // Get email from auth users table
      _email = user.email;

      // Get profile data from user_profiles table
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _personalInfo = PersonalInfo.fromMap(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Profile load error: $e');
      setState(() {
        _error = 'Failed to load profile: $e'; // show full error on screen
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8A0A0),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Color(0xFF9B8070),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _error = null;
                                  });
                                  _loadProfileData();
                                },
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Color(0xFFD4537E)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildUserCard(),
                              const SizedBox(height: 20),
                              _buildMenuCard(context),
                              const SizedBox(height: 16),
                              _buildLogoutButton(context),
                              const SizedBox(height: 24),
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

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDE5DE), width: 0.8),
        ),
      ),
      child: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D1F17),
        ),
      ),
    );
  }

  // ── User Info Card ───────────────────────────────────────────
  Widget _buildUserCard() {
    final name = _personalInfo?.fullName ?? '—';
    final email = _email ?? '—';
    final estDd = _personalInfo?.edd;
    final colourCode = _personalInfo?.antenatal_colour_code ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5E6E0),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 30,
            color: Color(0xFFC4857A),
          ),
        ),
        const SizedBox(width: 14),

        // Name / email / due date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9B8070)),
              ),
              const SizedBox(height: 2),
              Text(
                estDd != null
                  ? 'Estimate Delivery Due: ${estDd.year}-${estDd.month.toString().padLeft(2, '0')}-${estDd.day.toString().padLeft(2, '0')}'
                  : 'Due date not set',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9B8070)),
              ),
            ],
          ),
        ),

        // Antenatal colour code box
        Column(
          children: [
            const Text(
              'Antenatal\nColour Code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFF9B8070)),
            ),
            const SizedBox(height: 6),
            Container(
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                // Show the colour if available, otherwise white
                color: colourCode.isNotEmpty
                    ? _parseColour(colourCode)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFE8DDD6), width: 0.8),
              ),
              child: colourCode.isNotEmpty
                  ? null
                  : const Center(
                      child: Text(
                        '—',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9B8070)),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tries to parse antenatal_colour_code as a colour name or hex string.
  /// Falls back to a neutral pink if unrecognised.
  Color _parseColour(String code) {
    final Map<String, Color> namedColours = {
      'red': Colors.red,
      'yellow': Colors.yellow,
      'green': Colors.green,
      'white': Colors.white,
    };

    final lower = code.trim().toLowerCase();
    if (namedColours.containsKey(lower)) return namedColours[lower]!;

    // Try hex (#RRGGBB or RRGGBB)
    final hex = lower.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }

    return const Color(0xFFF5E6E0); // fallback
  }

  // ── Menu Card ────────────────────────────────────────────────
  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        children: _menuItems.asMap().entries.map((e) {
          final isLast = e.key == _menuItems.length - 1;
          return Column(
            children: [
              _buildMenuRow(context, e.value),
              if (!isLast)
                const Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFF0E8E2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D1F17),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFC0B0A8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout Button ────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFDE8EE),
          foregroundColor: const Color(0xFFD4537E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ── Logout Confirmation Dialog ───────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1F17),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14, color: Color(0xFF9B8070)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9B8070)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                  color: Color(0xFFD4537E),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────
class _MenuItem {
  final String label;
  final String route;
  const _MenuItem({required this.label, required this.route});
}