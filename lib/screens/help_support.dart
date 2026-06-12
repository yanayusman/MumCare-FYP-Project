// lib/screens/help_support.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _kBg = Color(0xFFFAF6F3);
const _kDark = Color(0xFF2D1F17);
const _kLight = Color(0xFF9B8070);
const _kBorder = Color(0xFFE8DDD6);
const _kPrimary = Color(0xFFE8A0A0);
const _kSecondary = Color(0xFFD4537E);

const _kSupportEmail = 'support@mumcare.app';
const _kWhatsAppNumber = '60123456789';
const _kUserGuideUrl = 'https://mumcare.app/guide';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  String _version = '';
  String _faqQuery = '';

  static const _faqs = [
    (
      'How do I update my pregnancy due date (EDD)?',
      'Go to Profile > Medical History and update the "EDD / TAL (Expected '
          'Delivery Date)" field, then tap Save Changes.'
    ),
    (
      'How do I add a previous pregnancy record?',
      'Go to Profile > Medical History, scroll to "Previous Pregnancy '
          'History", and tap "Add Record" to fill in the details.'
    ),
    (
      'How do I update my clinic or nurse details?',
      'Go to Profile > Healthcare Provider to update your nurse or midwife '
          'name and preferred delivery place.'
    ),
    (
      'Is my health data private?',
      'Yes. Your records are only accessible to you and are protected '
          'with row-level security. See Privacy & Security for more.'
    ),
    (
      'How do I change my password?',
      'Go to Profile > Privacy & Security > Change Password.'
    ),
    (
      'Who can I contact for medical advice?',
      'MumCare is a tracking tool, not a medical service. For medical '
          'advice, please contact your clinic or healthcare provider listed '
          'under Profile > Healthcare Provider.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      // ignore if unavailable
    }
  }

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _emailSupport({String subject = 'MumCare Support Request', String? body}) {
    _launch(Uri(
      scheme: 'mailto',
      path: _kSupportEmail,
      queryParameters: {
        'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    ));
  }

  void _callEmergency() => _launch(Uri(scheme: 'tel', path: '999'));

  void _whatsappSupport() =>
      _launch(Uri.parse('https://wa.me/$_kWhatsAppNumber'));

  void _openUserGuide() => _launch(Uri.parse(_kUserGuideUrl));

  void _showReportProblemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ReportProblemSheet(
        appVersion: _version,
        onSubmit: (subject, body) {
          Navigator.pop(ctx);
          _emailSupport(subject: subject, body: body);
        },
      ),
    );
  }

  List<(String, String)> get _filteredFaqs {
    final query = _faqQuery.trim().toLowerCase();
    if (query.isEmpty) return _faqs;
    return _faqs
        .where((faq) =>
            faq.$1.toLowerCase().contains(query) ||
            faq.$2.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDark),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: _kDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _emergencyBanner(),
              const SizedBox(height: 20),
              _sectionTitle('Contact Us'),
              _card([
                _menuRow(
                  icon: Icons.email_outlined,
                  label: 'Email Support',
                  subtitle: _kSupportEmail,
                  onTap: () => _emailSupport(),
                ),
                const Divider(height: 0, color: _kBorder, indent: 16, endIndent: 16),
                _menuRow(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp Support',
                  subtitle: 'Mon–Fri, 9am – 6pm',
                  onTap: _whatsappSupport,
                ),
                const Divider(height: 0, color: _kBorder, indent: 16, endIndent: 16),
                _menuRow(
                  icon: Icons.bug_report_outlined,
                  label: 'Report a Problem',
                  subtitle: 'Describe an issue and we will follow up',
                  onTap: _showReportProblemSheet,
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),
              _sectionTitle('Frequently Asked Questions'),
              _faqSearchField(),
              const SizedBox(height: 10),
              if (filteredFaqs.isEmpty)
                _emptyFaqState()
              else
                _faqCard(filteredFaqs),

              const SizedBox(height: 20),
              _sectionTitle('Resources'),
              _card([
                _menuRow(
                  icon: Icons.menu_book_outlined,
                  label: 'User Guide',
                  subtitle: 'Learn how to use MumCare',
                  onTap: _openUserGuide,
                ),
                const Divider(height: 0, color: _kBorder, indent: 16, endIndent: 16),
                _menuRow(
                  icon: Icons.feedback_outlined,
                  label: 'Send Feedback',
                  subtitle: 'Share ideas to improve the app',
                  onTap: () => _emailSupport(subject: 'MumCare Feedback'),
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  _version.isEmpty ? 'MumCare' : 'MumCare v$_version',
                  style: const TextStyle(fontSize: 12, color: _kLight),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emergencyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF6C9D6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_hospital_outlined,
                  color: _kSecondary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Medical Emergency?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'If you have severe bleeding, severe headache, blurred '
                      'vision, or reduced fetal movement, seek help immediately.',
                      style: TextStyle(fontSize: 12, color: _kLight, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _callEmergency,
              icon: const Icon(Icons.phone, size: 16),
              label: const Text('Call 999'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kSecondary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _faqQuery = value),
      style: const TextStyle(fontSize: 14, color: _kDark),
      decoration: InputDecoration(
        hintText: 'Search FAQs...',
        hintStyle: const TextStyle(fontSize: 14, color: _kLight),
        prefixIcon: const Icon(Icons.search, size: 20, color: _kLight),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kPrimary, width: 1.2),
        ),
      ),
    );
  }

  Widget _emptyFaqState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 32, color: _kLight),
          const SizedBox(height: 8),
          Text(
            'No FAQs match "$_faqQuery"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _kLight),
          ),
        ],
      ),
    );
  }

  Widget _faqCard(List<(String, String)> faqs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: faqs.asMap().entries.map((e) {
            final isLast = e.key == faqs.length - 1;
            return Column(
              children: [
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(
                    e.value.$1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kDark,
                    ),
                  ),
                  iconColor: _kSecondary,
                  collapsedIconColor: _kLight,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e.value.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  const Divider(
                    height: 0,
                    color: _kBorder,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }).toList(),
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
        child: Column(children: children),
      );

  Widget _menuRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _kLight),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: _kDark),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: _kLight),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFC0B0A8)),
          ],
        ),
      ),
    );
  }
}

