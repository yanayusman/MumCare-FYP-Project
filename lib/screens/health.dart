import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class Health extends StatelessWidget {
  const Health({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildVitalsGrid(),
                    const SizedBox(height: 14),
                    _buildWeightTrendCard(),
                    const SizedBox(height: 14),
                    _buildSymptomsCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Health Monitoring',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Add health record
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4C4B8), width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Color(0xFF4A3728), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vitals Grid ──────────────────────────────────────────────
  Widget _buildVitalsGrid() {
    final vitals = [
      _Vital(label: 'Blood Pressure', value: '120/80', status: 'Normal', statusColor: const Color(0xFF3B6D11)),
      _Vital(label: 'Weight', value: '68 kg', status: '+2 kg this month', statusColor: const Color(0xFF185FA5)),
      _Vital(label: 'Heart Rate', value: '78 bpm', status: 'Normal', statusColor: const Color(0xFF3B6D11)),
      _Vital(label: 'Baby Kicks', value: '12', status: 'Today', statusColor: const Color(0xFF9B8070)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: vitals.map(_buildVitalCard).toList(),
    );
  }

  Widget _buildVitalCard(_Vital v) {
    return Container(
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
          Text(v.label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9B8070))),
          const SizedBox(height: 4),
          Text(v.value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17))),
          const SizedBox(height: 4),
          Text(v.status,
              style: TextStyle(fontSize: 12, color: v.statusColor)),
        ],
      ),
    );
  }

  // ── Weight Trend Chart ───────────────────────────────────────
  Widget _buildWeightTrendCard() {
    // Weight data per week
    final weights = [142.5, 140.0, 138.0, 136.0, 135.0];
    final weeks = ['W19', 'W20', 'W21', 'W22', 'W23'];
    final maxW = 144.0;
    final minW = 133.0;
    final chartH = 100.0;
    final chartW = double.infinity;

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
          const Text('Weight Trend',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17))),
          const SizedBox(height: 12),
          SizedBox(
            height: chartH,
            child: CustomPaint(
              painter: _WeightChartPainter(
                  weights: weights, minY: minW, maxY: maxW),
              size: Size(double.infinity, chartH),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weeks
                .map((w) => Text(w,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9B8070))))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Recent Symptoms ──────────────────────────────────────────
  Widget _buildSymptomsCard() {
    final symptoms = [
      _Symptom(name: 'Morning sickness', when: 'Yesterday'),
      _Symptom(name: 'Back pain', when: '2 days ago'),
      _Symptom(name: 'Swollen feet', when: '3 days ago'),
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
          const Text('Recent Symptoms',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17))),
          const SizedBox(height: 10),
          ...symptoms.asMap().entries.map((e) {
            final isLast = e.key == symptoms.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.value.name,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF2D1F17))),
                      Text(e.value.when,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9B8070))),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Color(0xFFF0E8E2)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ── Weight Chart Painter ─────────────────────────────────────
class _WeightChartPainter extends CustomPainter {
  final List<double> weights;
  final double minY;
  final double maxY;

  _WeightChartPainter(
      {required this.weights, required this.minY, required this.maxY});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF378ADD)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF378ADD)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFF0E8E2)
      ..strokeWidth = 0.5;

    // Draw grid lines
    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (int i = 0; i < weights.length; i++) {
      final x = size.width * i / (weights.length - 1);
      final y = size.height *
          (1 - (weights[i] - minY) / (maxY - minY));
      points.add(Offset(x, y));
    }

    // Draw line
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw dots
    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, dotPaint);
      canvas.drawCircle(pt, 3.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Models ────────────────────────────────────────────────────
class _Vital {
  final String label, value, status;
  final Color statusColor;
  const _Vital(
      {required this.label,
      required this.value,
      required this.status,
      required this.statusColor});
}

class _Symptom {
  final String name, when;
  const _Symptom({required this.name, required this.when});
}