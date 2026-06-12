// lib/models/maternal_health.dart
//
// Data models mapping to the `user_profiles` table (Supabase) 
import 'dart:convert';

/// Section 1 (Personal) + Husband info — collected at Profile Setup.
class PersonalInfo {
  String fullName;
  String icNumber;
  DateTime? dateOfBirth;
  String ethnic;
  String citizenship;
  String phoneNumber;
  String homeAddress;
  String occupation;
  String workAddress;
  String antenatal_colour_code;
  DateTime? lnmp; // THA / LNMP - Tarikh Haid Akhir
  DateTime? edd; // TAL / EDD - Tarikh Anggaran Lahir
  DateTime? revisedEdd; 

  // Husband information
  String husbandFullName;
  String husbandIcNumber;
  String husbandPhoneNumber;
  String husbandOccupation;
  String husbandWorkAddress;

  PersonalInfo({
    this.fullName = '',
    this.icNumber = '',
    this.dateOfBirth,
    this.ethnic = '',
    this.citizenship = '',
    this.phoneNumber = '',
    this.homeAddress = '',
    this.occupation = '',
    this.workAddress = '',
    this.lnmp,
    this.edd,
    this.revisedEdd,
    this.antenatal_colour_code = '',
    this.husbandFullName = '',
    this.husbandIcNumber = '',
    this.husbandPhoneNumber = '',
    this.husbandOccupation = '',
    this.husbandWorkAddress = '',
  });

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      fullName: map['full_name'] ?? '',
      icNumber: map['ic_number'] ?? '',
      dateOfBirth: map['birth_date'] != null
          ? DateTime.tryParse(map['birth_date'])
          : null,
      ethnic: map['ethnic'] ?? '',
      citizenship: map['citizenship'] ?? '',
      phoneNumber: map['phone'] ?? '',
      homeAddress: map['home_address'] ?? '',
      occupation: map['occupation'] ?? '',
      workAddress: map['work_address'] ?? '',
      husbandFullName: map['husband_name'] ?? '',
      husbandIcNumber: map['husband_ic'] ?? '',
      husbandPhoneNumber: map['husband_phone'] ?? '',
      husbandOccupation: map['husband_work'] ?? '',
      husbandWorkAddress: map['husband_work_address'] ?? '',
      lnmp: map['lnmp'] != null ? DateTime.tryParse(map['lnmp']) : null,
      edd: map['edd'] != null ? DateTime.tryParse(map['edd']) : null,
      revisedEdd: map['revised_edd'] != null ? DateTime.tryParse(map['revised_edd']) : null,
      antenatal_colour_code: map['antenatal_colour_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'ic_number': icNumber,
      'birth_date': dateOfBirth?.toIso8601String(),
      'ethnic': ethnic,
      'citizenship': citizenship,
      'phone': phoneNumber,
      'home_address': homeAddress,
      'occupation': occupation,
      'work_address': workAddress,
      'husband_name': husbandFullName,
      'husband_ic': husbandIcNumber,
      'husband_phone': husbandPhoneNumber,
      'husband_work': husbandOccupation,
      'husband_work_address': husbandWorkAddress,
      'antenatal_colour_code': antenatal_colour_code,
      'lnmp': lnmp?.toIso8601String(),
      'edd': edd?.toIso8601String(),
      'revised_edd': revisedEdd?.toIso8601String(),
    };
  }
}
 
/// Healthcare Provider info (from clinic record)
class HealthcareProviderInfo {
  String nurseOrMidwifeName; // Jururawat Y/M
  String preferredDeliveryPlaceType; // Hospital / ABC / Rumah
  String preferredDeliveryPlaceName; // Name of facility chosen
 
  HealthcareProviderInfo({
    this.nurseOrMidwifeName = '',
    this.preferredDeliveryPlaceType = '',
    this.preferredDeliveryPlaceName = '',
  });
 
  factory HealthcareProviderInfo.fromMap(Map<String, dynamic> map) {
    return HealthcareProviderInfo(
      nurseOrMidwifeName: map['nurse_midwife_name'] ?? '',
      preferredDeliveryPlaceType: map['preferred_delivery_place_type'] ?? '',
      preferredDeliveryPlaceName: map['preferred_delivery_place_name'] ?? '',
    );
  }
 
  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'nurse_midwife_name': nurseOrMidwifeName,
      'preferred_delivery_place_type': preferredDeliveryPlaceType,
      'preferred_delivery_place_name': preferredDeliveryPlaceName,
    };
  }
}

