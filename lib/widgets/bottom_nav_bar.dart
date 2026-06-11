import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    final routes = [
      '/appointment',
      '/health',
      '/home',
      '/explorer',
      '/profile',
    ];

    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nav bar with curved cutout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _NavBarPainter(),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(context, 0, Icons.calendar_today_outlined, 'Appointments'),
                      _navItem(context, 1, Icons.favorite_border, 'Health'),
                      const SizedBox(width: 64), // space for FAB
                      _navItem(context, 3, Icons.menu_book_outlined, 'Explorer'),
                      _navItem(context, 4, Icons.person_outline, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating home button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _onTap(context, 2),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE070A8), Color(0xFFD4537E)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4537E).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF8C6A55) : const Color(0xFFB8A89A),
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF8C6A55) : const Color(0xFFB8A89A),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final cutoutCenterX = size.width / 2;
    const cutoutRadius = 38.0;
    const curveWidth = 56.0;
    const curveDepth = 28.0;

    path.moveTo(0, 0);
    path.lineTo(cutoutCenterX - curveWidth, 0);

    // Left side of the curve
    path.cubicTo(
      cutoutCenterX - curveWidth + 18, 0,
      cutoutCenterX - cutoutRadius, curveDepth,
      cutoutCenterX, curveDepth,
    );

    // Right side of the curve
    path.cubicTo(
      cutoutCenterX + cutoutRadius, curveDepth,
      cutoutCenterX + curveWidth - 18, 0,
      cutoutCenterX + curveWidth, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Draw white bar
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}