import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/appointment.dart';

class AppointmentService {
  AppointmentService._();

  static final AppointmentService instance = AppointmentService._();

  final _client = Supabase.instance.client;

  Future<List<AppointmentModel>> fetchAppointments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await _client
        .from('appointments')
        .select()
        .eq('user_id', userId)
        .order('scheduled_at', ascending: true, nullsFirst: false)
        .order('preferred_date', ascending: true, nullsFirst: false)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((r) => AppointmentModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<String?> fetchDefaultDoctorName() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from('healthcare_providers')
        .select('nurse_midwife_name')
        .eq('user_id', userId)
        .maybeSingle();

    final name = row?['nurse_midwife_name']?.toString().trim();
    if (name == null || name.isEmpty) return 'Dr.';
    return name.startsWith('Dr.') ? name : 'Dr. $name';
  }

  Future<void> createRequest({
    required String type,
    required String doctorName,
    required DateTime preferredDate,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not logged in');

    await _client.from('appointments').insert({
      'user_id': userId,
      'type': type,
      'doctor_name': doctorName,
      'preferred_date': _dateOnly(preferredDate),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'status': AppointmentStatus.pending.name,
    });
  }

  Future<void> requestReschedule({
    required String appointmentId,
    required DateTime preferredDate,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not logged in');

    await _client.from('appointments').update({
      'preferred_date': _dateOnly(preferredDate),
      'status': AppointmentStatus.rescheduled.name,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    }).eq('id', appointmentId).eq('user_id', userId);
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