/// Section 2 — Perihal Kandungan Lalu (one row per previous pregnancy)
class PreviousPregnancy {
  String? id; // supabase row id, null if not yet saved
  int? year; // Tahun
  String outcome; // Hasil Kandungan (e.g. Live birth / Miscarriage / Stillbirth)
  String deliveryType; // Jenis Kelahiran (Normal / Caesarean / Assisted)
  String placeAndAttendedBy; // Tempat & Disambut Oleh
  String gender; // Jantina
  double? birthWeightKg; // Berat Lahir (kg)
  String complicationsMother; // Komplikasi - Ibu
  String complicationsChild; // Komplikasi - Anak
  String breastfeedingDuration; // Penyusuan susu ibu / tempoh
  String childConditionNow; // Keadaan anak sekarang

  PreviousPregnancy({
    this.id,
    this.year,
    this.outcome = '',
    this.deliveryType = '',
    this.placeAndAttendedBy = '',
    this.gender = '',
    this.birthWeightKg,
    this.complicationsMother = '',
    this.complicationsChild = '',
    this.breastfeedingDuration = '',
    this.childConditionNow = '',
  });

  factory PreviousPregnancy.fromMap(Map<String, dynamic> map) {
    return PreviousPregnancy(
      id: map['id']?.toString(),
      year: map['year'],
      outcome: map['outcome'] ?? '',
      deliveryType: map['delivery_type'] ?? '',
      placeAndAttendedBy: map['place_attended_by'] ?? '',
      gender: map['gender'] ?? '',
      birthWeightKg: (map['birth_weight_kg'] as num?)?.toDouble(),
      complicationsMother: map['complications_mother'] ?? '',
      complicationsChild: map['complications_child'] ?? '',
      breastfeedingDuration: map['breastfeeding_duration'] ?? '',
      childConditionNow: map['child_condition_now'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'year': year,
      'outcome': outcome,
      'delivery_type': deliveryType,
      'place_attended_by': placeAndAttendedBy,
      'gender': gender,
      'birth_weight_kg': birthWeightKg,
      'complications_mother': complicationsMother,
      'complications_child': complicationsChild,
      'breastfeeding_duration': breastfeedingDuration,
      'child_condition_now': childConditionNow,
    };
  }
}

/// Section 3 — Riwayat Kesihatan Ibu dan Keluarga
/// + pregnancy-related fields from Profile Setup Step 2.
class MedicalHistory {
  // ---- From Profile Setup Step 2 ----
  List<String> riskFactors; // Faktor Risiko (free-text list)
  DateTime? lnmp; // THA / LNMP - Tarikh Haid Akhir
  DateTime? edd; // TAL / EDD - Tarikh Anggaran Lahir
  DateTime? revisedEdd; // RE EDD
  int? gravida;
  int? para;

  // ---- Section 3.0 - Haid & Family Planning ----
  int? menstrualCycleDays; // Jumlah Hari
  String menstrualCyclePattern; // Pusingan (regular/irregular)
  bool familyPlanningPractice; // Amalan Perancang Keluarga (Ya/Tidak)
  String familyPlanningMethod; // Kaedah
  int? familyPlanningDurationMonths; // Berapa Lama (bulan/tahun)

  // ---- Smoking status ----
  bool motherSmokes;
  bool husbandSmokes;

  // ---- Mother's medical problems (Masalah Perubatan Ibu) ----
  bool diabetes;
  bool asthma;
  bool thalassemia;
  bool hypertension;
  bool heartDisease;
  bool thyroidProblem;
  bool allergy;
  bool tuberculosis;
  bool cancer;
  bool psychiatricCondition;
  bool anemia;
  String otherMedicalConditions; // Lain-lain, nyatakan

  // ---- 3.1 TB Screening ----
  bool coughMoreThan2Weeks; // Batuk lebih 2 minggu

