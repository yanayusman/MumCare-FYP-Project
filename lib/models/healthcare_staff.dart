// lib/models/healthcare_staff.dart

class HealthcareStaff {
  final String userId;
  final String fullName;
  final String role; // nurse, doctor, admin
  final String clinicId;

  HealthcareStaff({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.clinicId,
  });

  factory HealthcareStaff.fromMap(Map<String, dynamic> map) {
    return HealthcareStaff(
      userId: map['user_id'] as String,
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? 'nurse',
      clinicId: map['clinic_id'] as String,
    );
  }
}

/// Lightweight patient record for the provider's patient list.
class PatientSummary {
  final String id;
  final String fullName;
  final String icNumber;
  final String phoneNumber;
  final DateTime? edd;
  final int? gravida;
  final int? para;

  PatientSummary({
    required this.id,
    required this.fullName,
    required this.icNumber,
    required this.phoneNumber,
    this.edd,
    this.gravida,
    this.para,
  });

  factory PatientSummary.fromMap(Map<String, dynamic> map) {
    return PatientSummary(
      id: map['id'] as String,
      fullName: map['full_name'] ?? '',
      icNumber: map['ic_number'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      edd: map['edd_date'] != null ? DateTime.tryParse(map['edd_date']) : null,
      gravida: map['gravida'],
      para: map['para'],
    );
  }

  /// Pregnancy week estimate based on EDD (assuming 40-week term).
  int? get gestationWeeks {
    if (edd == null) return null;
    final daysUntilDue = edd!.difference(DateTime.now()).inDays;
    final weeksUntilDue = (daysUntilDue / 7).floor();
    final weeks = 40 - weeksUntilDue;
    if (weeks < 0 || weeks > 45) return null;
    return weeks;
  }
}