import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  static const _appVersion = '1.0.0';
  static const _buildNumber = '2026.06';

  static const List<_ValueItem> _values = [
    _ValueItem(
      icon: Icons.favorite_rounded,
      title: 'Care at the centre',
      description:
          'Every feature is built around the mother — her comfort, her confidence, and her wellbeing throughout the journey.',
    ),
    _ValueItem(
      icon: Icons.lock_outline_rounded,
      title: 'Your data, protected',
      description:
          'We handle your health information with the highest level of care. It is never sold or shared without your knowledge.',
    ),
    _ValueItem(
      icon: Icons.people_outline_rounded,
      title: 'Built with mothers',
      description:
          'MumCare was shaped by real feedback from pregnant women, midwives, and maternal health professionals in Malaysia.',
    ),
    _ValueItem(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Simple by design',
      description:
          'Pregnancy is already a lot. We keep MumCare clear, calm, and easy to use — even on the hardest days.',
    ),
  ];

  static const List<_StatItem> _stats = [
    _StatItem(value: '9', label: 'Months\nwith you'),
    _StatItem(value: '3', label: 'Trimesters\ncovered'),
    _StatItem(value: '100%', label: 'Built for\nmothers'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 28),
                    _buildStats(),
                    const SizedBox(height: 32),
                    _buildMissionBlock(),
                    const SizedBox(height: 32),
                    _buildValuesSection(),
                    const SizedBox(height: 32),
                    _buildTeamNote(),
                    const SizedBox(height: 32),
                    _buildVersionFooter(),
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
            color: const Color(0xFF2D1F17),
            iconSize: 20,
          ),
          const Text(
            'About Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9D0D8), Color(0xFFFDE8EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // App icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4537E).withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFD4537E),
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MumCare',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D1F17),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your pregnancy journey companion',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7A4F5A),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────
  Widget _buildStats() {
    return Row(
      children: _stats.map((stat) {
        final isLast = stat == _stats.last;
        return Expanded(
          child: Row(
            children: [
              Expanded(child: _buildStatCell(stat)),
              if (!isLast)
                Container(
                  width: 0.8,
                  height: 40,
                  color: const Color(0xFFE8DDD6),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCell(_StatItem stat) {
    return Column(
      children: [
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD4537E),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9B8070),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── Mission ───────────────────────────────────────────────────
  Widget _buildMissionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our mission',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1F17),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
          ),
          child: const Text(
            'Pregnancy is one of the most significant journeys a woman will ever take. MumCare exists to make that journey feel less overwhelming by putting the right information, reminders, and support in the palm of your hand.\n\nWe believe every mother deserves to feel informed, prepared, and cared for at every stage.',
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B5A52),
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  // ── Values ────────────────────────────────────────────────────
  Widget _buildValuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What we stand for',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1F17),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
          ),
          child: Column(
            children: _values.asMap().entries.map((e) {
              final isLast = e.key == _values.length - 1;
              return Column(
                children: [
                  _buildValueRow(e.value),
                  if (!isLast)
                    const Divider(
                      height: 0,
                      thickness: 0.5,
                      indent: 56,
                      endIndent: 16,
                      color: Color(0xFFF0E8E2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(_ValueItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: const Color(0xFFD4537E), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D1F17),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9B8070),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Team note ─────────────────────────────────────────────────
  Widget _buildTeamNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🇲🇾  Made in Malaysia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'MumCare was built by a team passionate about improving maternal health outcomes in Malaysia. We work closely with healthcare professionals to ensure the app reflects real clinical guidance and local needs.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B5A52),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Version footer ────────────────────────────────────────────
  Widget _buildVersionFooter() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.favorite_rounded,
            color: Color(0xFFE8A0A0),
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            'Version $_appVersion (Build $_buildNumber)',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB0978C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '© 2026 MumCare. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFFB0978C),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────
class _ValueItem {
  final IconData icon;
  final String title;
  final String description;
  const _ValueItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _StatItem {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});
}