  // ---- 3.2 Family medical problems (Masalah Perubatan Keluarga) ----
  bool familyDiabetes;
  bool familyAsthma;
  bool familyAnemia;
  bool familyHypertension;
  bool familyHeartDisease;
  bool familyThalassemia;
  bool familyAllergy;
  bool familyTuberculosis;
  bool familyPsychiatricCondition;
  String otherFamilyConditions;

  // ---- 3.3 Tetanus / Toxoid immunization status ----
  DateTime? tetanusDose1Date;
  String tetanusDose1BatchNo;
  DateTime? tetanusDose1ExpiryDate;

  DateTime? tetanusDose2Date;
  String tetanusDose2BatchNo;
  DateTime? tetanusDose2ExpiryDate;

  DateTime? tetanusBoosterDate;
  String tetanusBoosterBatchNo;
  DateTime? tetanusBoosterExpiryDate;

  String otherImmunizations;

  MedicalHistory({
    this.riskFactors = const [],
    this.lnmp,
    this.edd,
    this.revisedEdd,
    this.gravida,
    this.para,
    this.menstrualCycleDays,
    this.menstrualCyclePattern = '',
    this.familyPlanningPractice = false,
    this.familyPlanningMethod = '',
    this.familyPlanningDurationMonths,
    this.motherSmokes = false,
    this.husbandSmokes = false,
    this.diabetes = false,
    this.asthma = false,
    this.thalassemia = false,
    this.hypertension = false,
    this.heartDisease = false,
    this.thyroidProblem = false,
    this.allergy = false,
    this.tuberculosis = false,
    this.cancer = false,
    this.psychiatricCondition = false,
    this.anemia = false,
    this.otherMedicalConditions = '',
    this.coughMoreThan2Weeks = false,
    this.familyDiabetes = false,
    this.familyAsthma = false,
    this.familyAnemia = false,
    this.familyHypertension = false,
    this.familyHeartDisease = false,
    this.familyThalassemia = false,
    this.familyAllergy = false,
    this.familyTuberculosis = false,
    this.familyPsychiatricCondition = false,
    this.otherFamilyConditions = '',
    this.tetanusDose1Date,
    this.tetanusDose1BatchNo = '',
    this.tetanusDose1ExpiryDate,
    this.tetanusDose2Date,
    this.tetanusDose2BatchNo = '',
    this.tetanusDose2ExpiryDate,
    this.tetanusBoosterDate,
    this.tetanusBoosterBatchNo = '',
    this.tetanusBoosterExpiryDate,
    this.otherImmunizations = '',
  });

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    DateTime? d(String key) =>
        map[key] != null ? DateTime.tryParse(map[key]) : null;

