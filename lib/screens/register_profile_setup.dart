import 'package:flutter/material.dart';

class RegisterProfileSetup extends StatefulWidget {
  const RegisterProfileSetup({super.key});

  @override
  State<RegisterProfileSetup> createState() => _RegisterProfileSetupState();
}

class _RegisterProfileSetupState extends State<RegisterProfileSetup> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // ── Controllers ───────────────────────────────────────────────
  // Personal
  final _fullName       = TextEditingController();
  final _icNumber       = TextEditingController();
  final _birthDate      = TextEditingController();
  final _phone          = TextEditingController();
  final _homeAddress    = TextEditingController();
  final _job            = TextEditingController();
  final _jobAddress     = TextEditingController();

  // Medical
  final _riskFactors    = TextEditingController();
  final _tha            = TextEditingController(); // LNMP
  final _tal            = TextEditingController(); // EDD
  final _reEdd          = TextEditingController();
  final _gravida        = TextEditingController();
  final _para           = TextEditingController();

  // Husband
  final _husbandName    = TextEditingController();
  final _husbandIc      = TextEditingController();
  final _husbandPhone   = TextEditingController();
  final _husbandJob     = TextEditingController();
  final _husbandAddress = TextEditingController();

  // Dropdowns
  String? _selectedEthnic;
  String? _selectedCitizenship;

  final _ethnics = [
    'Malay', 'Chinese', 'Indian', 'Kadazan', 'Iban',
    'Bajau', 'Melanau', 'Bidayuh', 'Other Bumiputera', 'Other',
  ];

  final _citizenships = ['Malaysian', 'Permanent Resident', 'Non-Citizen'];

  @override
  void dispose() {
    _fullName.dispose(); _icNumber.dispose(); _birthDate.dispose();
    _phone.dispose(); _homeAddress.dispose(); _job.dispose();
    _jobAddress.dispose(); _riskFactors.dispose(); _tha.dispose();
    _tal.dispose(); _reEdd.dispose(); _gravida.dispose(); _para.dispose();
    _husbandName.dispose(); _husbandIc.dispose(); _husbandPhone.dispose();
    _husbandJob.dispose(); _husbandAddress.dispose();
    super.dispose();
  }

  // ── Steps definition ─────────────────────────────────────────
  List<_Step> get _steps => [
    _Step(title: 'Personal\nInformation', icon: Icons.person_outline),
    _Step(title: 'Medical\nInformation', icon: Icons.favorite_border),
    _Step(title: 'Husband\nInformation', icon: Icons.people_outline),
  ];

  // ── Submit ────────────────────────────────────────────────────
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: save to Firestore / backend
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: () => setState(() => _currentStep--),
              child: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Color(0xFF4A3728)),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _steps[_currentStep].title.replaceAll('\n', ' '),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9B8070)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step Indicator ────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: _steps.asMap().entries.map((e) {
          final isDone = e.key < _currentStep;
          final isActive = e.key == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive
                          ? const Color(0xFFE8A0A0)
                          : const Color(0xFFE8DDD6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (e.key < _steps.length - 1)
                  const SizedBox(width: 6),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Current Step Content ──────────────────────────────────────
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildPersonalInfo();
      case 1: return _buildMedicalInfo();
      case 2: return _buildHusbandInfo();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Personal Information ─────────────────────────────
  Widget _buildPersonalInfo() {
    return Column(
      children: [
        _field('Full Name', _fullName,
            hint: 'As per IC', icon: Icons.person_outline),
        _field('IC Number', _icNumber,
            hint: 'e.g. 900101-14-1234',
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number),
        _datePicker('Date of Birth', _birthDate,
            icon: Icons.cake_outlined),
        _dropdown('Ethnic', _ethnics, _selectedEthnic,
            Icons.group_outlined,
            (v) => setState(() => _selectedEthnic = v)),
        _dropdown('Citizenship', _citizenships, _selectedCitizenship,
            Icons.flag_outlined,
            (v) => setState(() => _selectedCitizenship = v)),
        _field('Phone Number', _phone,
            hint: 'e.g. 012-3456789',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        _field('Home Address', _homeAddress,
            hint: 'Full address',
            icon: Icons.home_outlined,
            maxLines: 2),
        _field('Occupation', _job,
            hint: 'e.g. Teacher', icon: Icons.work_outline),
        _field('Work Address', _jobAddress,
            hint: 'Full work address',
            icon: Icons.location_on_outlined,
            maxLines: 2),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Step 2: Medical Information ───────────────────────────────
  Widget _buildMedicalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Risk Factors', _riskFactors,
            hint: 'e.g. Hypertension, Diabetes',
            icon: Icons.warning_amber_outlined,
            maxLines: 2),
        const SizedBox(height: 4),
        _sectionLabel('Pregnancy Dates'),
        _datePicker('THA / LNMP (Last Normal Menstrual Period)', _tha,
            icon: Icons.calendar_month_outlined),
        _datePicker('TAL / EDD (Expected Delivery Date)', _tal,
            icon: Icons.child_care_outlined),
        _datePicker('RE EDD (Revised EDD)', _reEdd,
            icon: Icons.event_outlined),
        const SizedBox(height: 4),
        _sectionLabel('Obstetric History'),
        Row(
          children: [
            Expanded(
              child: _field('Gravida', _gravida,
                  hint: '0',
                  icon: Icons.pregnant_woman_outlined,
                  keyboardType: TextInputType.number),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field('Para', _para,
                  hint: '0',
                  icon: Icons.baby_changing_station_outlined,
                  keyboardType: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Step 3: Husband Information ───────────────────────────────
  Widget _buildHusbandInfo() {
    return Column(
      children: [
        _field('Husband\'s Full Name', _husbandName,
            hint: 'As per IC', icon: Icons.person_outline),
        _field('Husband\'s IC Number', _husbandIc,
            hint: 'e.g. 880101-14-5678',
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number),
        _field('Husband\'s Phone Number', _husbandPhone,
            hint: 'e.g. 012-3456789',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        _field('Husband\'s Occupation', _husbandJob,
            hint: 'e.g. Engineer', icon: Icons.work_outline),
        _field('Husband\'s Work Address', _husbandAddress,
            hint: 'Full work address',
            icon: Icons.location_on_outlined,
            maxLines: 2),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Navigation Buttons ────────────────────────────────────────
  Widget _buildBottomButtons() {
    final isLast = _currentStep == _steps.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (isLast) {
              _submit();
            } else {
              setState(() => _currentStep++);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8A0A0),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            isLast ? 'Complete Registration' : 'Next',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8C6A55),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Please fill in $label' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: const Color(0xFF9B8070))
              : null,
          labelStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF9B8070)),
          hintStyle:
              const TextStyle(fontSize: 13, color: Color(0xFFC0B0A8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8A0A0), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _datePicker(String label, TextEditingController ctrl,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Please select $label' : null,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFE8A0A0),
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            ctrl.text =
                '${picked.day.toString().padLeft(2, '0')}/'
                '${picked.month.toString().padLeft(2, '0')}/'
                '${picked.year}';
          }
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon ?? Icons.calendar_today_outlined,
            size: 20,
            color: const Color(0xFF9B8070),
          ),
          labelStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF9B8070)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8A0A0), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9B8070)),
          labelStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF9B8070)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8DDD6), width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8A0A0), width: 1.5),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
      ),
    );
  }
}

// ── Step model ────────────────────────────────────────────────
class _Step {
  final String title;
  final IconData icon;
  const _Step({required this.title, required this.icon});
}