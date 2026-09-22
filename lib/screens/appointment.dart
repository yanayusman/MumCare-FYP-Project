import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/bottom_nav_bar.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);
const _kGreen = Color(0xFF4CAF6D);

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

// ── Time slots ────────────────────────────────────────────────
const _kTimeSlots = [
  '8:00 AM', '8:30 AM', '9:00 AM', '9:30 AM',
  '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
  '12:00 PM', '12:30 PM',
  '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM',
  '4:00 PM', '4:30 PM',
];

TimeOfDay _parseSlot(String slot) {
  final parts = slot.split(' ');
  final hm = parts[0].split(':');
  var hour = int.parse(hm[0]);
  final minute = int.parse(hm[1]);
  final isPm = parts[1] == 'PM';
  if (isPm && hour != 12) hour += 12;
  if (!isPm && hour == 12) hour = 0;
  return TimeOfDay(hour: hour, minute: minute);
}

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  final _service = AppointmentService.instance;

  bool _showUpcoming = true;
  bool _loading = true;
  String? _error;
  List<AppointmentModel> _appointments = [];

  List<AppointmentModel> get _upcoming =>
      _appointments.where((a) => a.isUpcoming).toList();

  List<AppointmentModel> get _past =>
      _appointments.where((a) => !a.isUpcoming).toList();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _service.fetchAppointments();
      if (!mounted) return;
      setState(() {
        _appointments = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openNewRequestSheet() async {
    final doctorDefault = await _service.fetchDefaultDoctorName() ?? 'Dr.';
    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentRequestSheet(
        title: 'Request Appointment',
        submitLabel: 'Submit Request',
        doctorDefault: doctorDefault,
      ),
    );

    if (saved == true) {
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Request submitted. Your nurse will confirm the date.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openRescheduleSheet(AppointmentModel appt) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentRequestSheet(
        title: 'Reschedule Appointment',
        submitLabel: 'Request Reschedule',
        doctorDefault: appt.doctorName,
        initialType: appt.type,
        lockType: true,
        onSubmit: (type, doctor, preferredDate, notes) =>
            _service.requestReschedule(
          appointmentId: appt.id,
          preferredDate: preferredDate,
          notes: notes,
        ),
      ),
    );

    if (saved == true) {
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Reschedule request sent. Your nurse will confirm a new date.',
            ),
          ),
        );
      }
    }
  }

  void _showDetails(AppointmentModel appt) {
    showDialog(
      context: context,
      builder: (_) => _AppointmentDetailsDialog(appointment: appt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _showUpcoming ? _upcoming : _past;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildToggle(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(list)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
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
              color: _kDark,
            ),
          ),
          GestureDetector(
            onTap: _openNewRequestSheet,
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

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _kBorder, width: 0.8),
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
            color: isActive ? _kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : _kLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<AppointmentModel> list) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _kSecondary),
      );
    }

    if (_error != null) {
      final isMissingTable = _error!.contains('appointments') &&
          (_error!.contains('PGRST205') || _error!.contains('does not exist'));

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMissingTable ? Icons.storage_outlined : Icons.error_outline,
                size: 40,
                color: _kLight,
              ),
              const SizedBox(height: 12),
              Text(
                isMissingTable
                    ? 'Appointments table not set up yet'
                    : 'Could not load appointments',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isMissingTable
                    ? 'Run supabase/migrations/20250613100000_appointments.sql in your Supabase SQL Editor.'
                    : _error!,
                style: const TextStyle(fontSize: 13, color: _kLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showUpcoming
                    ? Icons.event_available_outlined
                    : Icons.history,
                size: 48,
                color: _kLight,
              ),
              const SizedBox(height: 12),
              Text(
                _showUpcoming
                    ? 'No upcoming appointments'
                    : 'No past appointments',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _kDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _showUpcoming
                    ? 'Tap + to request an appointment with your doctor.'
                    : 'Completed appointments will appear here.',
                style: const TextStyle(fontSize: 13, color: _kLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _kSecondary,
      onRefresh: _loadAppointments,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, i) => _buildCard(list[i]),
      ),
    );
  }

  Widget _buildCard(AppointmentModel appt) {
    final canReschedule = appt.status == AppointmentStatus.confirmed ||
        appt.status == AppointmentStatus.pending ||
        appt.status == AppointmentStatus.rescheduled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.type,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _kDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appt.doctorName,
                      style: const TextStyle(fontSize: 13, color: _kLight),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: appt.status),
            ],
          ),
          const SizedBox(height: 12),
          _buildDateRow(appt),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDetails(appt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
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
              if (canReschedule) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openRescheduleSheet(appt),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(AppointmentModel appt) {
    String primary;
    String? secondary;

    if (appt.scheduledAt != null) {
      primary = _formatDateTime(appt.scheduledAt!);
      if (appt.status == AppointmentStatus.rescheduled &&
          appt.preferredDate != null) {
        secondary =
            'Requested: ${_formatDateTime(appt.preferredDate!)}';
      }
    } else if (appt.preferredDate != null) {
      primary = 'Preferred: ${_formatDateTime(appt.preferredDate!)}';
      secondary = 'Awaiting nurse confirmation';
    } else {
      primary = 'Date to be confirmed';
      secondary = 'Your nurse will set the schedule';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF4A3728)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                primary,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A3728),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (secondary != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              secondary,
              style: const TextStyle(fontSize: 12, color: _kLight),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Status badge ───────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      AppointmentStatus.pending => (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
        ),
      AppointmentStatus.confirmed => (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        ),
      AppointmentStatus.rescheduled => (
          const Color(0xFFFFF8E1),
          const Color(0xFFF57F17),
        ),
      AppointmentStatus.cancelled => (
          const Color(0xFFF5F5F5),
          const Color(0xFF757575),
        ),
      AppointmentStatus.completed => (
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Time slot picker ──────────────────────────────────────────
// Mirrors the picker used on the provider side so patients pick
// from the same set of bookable slots.

class _TimeSlotPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _TimeSlotPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final morningSlots = _kTimeSlots.where((s) => s.contains('AM')).toList();
    final afternoonSlots = _kTimeSlots.where((s) => s.contains('PM')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SlotGroup(
          label: '🌤  Morning',
          slots: morningSlots,
          selected: selected,
          onSelect: onSelect,
        ),
        const SizedBox(height: 12),
        _SlotGroup(
          label: '☀️  Afternoon',
          slots: afternoonSlots,
          selected: selected,
          onSelect: onSelect,
        ),
      ],
    );
  }
}