    return MedicalHistory(
      riskFactors: _parseRiskFactors(map['risk_factors']),
      lnmp: d('lnmp'),
      edd: d('edd'),
      revisedEdd: d('re_edd'),
      gravida: map['gravida'],
      para: map['para'],
      menstrualCycleDays: map['menstrual_cycle_days'],
      menstrualCyclePattern: map['menstrual_cycle_pattern'] ?? '',
      familyPlanningPractice: map['family_planning_practice'] ?? false,
      familyPlanningMethod: map['family_planning_method'] ?? '',
      familyPlanningDurationMonths: map['family_planning_duration_months'],
      motherSmokes: map['mother_smokes'] ?? false,
      husbandSmokes: map['husband_smokes'] ?? false,
      diabetes: map['diabetes'] ?? false,
      asthma: map['asthma'] ?? false,
      thalassemia: map['thalassemia'] ?? false,
      hypertension: map['hypertension'] ?? false,
      heartDisease: map['heart_disease'] ?? false,
      thyroidProblem: map['thyroid_problem'] ?? false,
      allergy: map['allergy'] ?? false,
      tuberculosis: map['tuberculosis'] ?? false,
      cancer: map['cancer'] ?? false,
      psychiatricCondition: map['psychiatric_condition'] ?? false,
      anemia: map['anemia'] ?? false,
      otherMedicalConditions: map['other_medical_conditions'] ?? '',
      coughMoreThan2Weeks: map['cough_more_than_2_weeks'] ?? false,
      familyDiabetes: map['family_diabetes'] ?? false,
      familyAsthma: map['family_asthma'] ?? false,
      familyAnemia: map['family_anemia'] ?? false,
      familyHypertension: map['family_hypertension'] ?? false,
      familyHeartDisease: map['family_heart_disease'] ?? false,
      familyThalassemia: map['family_thalassemia'] ?? false,
      familyAllergy: map['family_allergy'] ?? false,
      familyTuberculosis: map['family_tuberculosis'] ?? false,
      familyPsychiatricCondition: map['family_psychiatric_condition'] ?? false,
      otherFamilyConditions: map['other_family_conditions'] ?? '',
      tetanusDose1Date: d('tetanus_dose1_date'),
      tetanusDose1BatchNo: map['tetanus_dose1_batch_no'] ?? '',
      tetanusDose1ExpiryDate: d('tetanus_dose1_expiry_date'),
      tetanusDose2Date: d('tetanus_dose2_date'),
      tetanusDose2BatchNo: map['tetanus_dose2_batch_no'] ?? '',
      tetanusDose2ExpiryDate: d('tetanus_dose2_expiry_date'),
      tetanusBoosterDate: d('tetanus_booster_date'),
      tetanusBoosterBatchNo: map['tetanus_booster_batch_no'] ?? '',
      tetanusBoosterExpiryDate: d('tetanus_booster_expiry_date'),
      otherImmunizations: map['other_immunizations'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    String? iso(DateTime? dt) => dt?.toIso8601String();

    return {
      'risk_factors': riskFactors,
      'lnmp': iso(lnmp),
      'edd': iso(edd),
      're_edd': iso(revisedEdd),
      'gravida': gravida,
      'para': para,
      'menstrual_cycle_days': menstrualCycleDays,
      'menstrual_cycle_pattern': menstrualCyclePattern,
      'family_planning_practice': familyPlanningPractice,
      'family_planning_method': familyPlanningMethod,
      'family_planning_duration_months': familyPlanningDurationMonths,
      'mother_smokes': motherSmokes,
      'husband_smokes': husbandSmokes,
      'diabetes': diabetes,
      'asthma': asthma,
      'thalassemia': thalassemia,
      'hypertension': hypertension,
      'heart_disease': heartDisease,
      'thyroid_problem': thyroidProblem,
      'allergy': allergy,
      'tuberculosis': tuberculosis,
      'cancer': cancer,
      'psychiatric_condition': psychiatricCondition,
      'anemia': anemia,
      'other_medical_conditions': otherMedicalConditions,
      'cough_more_than_2_weeks': coughMoreThan2Weeks,
      'family_diabetes': familyDiabetes,
      'family_asthma': familyAsthma,
      'family_anemia': familyAnemia,
      'family_hypertension': familyHypertension,
      'family_heart_disease': familyHeartDisease,
      'family_thalassemia': familyThalassemia,
      'family_allergy': familyAllergy,
      'family_tuberculosis': familyTuberculosis,
      'family_psychiatric_condition': familyPsychiatricCondition,
      'other_family_conditions': otherFamilyConditions,
      'tetanus_dose1_date': iso(tetanusDose1Date),
      'tetanus_dose1_batch_no': tetanusDose1BatchNo,
      'tetanus_dose1_expiry_date': iso(tetanusDose1ExpiryDate),
      'tetanus_dose2_date': iso(tetanusDose2Date),
      'tetanus_dose2_batch_no': tetanusDose2BatchNo,
      'tetanus_dose2_expiry_date': iso(tetanusDose2ExpiryDate),
      'tetanus_booster_date': iso(tetanusBoosterDate),
      'tetanus_booster_batch_no': tetanusBoosterBatchNo,
      'tetanus_booster_expiry_date': iso(tetanusBoosterExpiryDate),
      'other_immunizations': otherImmunizations,
    };
  }

  static List<String> _parseRiskFactors(dynamic value) {
  if (value == null) return const [];
  if (value is List) return value.cast<String>();
  if (value is String) {
    if (value.trim().isEmpty) return const [];
    // If stored as JSON string e.g. '["Diabetes","Hypertension"]'
    if (value.trim().startsWith('[')) {
      try {
        final decoded = jsonDecode(value) as List;
        return decoded.cast<String>();
      } catch (_) {}
    }
    // If stored as comma-separated e.g. "Diabetes,Hypertension"
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return const [];
}
}