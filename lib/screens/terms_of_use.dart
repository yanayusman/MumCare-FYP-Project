import 'package:flutter/material.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  static const _lastUpdated = 'June 2026';

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: 'Acceptance of Terms',
      body:
          'By downloading, installing, or using MumCare, you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the app. We may update these terms from time to time — continued use of MumCare after changes are posted means you accept the revised terms.',
    ),
    _TermsSection(
      title: 'Who MumCare Is For',
      body:
          'MumCare is designed to support pregnant women and new mothers in managing their maternal health journey. You must be at least 18 years old to create an account. By registering, you confirm that the information you provide is accurate and up to date.',
    ),
    _TermsSection(
      title: 'Health Information Disclaimer',
      body:
          'MumCare provides general health information and tracking tools for personal use only. The content within this app — including tips, reminders, and educational articles — does not constitute medical advice and is not a substitute for professional medical consultation, diagnosis, or treatment.\n\nAlways seek guidance from your doctor, midwife, or qualified healthcare provider regarding any medical questions or concerns related to your pregnancy.',
    ),
    _TermsSection(
      title: 'Your Account & Data',
      body:
          'You are responsible for keeping your account credentials secure. Do not share your password with others. Any activity under your account is your responsibility.\n\nWe collect and store health-related data you enter — such as vitals, appointments, and nutrition logs — solely to provide app functionality. We do not sell your personal data to third parties. Please review our Privacy Policy for full details on how your data is handled.',
    ),
    _TermsSection(
      title: 'Appropriate Use',
      body:
          'You agree not to misuse MumCare. This includes attempting to access other users\' data, interfering with app functionality, uploading harmful or misleading content, or using the app for any unlawful purpose. We reserve the right to suspend accounts that violate these terms.',
    ),
    _TermsSection(
      title: 'Intellectual Property',
      body:
          'All content within MumCare — including text, graphics, icons, and educational materials — is the property of MumCare and protected by applicable intellectual property laws. You may not reproduce, distribute, or create derivative works from any part of the app without prior written permission.',
    ),
    _TermsSection(
      title: 'Third-Party Services',
      body:
          'MumCare uses third-party services (such as Supabase for data storage and Google for sign-in) to deliver its features. Your use of these services is also subject to their respective terms and privacy policies. We are not responsible for the practices of third-party providers.',
    ),
    _TermsSection(
      title: 'Limitation of Liability',
      body:
          'MumCare is provided "as is" without warranties of any kind. To the fullest extent permitted by law, we are not liable for any indirect, incidental, or consequential damages arising from your use of the app, including reliance on health information provided within it.',
    ),
    _TermsSection(
      title: 'Changes & Termination',
      body:
          'We reserve the right to modify, suspend, or discontinue MumCare at any time. We may also terminate or restrict your account if these terms are violated. Where possible, we will provide reasonable notice of significant changes.',
    ),
    _TermsSection(
      title: 'Contact Us',
      body:
          'If you have questions about these Terms of Use, please reach out through the Help & Support section of the app. We\'re here to help.',
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

  // ── Header ────────────────────────────────────────────────────
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
            'Terms of Use',
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

  // ── Intro block ───────────────────────────────────────────────
  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8EE),
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
                  color: const Color(0xFFD4537E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFD4537E),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'MumCare Terms of Use',
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
            'Please read these terms carefully before using MumCare. They explain your rights, our responsibilities, and how we handle your health data.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7A4F5A),
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

  // ── Section ───────────────────────────────────────────────────
  Widget _buildSection(_TermsSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with pink left accent
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 18,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A0A0),
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

// ── Data model ─────────────────────────────────────────────────
class _TermsSection {
  final String title;
  final String body;
  const _TermsSection({required this.title, required this.body});
}