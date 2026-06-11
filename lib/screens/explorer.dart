import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class Explorer extends StatefulWidget {
  const Explorer({super.key});

  @override
  State<Explorer> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<Explorer> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<_FilterChip> _filters = [
    _FilterChip(label: 'All', icon: Icons.grid_view_rounded),
    _FilterChip(label: 'Medication', icon: Icons.medication_outlined),
    _FilterChip(label: 'Nutrition', icon: Icons.eco_outlined),
    _FilterChip(label: 'Exercise', icon: Icons.self_improvement_outlined),
  ];

  final List<_Article> _articles = [
    _Article(title: 'Dietary precautions during pregnancy'),
    _Article(title: 'Yoga, the ideal sport for a zen pregnancy'),
    _Article(title: 'What to eat during pregnancy?'),
    _Article(title: 'Understanding your baby\'s development'),
    _Article(title: 'Managing fatigue in the second trimester'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    const Text(
                      'Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D1F17),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturedCard(),
                    const SizedBox(height: 4),
                    _buildArticleList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(
        'Explorer',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D1F17),
        ),
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2D1F17)),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(
              fontSize: 14, color: Color(0xFFC0B0A8)),
          prefixIcon: const Icon(Icons.search,
              color: Color(0xFF9B8070), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
      ),
    );
  }

  // ── Filter Chips ─────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.asMap().entries.map((e) {
          final isActive = _selectedFilter == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE8A0A0)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFE8A0A0)
                      : const Color(0xFFE8DDD6),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    e.value.icon,
                    size: 22,
                    color: isActive
                        ? Colors.white
                        : const Color(0xFF4A3728),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.value.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF4A3728),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Featured Card ────────────────────────────────────────────
  Widget _buildFeaturedCard() {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Replace with actual Image.asset when you have the image
            Container(
              height: 200,
              width: double.infinity,
              color: const Color(0xFFC4B8B0),
              child: Image.asset(
                'assets/images/trimester.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: const Color(0xFFC4B8B0),
                  child: const Center(
                    child: Icon(Icons.pregnant_woman,
                        size: 80, color: Color(0xFF8C7060)),
                  ),
                ),
              ),
            ),
            // Overlay text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0x99000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Your 1st trimester',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '200 contents',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Article List ─────────────────────────────────────────────
  Widget _buildArticleList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        children: _articles.asMap().entries.map((e) {
          final isLast = e.key == _articles.length - 1;
          return GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.value.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D1F17),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFC0B0A8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFF0E8E2),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────
class _FilterChip {
  final String label;
  final IconData icon;
  const _FilterChip({required this.label, required this.icon});
}

class _Article {
  final String title;
  const _Article({required this.title});
}