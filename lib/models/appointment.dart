enum AppointmentStatus {
  pending,
  confirmed,
  rescheduled,
  cancelled,
  completed;

  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AppointmentStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }
}

class AppointmentModel {
  final String id;
  final String userId;
  final String type;
  final String doctorName;
  final DateTime? scheduledAt;
  final DateTime? preferredDate;
  final String? notes;
  final String? location;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.doctorName,
    this.scheduledAt,
    this.preferredDate,
    this.notes,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUpcoming {
    if (status == AppointmentStatus.cancelled ||
        status == AppointmentStatus.completed) {
      return false;
    }
    if (scheduledAt != null) {
      return !scheduledAt!.isBefore(DateTime.now());
    }
    return true;
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseTs(String? key) {
      final v = map[key];
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    DateTime? parseDate(String? key) {
      final v = map[key];
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return AppointmentModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      type: map['type'] ?? '',
      doctorName: map['doctor_name'] ?? 'Dr.',
      scheduledAt: parseTs(map['scheduled_at']?.toString()),
      preferredDate: parseDate(map['preferred_date']?.toString()),
      notes: map['notes']?.toString(),
      location: map['location']?.toString(),
      status: AppointmentStatus.fromString(map['status'] ?? 'pending'),
      createdAt: parseTs(map['created_at']?.toString()) ?? DateTime.now(),
      updatedAt: parseTs(map['updated_at']?.toString()) ?? DateTime.now(),
    );
  }

  static const appointmentTypes = [
    'Checkup',
    'Ultrasound',
    'Blood Test',
    'Consultation',
    'Vaccination',
    'Other',
  ];

  static const List<String> doctorOptions = [
    'Dr. Nor Aini binti Abdullah',
    'Dr. Siti Rahayu binti Mohd Yusof',
    'Dr. Faridah binti Hassan',
    'Dr. Zainab binti Ibrahim',
    'Dr. Rohani binti Othman',
    'Dr. Nurul Huda binti Ahmad',
    'Dr. Mazlina binti Zakaria',
    'Dr. Hasnah binti Ismail',
    'Dr. Suraya binti Ramli',
    'Dr. Norzahra binti Kamarudin',
    'Dr. Priya a/p Krishnamurthy',
    'Dr. Lim Wei Ling',
    'Dr. Tan Siew Mei',
    'Dr. Kavitha a/p Subramaniam',
    'Dr. Ng Pei Shan',
    'Dr. Muhammad Hafiz bin Razali',
    'Dr. Ahmad Fauzi bin Mokhtar',
    'Dr. Mohd Redzuan bin Yusuf',
    'Dr. Azlan bin Che Hassan',
    'Dr. Shahril bin Mustafa',
  ];
}