class _ReportProblemSheet extends StatefulWidget {
  const _ReportProblemSheet({
    required this.appVersion,
    required this.onSubmit,
  });

  final String appVersion;
  final void Function(String subject, String body) onSubmit;

  @override
  State<_ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<_ReportProblemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  static const _categories = [
    'App crash or freeze',
    'Login or account issue',
    'Data not saving correctly',
    'Display or layout problem',
    'Other',
  ];

  String _category = _categories.first;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final versionLine =
        widget.appVersion.isEmpty ? '' : '\n\nApp version: ${widget.appVersion}';
    final body =
        'Category: $_category\n\nDescription:\n${_descriptionController.text.trim()}$versionLine';

    widget.onSubmit('MumCare Problem Report — $_category', body);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report a Problem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _kDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'We will open your email app with the details pre-filled.',
              style: TextStyle(fontSize: 13, color: _kLight),
            ),
            const SizedBox(height: 16),
            const Text(
              'Issue type',
              style: TextStyle(fontSize: 13, color: _kLight),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final selected = _category == category;
                return ChoiceChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : _kDark,
                    ),
                  ),
                  selected: selected,
                  selectedColor: _kSecondary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected ? _kSecondary : _kBorder,
                  ),
                  onSelected: (_) => setState(() => _category = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, color: _kDark),
              decoration: const InputDecoration(
                labelText: 'What happened?',
                alignLabelWithHint: true,
                labelStyle: TextStyle(fontSize: 13, color: _kLight),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: _kBorder),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _kPrimary, width: 1.4),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Please describe the issue in at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Send Report',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
