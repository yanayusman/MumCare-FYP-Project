// lib/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maternal_health.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _saving = false;
  late PersonalInfo _info;

  // Controllers
  late TextEditingController _fullName;
  late TextEditingController _icNumber;
  late TextEditingController _ethnic;
  late TextEditingController _citizenship;
  late TextEditingController _phone;
  late TextEditingController _homeAddress;
  late TextEditingController _occupation;
  late TextEditingController _workAddress;

  late TextEditingController _husbandFullName;
  late TextEditingController _husbandIc;
  late TextEditingController _husbandPhone;
  late TextEditingController _husbandOccupation;
  late TextEditingController _husbandWorkAddress;

  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _info = PersonalInfo();
    _initControllers();
    _loadProfile();
  }

  void _initControllers() {
    _fullName = TextEditingController(text: _info.fullName);
    _icNumber = TextEditingController(text: _info.icNumber);
    _ethnic = TextEditingController(text: _info.ethnic);
    _citizenship = TextEditingController(text: _info.citizenship);
    _phone = TextEditingController(text: _info.phoneNumber);
    _homeAddress = TextEditingController(text: _info.homeAddress);
    _occupation = TextEditingController(text: _info.occupation);
    _workAddress = TextEditingController(text: _info.workAddress);

    _husbandFullName = TextEditingController(text: _info.husbandFullName);
    _husbandIc = TextEditingController(text: _info.husbandIcNumber);
    _husbandPhone = TextEditingController(text: _info.husbandPhoneNumber);
    _husbandOccupation =
        TextEditingController(text: _info.husbandOccupation);
    _husbandWorkAddress =
        TextEditingController(text: _info.husbandWorkAddress);

    _dob = _info.dateOfBirth;
  }

  Future<void> _loadProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _info = PersonalInfo.fromMap(data);
        _initControllers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      _info
        ..fullName = _fullName.text.trim()
        ..icNumber = _icNumber.text.trim()
        ..dateOfBirth = _dob
        ..ethnic = _ethnic.text.trim()
        ..citizenship = _citizenship.text.trim()
        ..phoneNumber = _phone.text.trim()
        ..homeAddress = _homeAddress.text.trim()
        ..occupation = _occupation.text.trim()
        ..workAddress = _workAddress.text.trim()
        ..husbandFullName = _husbandFullName.text.trim()
        ..husbandIcNumber = _husbandIc.text.trim()
        ..husbandPhoneNumber = _husbandPhone.text.trim()
        ..husbandOccupation = _husbandOccupation.text.trim()
        ..husbandWorkAddress = _husbandWorkAddress.text.trim();

      await _supabase.from('user_profiles').update(_info.toMap()).eq(
            'id',
            userId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal information updated')),
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

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
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
          'Personal Information',
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Personal Details'),
                      _card([
                        _textField('Full Name', _fullName, required: true),
                        _textField('IC Number', _icNumber,
                            required: true, keyboardType: TextInputType.number),
                        _dateField('Date of Birth', _dob, _pickDob),
                        _textField('Ethnic Group', _ethnic),
                        _textField('Citizenship', _citizenship),
                        _textField('Phone Number', _phone,
                            keyboardType: TextInputType.phone),
                        _textField('Home Address', _homeAddress,
                            maxLines: 3),
                        _textField('Occupation', _occupation),
                        _textField('Work Address', _workAddress,
                            maxLines: 3, isLast: true),
                      ]),
                      const SizedBox(height: 20),
                      _sectionTitle('Husband Information'),
                      _card([
                        _textField('Full Name', _husbandFullName),
                        _textField('IC Number', _husbandIc,
                            keyboardType: TextInputType.number),
                        _textField('Phone Number', _husbandPhone,
                            keyboardType: TextInputType.phone),
                        _textField('Occupation', _husbandOccupation),
                        _textField('Work Address', _husbandWorkAddress,
                            maxLines: 3, isLast: true),
                      ]),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kSecondary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
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
            ),
    );
  }

  // ── Shared widgets ───────────────────────────────────────────
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(children: children),
      );

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 12 : 0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _kDark),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: const TextStyle(fontSize: 13, color: _kLight),
          isDense: true,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: _kBorder),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _kPrimary, width: 1.4),
          ),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _dateField(
    String label,
    DateTime? value,
    VoidCallback onTap,
  ) {
    final text = value == null
        ? ''
        : '${value.day.toString().padLeft(2, '0')}/'
            '${value.month.toString().padLeft(2, '0')}/'
            '${value.year}';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: onTap,
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

  @override
  void dispose() {
    _fullName.dispose();
    _icNumber.dispose();
    _ethnic.dispose();
    _citizenship.dispose();
    _phone.dispose();
    _homeAddress.dispose();
    _occupation.dispose();
    _workAddress.dispose();
    _husbandFullName.dispose();
    _husbandIc.dispose();
    _husbandPhone.dispose();
    _husbandOccupation.dispose();
    _husbandWorkAddress.dispose();
    super.dispose();
  }
}