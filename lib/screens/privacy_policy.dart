// lib/screens/privacy_policy.dart
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  static const _lastUpdated = 'June 2026';

  static const List<_Section> _sections = [
    _Section(
      title: 'Information We Collect',
      body:
          'We collect information you provide directly when you register and use MumCare:\n\n'
          '• Personal details (name, IC number, date of birth, phone number)\n'
          '• Medical information (LNMP, EDD, gravida, para, risk factors)\n'
          '• Health records you log (vitals, weight, symptoms, baby kicks)\n'
          '• Appointment and nutrition data\n'
          '• Profile photo if you choose to upload one\n\n'
          'We also collect basic usage data (device type, app version) to improve performance.',
    ),
    _Section(
      title: 'How We Use Your Information',
      body:
          'Your data is used solely to:\n\n'
          '• Provide and personalise the MumCare experience\n'
          '• Track your pregnancy progress and health trends\n'
          '• Send appointment and medication reminders\n'
          '• Improve app features based on anonymised usage patterns\n\n'
          'We do not use your data for advertising and we never sell your personal information.',
    ),
    _Section(
      title: 'Data Storage & Security',
      body:
          'Your data is stored securely using Supabase (PostgreSQL) with encryption at rest and in transit. '
          'Profile photos are stored in a private, access-controlled storage bucket.\n\n'
          'We implement industry-standard security practices including row-level security (RLS) '
          'so that only you can access your own records.',
    ),
    _Section(
      title: 'Data Sharing',
      body:
          'We do not sell, rent, or trade your personal information. Your data may only be shared:\n\n'
          '• With your explicit consent (e.g. sharing records with a healthcare provider)\n'
          '• When required by Malaysian law or a valid legal process\n'
          '• With trusted infrastructure providers (Supabase, Google) who are contractually '
          'bound to protect your data\n\n'
          'These providers act as data processors only and cannot use your information for their own purposes.',
    ),
    _Section(
      title: 'Your Rights',
      body:
          'You have the right to:\n\n'
          '• Access all personal data we hold about you\n'
          '• Correct inaccurate information via the app\n'
          '• Request a full export of your data (via Privacy & Security settings)\n'
          '• Delete your account and all associated data at any time\n\n'
          'To exercise any of these rights, use the options in Privacy & Security or contact us via Help & Support.',
    ),
    _Section(
      title: 'Data Retention',
      body:
          'We retain your data for as long as your account is active. '
          'If you delete your account, all personal data and health records are permanently '
          'removed from our systems within 30 days. Anonymised, aggregated data may be '
          'retained for service improvement purposes.',
    ),
    _Section(
      title: 'Children\'s Privacy',
      body:
          'MumCare is intended for adults aged 18 and above. We do not knowingly collect '
          'personal information from anyone under 18. If you believe a minor has created '
          'an account, please contact us and we will remove the data promptly.',
    ),
    _Section(
      title: 'Cookies & Analytics',
      body:
          'The MumCare mobile app does not use cookies. We may use anonymised, '
          'aggregated analytics to understand how the app is used overall — '
          'this data cannot be linked back to any individual user.',
    ),
    _Section(
      title: 'Changes to This Policy',
      body:
          'We may update this Privacy Policy from time to time. When we do, '
          'we will update the "Last updated" date at the top of this page. '
          'Significant changes will be communicated via an in-app notification. '
          'Continued use of MumCare after changes take effect constitutes acceptance of the revised policy.',
    ),
    _Section(
      title: 'Contact Us',
      body:
          'If you have questions, concerns, or requests regarding your privacy or this policy, '
          'please reach out through the Help & Support section in the app. '
          'We aim to respond to all privacy-related enquiries within 5 business days.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),
                    ..._sections.map((s) => _buildSection(s)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDE5DE), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF2D1F17),
            iconSize: 20,
          ),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1F17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF4A90D9),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'MumCare handles sensitive health information. This policy explains exactly what we collect, why, and how we protect it.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4A6080),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: $_lastUpdated',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9B8070),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(_Section section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 18,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D1F17),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              section.body,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B5A52),
                height: 1.65,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEDE5DE), thickness: 0.6),
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});
}