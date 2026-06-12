// lib/screens/healthcare_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maternal_health.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);

const _placeTypes = ['Hospital', 'ABC', 'Rumah'];

class HealthcareProvider extends StatefulWidget {
  const HealthcareProvider({super.key});

  @override
  State<HealthcareProvider> createState() =>
      _HealthcareProviderScreenState();
}

class _HealthcareProviderScreenState extends State<HealthcareProvider> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _saving = false;

  late HealthcareProviderInfo _info;
  late TextEditingController _nurseName;
  late TextEditingController _placeName;
  String? _placeType;

  @override
  void initState() {
    super.initState();
    _info = HealthcareProviderInfo();
    _initControllers();
    _loadData();
  }

  void _initControllers() {
    _nurseName = TextEditingController(text: _info.nurseOrMidwifeName);
    _placeName = TextEditingController(text: _info.preferredDeliveryPlaceName);
    _placeType = _info.preferredDeliveryPlaceType.isEmpty
        ? null
        : _info.preferredDeliveryPlaceType;
  }

  Future<void> _loadData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }
      final data = await _supabase
          .from('healthcare_providers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        _info = HealthcareProviderInfo.fromMap(data);
        _initControllers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: $e')),
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

      _info
        ..nurseOrMidwifeName = _nurseName.text.trim()
        ..preferredDeliveryPlaceType = _placeType ?? ''
        ..preferredDeliveryPlaceName = _placeName.text.trim();

      await _supabase
          .from('healthcare_providers')
          .upsert(_info.toMap(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Healthcare provider info updated')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDark),
        title: const Text(
          'Healthcare Provider',
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
                    _sectionTitle('Assigned Nurse / Midwife'),
                    _card([
                      _textField('Nurse / Midwife Name (Jururawat Y/M)',
                          _nurseName, isLast: true),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle('Preferred Place of Delivery'),
                    _card([
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: DropdownButtonFormField<String>(
                          value: _placeType,
                          decoration: const InputDecoration(
                            labelText: 'Type (Tempat bersalin pilihan)',
                            labelStyle:
                                TextStyle(fontSize: 13, color: _kLight),
                            isDense: true,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: _kBorder),
                            ),
                          ),
                          style: const TextStyle(fontSize: 14, color: _kDark),
                          items: _placeTypes
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                        t == 'ABC'
                                            ? 'ABC (Alternative Birthing Centre)'
                                            : t),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _placeType = v),
                        ),
                      ),
                      _textField('Facility / Hospital Name', _placeName,
                          isLast: true),
                    ]),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: children),
      );

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 12 : 0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
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

  @override
  void dispose() {
    _nurseName.dispose();
    _placeName.dispose();
    super.dispose();
  }
}