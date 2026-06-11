import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/auth_service.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  final List<_MenuItem> _menuItems = const [
    _MenuItem(label: 'Personal Information', route: '/personal-info'),
    _MenuItem(label: 'Medical History', route: '/medical-history'),
    _MenuItem(label: 'Healthcare Provider', route: '/healthcare-provider'),
    _MenuItem(label: 'Notifications', route: '/notifications'),
    _MenuItem(label: 'Privacy & Security', route: '/privacy-security'),
    _MenuItem(label: 'Help & Support', route: '/help-support'),
  ];

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
            children: const [
              Text(
                'Sarah Aabrek',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'sarah.a@gmail.com',
                style: TextStyle(fontSize: 12, color: Color(0xFF9B8070)),
              ),
              SizedBox(height: 2),
              Text(
                'Due: 28 August 2027',
                style: TextStyle(fontSize: 12, color: Color(0xFF9B8070)),
              ),
            ],
          ),
        ),

        // Postnatal colour code box
        Column(
          children: [
            const Text(
              'Postnatal\nColour Code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFF9B8070)),
            ),
            const SizedBox(height: 6),
            Container(
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFE8DDD6), width: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
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
              if (!context.mounted) {
                return;
              }
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