class _SlotGroup extends StatelessWidget {
  final String label;
  final List<String> slots;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SlotGroup({
    required this.label,
    required this.slots,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _kLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = selected == slot;
            return InkWell(
              onTap: () => onSelect(slot),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? _kSecondary : _kBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? _kSecondary : _kBorder,
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : _kDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Request / Reschedule sheet ─────────────────────────────────

typedef _SubmitFn = Future<void> Function(
  String type,
  String doctor,
  DateTime preferredDate,
  String? notes,
);

class _AppointmentRequestSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String doctorDefault;
  final String? initialType;
  final bool lockType;
  final _SubmitFn? onSubmit;

  const _AppointmentRequestSheet({
    required this.title,
    required this.submitLabel,
    required this.doctorDefault,
    this.initialType,
    this.lockType = false,
    this.onSubmit,
  });

  @override
  State<_AppointmentRequestSheet> createState() =>
      _AppointmentRequestSheetState();
}

class _AppointmentRequestSheetState extends State<_AppointmentRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  String? _selectedDoctor;
  late final TextEditingController _notes;
  DateTime? _preferredDate;
  String? _preferredSlot;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? AppointmentModel.appointmentTypes.first;

    _selectedDoctor = AppointmentModel.doctorOptions.contains(widget.doctorDefault)
        ? widget.doctorDefault
        : AppointmentModel.doctorOptions.first;

    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kSecondary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _preferredDate == null) {
      if (_preferredDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your preferred date')),
        );
      }
      return;
    }

