import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildProgressCard(),
                    const SizedBox(height: 14),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 14),
                    _buildTipCard(),
                    const SizedBox(height: 14),
                    _buildRecentActivity(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hi, Sarah!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Week 24 of your pregnancy',
                style: TextStyle(fontSize: 13, color: Color(0xFF9B8070)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF4A3728)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ── Pregnancy Progress Card ──────────────────────────────────
  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pregnancy Progress',
            style: TextStyle(fontSize: 12, color: Color(0xFF7A6558)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '24 Weeks',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              Text(
                '16 weeks to go',
                style: TextStyle(fontSize: 12, color: Color(0xFF7A6558)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 24 / 40,
              backgroundColor: const Color(0xFFC8BDB5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFE8A0A0)),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Grid ───────────────────────────────────────
  Widget _buildQuickActionsGrid(BuildContext context) {
    final cards = [
      _QuickCard(
        icon: Icons.calendar_today_outlined,
        title: 'Next Appointment',
        subtitle: '20 May 2026',
        route: '/appointments',
      ),
      _QuickCard(
        icon: Icons.favorite_border,
        title: "Today's Health",
        subtitle: 'All Good!',
        route: '/health',
      ),
      _QuickCard(
        icon: Icons.eco_outlined,
        title: 'Nutrition',
        subtitle: '1200/2000 cal',
        route: '/nutrition',
      ),
      _QuickCard(
        icon: Icons.medication_outlined,
        title: 'Medications',
        subtitle: '2 pending',
        route: '/medicine',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: cards
          .map((c) => _buildQuickCard(context, c))
          .toList(),
    );
  }

  Widget _buildQuickCard(BuildContext context, _QuickCard card) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, card.route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card.icon, color: const Color(0xFF4A3728), size: 26),
            const SizedBox(height: 8),
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D1F17),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              card.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9B8070),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Today's Tip ──────────────────────────────────────────────
  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Today's Tip",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Your baby is about the size of a cantaloupe! Make sure to stay hydrated and get plenty of rest.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7A6558),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Activity ──────────────────────────────────────────
  Widget _buildRecentActivity() {
    final activities = [
      _Activity(icon: Icons.favorite_border, title: 'Nutrition', sub: '1200/2000 cal'),
      _Activity(icon: Icons.medication_outlined, title: 'Medication taken', sub: 'Folic acid — 8:00 AM'),
      _Activity(icon: Icons.calendar_today_outlined, title: 'Appointment booked', sub: 'Dr. Aida — 20 May'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map((a) => _buildActivityRow(a)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityRow(_Activity a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F3),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8DDD6)),
            ),
            child: Icon(a.icon, size: 17, color: const Color(0xFF4A3728)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D1F17))),
              Text(a.sub,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9B8070))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper models ────────────────────────────────────────────
class _QuickCard {
  final IconData icon;
  final String title, subtitle, route;
  const _QuickCard({required this.icon, required this.title, required this.subtitle, required this.route});
}

class _Activity {
  final IconData icon;
  final String title, sub;
  const _Activity({required this.icon, required this.title, required this.sub});
}