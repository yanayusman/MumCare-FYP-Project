import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  bool _showUpcoming = true;

  final List<_Appointment> _upcoming = [
    _Appointment(
      type: 'Checkup',
      doctor: 'Dr. Emily',
      date: '20 May 2026',
      time: '10:00 AM',
    ),
    _Appointment(
      type: 'Ultrasound',
      doctor: 'Dr. Emily',
      date: '20 May 2026',
      time: '2:30 PM',
    ),
    _Appointment(
      type: 'Checkup',
      doctor: 'Dr. Emily',
      date: '17 June 2026',
      time: '10:00 AM',
    ),
  ];

  final List<_Appointment> _past = [
    _Appointment(
      type: 'Checkup',
      doctor: 'Dr. Emily',
      date: '10 April 2026',
      time: '9:00 AM',
    ),
    _Appointment(
      type: 'Ultrasound',
      doctor: 'Dr. Emily',
      date: '1 March 2026',
      time: '11:00 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = _showUpcoming ? _upcoming : _past;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildToggle(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) => _buildCard(list[i]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Appointments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Add new appointment
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

  // ── Upcoming / Past Toggle ───────────────────────────────────
  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
        ),
        child: Row(
          children: [
            _toggleBtn('Upcoming', true),
            _toggleBtn('Past', false),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool isUpcoming) {
    final isActive = _showUpcoming == isUpcoming;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showUpcoming = isUpcoming),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE8A0A0) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF9B8070),
            ),
          ),
        ),
      ),
    );
  }

  // ── Appointment Card ─────────────────────────────────────────
  Widget _buildCard(_Appointment appt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.type,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D1F17),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appt.doctor,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9B8070),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appt.type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD4537E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date & Time row
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF4A3728)),
              const SizedBox(width: 8),
              Text(
                '${appt.date}    ${appt.time}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A3728),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8A0A0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A3728),
                    side: const BorderSide(color: Color(0xFFD4C4B8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Reschedule',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Model ────────────────────────────────────────────────────
class _Appointment {
  final String type, doctor, date, time;
  const _Appointment({
    required this.type,
    required this.doctor,
    required this.date,
    required this.time,
  });
}