    if (_preferredSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your preferred time')),
      );
      return;
    }

    final tod = _parseSlot(_preferredSlot!);
    final preferredDateTime = DateTime(
      _preferredDate!.year,
      _preferredDate!.month,
      _preferredDate!.day,
      tod.hour,
      tod.minute,
    );

    setState(() => _submitting = true);
    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(
          _type,
          _selectedDoctor ?? '', 
          preferredDateTime,
          _notes.text.trim(),
        );
      } else {
        await AppointmentService.instance.createRequest(
          type: _type,
          doctorName: _selectedDoctor ?? '',
          preferredDate: preferredDateTime,
          notes: _notes.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _kDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: _kLight),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose your preferred date and time. Your nurse will '
                  'confirm the final schedule.',
                  style: TextStyle(fontSize: 13, color: _kLight, height: 1.4),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: _kBorder, thickness: 0.8),

              // ── Scrollable form body ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.lockType)
                        _readOnlyField('Appointment Type', _type)
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: _inputDecoration('Appointment Type'),
                          items: AppointmentModel.appointmentTypes
                              .map((t) =>
                                  DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedDoctor,
                        decoration: _inputDecoration('Doctor / Provider'),
                        isExpanded: true,
                        items: AppointmentModel.doctorOptions
                            .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 14, color: _kDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedDoctor = v),
                        validator: (v) =>
                            v == null ? 'Please select a doctor' : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Preferred date ──
                      GestureDetector(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: _inputDecoration('Preferred Date *'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _preferredDate != null
                                    ? _formatDate(_preferredDate!)
                                    : 'Select a date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _preferredDate != null
                                      ? _kDark
                                      : _kLight,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18, color: _kLight),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Preferred time slot ──
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Preferred Time *',
                          style: TextStyle(
                            fontSize: 13,
                            color: _kLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _TimeSlotPicker(
                        selected: _preferredSlot,
                        onSelect: (s) => setState(() => _preferredSlot = s),
                      ),
                      if (_preferredSlot != null) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.check_circle,
                              size: 14, color: _kGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Selected: $_preferredSlot',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ],
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _notes,
                        maxLines: 2,
                        decoration: _inputDecoration('Notes (optional)'),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kSecondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.submitLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _kLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kPrimary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return InputDecorator(
      decoration: _inputDecoration(label),
      child: Text(value, style: const TextStyle(fontSize: 14, color: _kDark)),
    );
  }
}

// ── Details dialog ─────────────────────────────────────────────

class _AppointmentDetailsDialog extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentDetailsDialog({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final appt = appointment;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appt.type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _kDark,
                    ),
                  ),
                ),
                _StatusBadge(status: appt.status),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.person_outline, 'Provider', appt.doctorName),
            if (appt.scheduledAt != null)
              _detailRow(
                Icons.event,
                'Confirmed Date',
                _formatDateTime(appt.scheduledAt!),
              ),
            if (appt.preferredDate != null)
              _detailRow(
                Icons.date_range,
                appt.status == AppointmentStatus.rescheduled
                    ? 'Requested Date & Time'
                    : 'Preferred Date & Time',
                _formatDateTime(appt.preferredDate!),
              ),
            if (appt.notes != null && appt.notes!.isNotEmpty)
              _detailRow(Icons.notes_outlined, 'Notes', appt.notes!),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _kLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: _kLight)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 14, color: _kDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date helpers ───────────────────────────────────────────────

String _formatDate(DateTime dt) {
  return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
}

String _formatDateTime(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '${_formatDate(dt)}  $h12:$minute $period';
}