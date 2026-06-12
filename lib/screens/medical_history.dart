// lib/screens/medical_history.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maternal_health.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _saving = false;

  late MedicalHistory _history;
  List<PreviousPregnancy> _pregnancies = [];

  // Controllers for free-text / numeric fields
  final _riskFactorController = TextEditingController();
  late TextEditingController _gravida;
  late TextEditingController _para;
  late TextEditingController _cycleDays;
  late TextEditingController _cyclePattern;
  late TextEditingController _fpMethod;
  late TextEditingController _fpDuration;
  late TextEditingController _otherMedical;
  late TextEditingController _otherFamily;
  late TextEditingController _otherImmunizations;
  late TextEditingController _dose1Batch;
  late TextEditingController _dose2Batch;
  late TextEditingController _boosterBatch;

  @override
  void initState() {
    super.initState();
    _history = MedicalHistory();
    _initControllers();
    _loadData();
  }

  void _initControllers() {
    _gravida = TextEditingController(text: _history.gravida?.toString() ?? '');
    _para = TextEditingController(text: _history.para?.toString() ?? '');
    _cycleDays = TextEditingController(
        text: _history.menstrualCycleDays?.toString() ?? '');
    _cyclePattern = TextEditingController(text: _history.menstrualCyclePattern);
    _fpMethod = TextEditingController(text: _history.familyPlanningMethod);
    _fpDuration = TextEditingController(
        text: _history.familyPlanningDurationMonths?.toString() ?? '');
    _otherMedical = TextEditingController(text: _history.otherMedicalConditions);
    _otherFamily = TextEditingController(text: _history.otherFamilyConditions);
    _otherImmunizations =
        TextEditingController(text: _history.otherImmunizations);
    _dose1Batch = TextEditingController(text: _history.tetanusDose1BatchNo);
    _dose2Batch = TextEditingController(text: _history.tetanusDose2BatchNo);
    _boosterBatch = TextEditingController(text: _history.tetanusBoosterBatchNo);
  }

  Future<void> _loadData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      final profile = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        _history = MedicalHistory.fromMap(profile);
        _initControllers();
      }

      final pregnancies = await _supabase
          .from('pregnancy_history')
          .select()
          .eq('user_id', userId)
          .order('year', ascending: true);

      _pregnancies = (pregnancies as List)
          .map((e) => PreviousPregnancy.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load medical history: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      _history
        ..gravida = int.tryParse(_gravida.text)
        ..para = int.tryParse(_para.text)
        ..menstrualCycleDays = int.tryParse(_cycleDays.text)
        ..menstrualCyclePattern = _cyclePattern.text.trim()
        ..familyPlanningMethod = _fpMethod.text.trim()
        ..familyPlanningDurationMonths = int.tryParse(_fpDuration.text)
        ..otherMedicalConditions = _otherMedical.text.trim()
        ..otherFamilyConditions = _otherFamily.text.trim()
        ..otherImmunizations = _otherImmunizations.text.trim()
        ..tetanusDose1BatchNo = _dose1Batch.text.trim()
        ..tetanusDose2BatchNo = _dose2Batch.text.trim()
        ..tetanusBoosterBatchNo = _boosterBatch.text.trim();

      await _supabase
          .from('user_profiles')
          .update(_history.toMap())
          .eq('id', userId);

      // Upsert previous pregnancy records
      for (final p in _pregnancies) {
        final map = p.toMap()..['user_id'] = userId;
        await _supabase.from('pregnancy_history').upsert(map);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical history updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate(
      DateTime? current, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  void _addRiskFactor() {
    final text = _riskFactorController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _history.riskFactors = [..._history.riskFactors, text];
      _riskFactorController.clear();
    });
  }

  void _removeRiskFactor(String factor) {
    setState(() {
      _history.riskFactors =
          _history.riskFactors.where((f) => f != factor).toList();
    });
  }

  void _addPregnancyRecord() {
    setState(() => _pregnancies.add(PreviousPregnancy()));
  }

  void _removePregnancyRecord(int index) {
    setState(() => _pregnancies.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDark),
        title: const Text(
          'Medical History',
          style: TextStyle(
            color: _kDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kSecondary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Pregnancy Information'),
                    _card([
                      _textField('Gravida', _gravida,
                          keyboardType: TextInputType.number),
                      _textField('Para', _para,
                          keyboardType: TextInputType.number),
                      _dateField(
                          'LNMP / THA (Last Normal Menstrual Period)',
                          _history.lnmp,
                          (d) => setState(() => _history.lnmp = d)),
                      _dateField(
                          'EDD / TAL (Expected Delivery Date)',
                          _history.edd,
                          (d) => setState(() => _history.edd = d)),
                      _dateField(
                          'Revised EDD',
                          _history.revisedEdd,
                          (d) => setState(() => _history.revisedEdd = d),
                          isLast: true),
                    ]),
                    const SizedBox(height: 12),
                    _riskFactorsCard(),

                    const SizedBox(height: 20),
                    _sectionTitle('Menstrual History & Family Planning'),
                    _card([
                      _textField('Menstrual Cycle Length (days)', _cycleDays,
                          keyboardType: TextInputType.number),
                      _textField(
                          'Cycle Pattern (e.g. Regular / Irregular)',
                          _cyclePattern),
                      _switchRow(
                          'Practices Family Planning',
                          _history.familyPlanningPractice,
                          (v) => setState(
                              () => _history.familyPlanningPractice = v)),
                      if (_history.familyPlanningPractice) ...[
                        _textField('Method', _fpMethod),
                        _textField('Duration (months)', _fpDuration,
                            keyboardType: TextInputType.number, isLast: true),
                      ] else
                        const SizedBox(height: 8),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle('Smoking Status'),
                    _card([
                      _switchRow('Mother Smokes', _history.motherSmokes,
                          (v) => setState(() => _history.motherSmokes = v)),
                      _switchRow('Husband Smokes', _history.husbandSmokes,
                          (v) => setState(() => _history.husbandSmokes = v),
                          isLast: true),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle("Mother's Medical Conditions"),
                    _card([
                      _checkRow('Diabetes', _history.diabetes,
                          (v) => setState(() => _history.diabetes = v ?? false)),
                      _checkRow('Asthma', _history.asthma,
                          (v) => setState(() => _history.asthma = v ?? false)),
                      _checkRow('Thalassemia', _history.thalassemia,
                          (v) => setState(() => _history.thalassemia = v ?? false)),
                      _checkRow('Hypertension', _history.hypertension,
                          (v) => setState(() => _history.hypertension = v ?? false)),
                      _checkRow('Heart Disease', _history.heartDisease,
                          (v) => setState(() => _history.heartDisease = v ?? false)),
                      _checkRow('Thyroid Problem', _history.thyroidProblem,
                          (v) => setState(() => _history.thyroidProblem = v ?? false)),
                      _checkRow('Allergy', _history.allergy,
                          (v) => setState(() => _history.allergy = v ?? false)),
                      _checkRow('Tuberculosis', _history.tuberculosis,
                          (v) => setState(() => _history.tuberculosis = v ?? false)),
                      _checkRow('Cancer', _history.cancer,
                          (v) => setState(() => _history.cancer = v ?? false)),
                      _checkRow('Psychiatric Condition',
                          _history.psychiatricCondition,
                          (v) => setState(
                              () => _history.psychiatricCondition = v ?? false)),
                      _checkRow('Anemia', _history.anemia,
                          (v) => setState(() => _history.anemia = v ?? false)),
                      _textField('Other (please specify)', _otherMedical,
                          isLast: true),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle('TB Screening'),
                    _card([
                      _switchRow(
                          'Cough for more than 2 weeks?',
                          _history.coughMoreThan2Weeks,
                          (v) => setState(
                              () => _history.coughMoreThan2Weeks = v),
                          isLast: true),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle('Family Medical Conditions'),
                    _card([
                      _checkRow('Diabetes', _history.familyDiabetes,
                          (v) => setState(() => _history.familyDiabetes = v ?? false)),
                      _checkRow('Asthma', _history.familyAsthma,
                          (v) => setState(() => _history.familyAsthma = v ?? false)),
                      _checkRow('Anemia', _history.familyAnemia,
                          (v) => setState(() => _history.familyAnemia = v ?? false)),
                      _checkRow('Hypertension', _history.familyHypertension,
                          (v) => setState(() => _history.familyHypertension = v ?? false)),
                      _checkRow('Heart Disease', _history.familyHeartDisease,
                          (v) => setState(() => _history.familyHeartDisease = v ?? false)),
                      _checkRow('Thalassemia', _history.familyThalassemia,
                          (v) => setState(() => _history.familyThalassemia = v ?? false)),
                      _checkRow('Allergy', _history.familyAllergy,
                          (v) => setState(() => _history.familyAllergy = v ?? false)),
                      _checkRow('Tuberculosis', _history.familyTuberculosis,
                          (v) => setState(() => _history.familyTuberculosis = v ?? false)),
                      _checkRow('Psychiatric Condition',
                          _history.familyPsychiatricCondition,
                          (v) => setState(() =>
                              _history.familyPsychiatricCondition = v ?? false)),
                      _textField('Other (please specify)', _otherFamily,
                          isLast: true),
                    ]),

                    const SizedBox(height: 20),
                    _sectionTitle('Tetanus / Toxoid Immunization'),
                    _card([
                      _immunizationGroup(
                          'Dose 1',
                          _history.tetanusDose1Date,
                          _dose1Batch,
                          _history.tetanusDose1ExpiryDate,
                          (d) => setState(() => _history.tetanusDose1Date = d),
                          (d) => setState(
                              () => _history.tetanusDose1ExpiryDate = d)),
                      const Divider(height: 20, color: _kBorder),
                      _immunizationGroup(
                          'Dose 2',
                          _history.tetanusDose2Date,
                          _dose2Batch,
                          _history.tetanusDose2ExpiryDate,
                          (d) => setState(() => _history.tetanusDose2Date = d),
                          (d) => setState(
                              () => _history.tetanusDose2ExpiryDate = d)),
                      const Divider(height: 20, color: _kBorder),
                      _immunizationGroup(
                          'Booster Dose',
                          _history.tetanusBoosterDate,
                          _boosterBatch,
                          _history.tetanusBoosterExpiryDate,
                          (d) => setState(
                              () => _history.tetanusBoosterDate = d),
                          (d) => setState(
                              () => _history.tetanusBoosterExpiryDate = d)),
                      const Divider(height: 20, color: _kBorder),
                      _textField(
                          'Other Immunizations', _otherImmunizations,
                          isLast: true),
                    ]),

                    const SizedBox(height: 20),
                    _previousPregnanciesSection(),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kSecondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Risk factors ─────────────────────────────────────────────
  Widget _riskFactorsCard() {
    return _card([
      const Padding(
        padding: EdgeInsets.only(top: 12, bottom: 6),
        child: Text('Risk Factors',
            style: TextStyle(fontSize: 13, color: _kLight)),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _history.riskFactors
            .map((f) => Chip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFFFDE8EE),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => _removeRiskFactor(f),
                ))
            .toList(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _riskFactorController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Add a risk factor',
                  hintStyle: TextStyle(fontSize: 13, color: _kLight),
                  isDense: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: _kBorder),
                  ),
                ),
                onSubmitted: (_) => _addRiskFactor(),
              ),
            ),
            IconButton(
              onPressed: _addRiskFactor,
              icon: const Icon(Icons.add_circle, color: _kSecondary),
            ),
          ],
        ),
      ),
    ]);
  }

  // ── Previous pregnancies (Section 2) ─────────────────────────
  Widget _previousPregnanciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Previous Pregnancy History'),
            TextButton.icon(
              onPressed: _addPregnancyRecord,
              icon: const Icon(Icons.add, size: 18, color: _kSecondary),
              label: const Text('Add Record',
                  style: TextStyle(color: _kSecondary, fontSize: 13)),
            ),
          ],
        ),
        if (_pregnancies.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder, width: 0.8),
            ),
            child: const Text(
              'No previous pregnancy records yet. Tap "Add Record" to add one.',
              style: TextStyle(fontSize: 13, color: _kLight),
            ),
          ),
        ...List.generate(_pregnancies.length, (i) => _pregnancyCard(i)),
      ],
    );
  }

  Widget _pregnancyCard(int index) {
    final p = _pregnancies[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: ExpansionTile(
        key: ValueKey('pregnancy_${p.id ?? index}'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          p.year != null
              ? 'Pregnancy (${p.year})'
              : 'Pregnancy Record ${index + 1}',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: _kDark),
        ),
        subtitle: Text(
          p.outcome.isEmpty ? 'Tap to fill in details' : p.outcome,
          style: const TextStyle(fontSize: 12, color: _kLight),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline,
              color: _kSecondary, size: 20),
          onPressed: () => _removePregnancyRecord(index),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _textField(
                    'Year',
                    TextEditingController(text: p.year?.toString() ?? ''),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => p.year = int.tryParse(v)),
                _textField(
                    'Outcome (e.g. Live birth / Miscarriage / Stillbirth)',
                    TextEditingController(text: p.outcome),
                    onChanged: (v) => p.outcome = v),
                _textField(
                    'Delivery Type (Normal / Caesarean / Assisted)',
                    TextEditingController(text: p.deliveryType),
                    onChanged: (v) => p.deliveryType = v),
                _textField(
                    'Place & Attended By',
                    TextEditingController(text: p.placeAndAttendedBy),
                    onChanged: (v) => p.placeAndAttendedBy = v),
                _textField(
                    'Gender (Male / Female)',
                    TextEditingController(text: p.gender),
                    onChanged: (v) => p.gender = v),
                _textField(
                    'Birth Weight (kg)',
                    TextEditingController(
                        text: p.birthWeightKg?.toString() ?? ''),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => p.birthWeightKg = double.tryParse(v)),
                _textField(
                    'Complications (Mother)',
                    TextEditingController(text: p.complicationsMother),
                    onChanged: (v) => p.complicationsMother = v),
                _textField(
                    'Complications (Child)',
                    TextEditingController(text: p.complicationsChild),
                    onChanged: (v) => p.complicationsChild = v),
                _textField(
                    'Breastfeeding Duration',
                    TextEditingController(text: p.breastfeedingDuration),
                    onChanged: (v) => p.breastfeedingDuration = v),
                _textField(
                    "Child's Condition Now",
                    TextEditingController(text: p.childConditionNow),
                    onChanged: (v) => p.childConditionNow = v,
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared field widgets ─────────────────────────────────────
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4, top: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _kDark,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: children),
      );

  Widget _textField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 12 : 0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: _kDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: _kLight),
          isDense: true,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: _kBorder),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _kPrimary, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _dateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onPicked, {
    bool isLast = false,
  }) {
    final text = value == null
        ? ''
        : '${value.day.toString().padLeft(2, '0')}/'
            '${value.month.toString().padLeft(2, '0')}/'
            '${value.year}';
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 12 : 0),
      child: InkWell(
        onTap: () => _pickDate(value, onPicked),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 13, color: _kLight),
            isDense: true,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: _kBorder),
            ),
            suffixIcon: const Icon(Icons.calendar_today_outlined,
                size: 18, color: _kLight),
          ),
          child: Text(
            text.isEmpty ? 'Select date' : text,
            style: TextStyle(
              fontSize: 14,
              color: text.isEmpty ? _kLight : _kDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: isLast ? 8 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: _kDark)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _kSecondary,
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontSize: 14, color: _kDark)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: _kSecondary,
    );
  }

  Widget _immunizationGroup(
    String label,
    DateTime? date,
    TextEditingController batchController,
    DateTime? expiry,
    ValueChanged<DateTime> onDatePicked,
    ValueChanged<DateTime> onExpiryPicked,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _kDark)),
          _dateField('Date Given', date, onDatePicked),
          _textField('Batch No.', batchController),
          _dateField('Expiry Date', expiry, onExpiryPicked, isLast: true),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _riskFactorController.dispose();
    _gravida.dispose();
    _para.dispose();
    _cycleDays.dispose();
    _cyclePattern.dispose();
    _fpMethod.dispose();
    _fpDuration.dispose();
    _otherMedical.dispose();
    _otherFamily.dispose();
    _otherImmunizations.dispose();
    _dose1Batch.dispose();
    _dose2Batch.dispose();
    _boosterBatch.dispose();
    super.dispose();
  }
}