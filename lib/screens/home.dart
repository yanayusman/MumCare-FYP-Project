import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';

// ── Profile completion model ────────────────────────────────────
class _ProfileSection {
  final String label;
  final IconData icon;
  final List<String> fields;
  final String route;

  const _ProfileSection({
    required this.label,
    required this.icon,
    required this.fields,
    required this.route,
  });
}

// All 28 required fields grouped by section
final _profileSections = [
  _ProfileSection(
    label: 'Personal Info',
    icon: Icons.person_outline_rounded,
    fields: [
      'full_name', 'ic_number', 'birth_date', 'ethnic',
      'citizenship', 'phone', 'home_address', 'occupation', 'work_address',
    ],
    route: '/profile-setup',
  ),
  _ProfileSection(
    label: 'Medical Info',
    icon: Icons.medical_information_outlined,
    fields: [
      'risk_factors', 'lnmp', 'edd', 're_edd', 'gravida', 'para',
      'antenatal_colour_code', 'menstrual_cycle_days', 'menstrual_cycle_pattern',
      'family_planning_practice', 'family_planning_method',
      'family_planning_duration_months', 'mother_smokes', 'husband_smokes',
    ],
    route: '/profile-setup',
  ),
  _ProfileSection(
    label: "Husband's Info",
    icon: Icons.people_outline_rounded,
    fields: [
      'husband_name', 'husband_ic', 'husband_phone',
      'husband_work', 'husband_work_address',
    ],
    route: '/profile',
  ),
];

// ── Home screen ─────────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = true;
  String? _error;

  // Raw profile data
  Map<String, dynamic> _profileData = {};

  // Computed
  String _firstName = '';
  DateTime? _edd;
  String? _antenatalColourCode;

  // Completion
  late List<_SectionCompletion> _sectionCompletions;
  int _totalFilled = 0;
  int _totalFields = 0;
  bool _showCompletionDetail = false;

  // Derived pregnancy data
  int? get _currentWeek {
    if (_edd == null) return null;
    final daysUntilDue = _edd!.difference(DateTime.now()).inDays;
    return (40 - (daysUntilDue / 7).ceil()).clamp(1, 40);
  }

  int? get _daysRemaining {
    if (_edd == null) return null;
    return _edd!.difference(DateTime.now()).inDays.clamp(0, 280);
  }

  String get _trimester {
    final w = _currentWeek;
    if (w == null) return '—';
    if (w <= 13) return '1st Trimester';
    if (w <= 26) return '2nd Trimester';
    return '3rd Trimester';
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _error = 'Not logged in.';
        });
        return;
      }

      final data = await supabase
          .from('user_profiles')
          .select(
            'full_name, ic_number, birth_date, ethnic, citizenship, phone, '
            'home_address, occupation, work_address, risk_factors, lnmp, edd, '
            're_edd, gravida, para, husband_name, husband_ic, husband_phone, '
            'husband_work, husband_work_address, antenatal_colour_code, '
            'menstrual_cycle_days, menstrual_cycle_pattern, family_planning_practice, '
            'family_planning_method, family_planning_duration_months, '
            'mother_smokes, husband_smokes',
          )
          .eq('id', user.id)
          .maybeSingle();

      final profileMap = data ?? <String, dynamic>{};
      final completions = _computeCompletion(profileMap);
      final filled = completions.fold<int>(0, (s, c) => s + c.filled);
      final total = completions.fold<int>(0, (s, c) => s + c.total);

      final fullName = profileMap['full_name'] as String?;
      final eddRaw = profileMap['edd'];

      setState(() {
        _profileData = profileMap;
        _firstName = _extractFirstName(fullName ?? user.email ?? 'Mum');
        _edd = eddRaw != null ? DateTime.tryParse(eddRaw.toString()) : null;
        _antenatalColourCode = profileMap['antenatal_colour_code'] as String?;
        _sectionCompletions = completions;
        _totalFilled = filled;
        _totalFields = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load: $e';
      });
    }
  }

  List<_SectionCompletion> _computeCompletion(Map<String, dynamic> data) {
    return _profileSections.map((section) {
      int filled = 0;
      final missing = <String>[];
      for (final field in section.fields) {
        final val = data[field];
        final isFilled = val != null &&
            val.toString().trim().isNotEmpty &&
            val.toString() != 'false'; // treat false bool as "not answered"
        // Special case: boolean fields (mother_smokes, husband_smokes) — any value counts
        final isBool = (field == 'mother_smokes' || field == 'husband_smokes');
        final countIt = isBool ? val != null : isFilled;
        if (countIt) {
          filled++;
        } else {
          missing.add(_fieldLabel(field));
        }
      }
      return _SectionCompletion(
        section: section,
        filled: filled,
        total: section.fields.length,
        missingLabels: missing,
      );
    }).toList();
  }

  String _fieldLabel(String field) {
    const labels = {
      'full_name': 'Full name',
      'ic_number': 'IC number',
      'birth_date': 'Date of birth',
      'ethnic': 'Ethnicity',
      'citizenship': 'Citizenship',
      'phone': 'Phone number',
      'home_address': 'Home address',
      'occupation': 'Occupation',
      'work_address': 'Work address',
      'risk_factors': 'Risk factors',
      'lnmp': 'Last menstrual period (LNMP)',
      'edd': 'Expected due date (EDD)',
      're_edd': 'Revised EDD',
      'gravida': 'Gravida',
      'para': 'Para',
      'antenatal_colour_code': 'Antenatal colour code',
      'menstrual_cycle_days': 'Menstrual cycle length',
      'menstrual_cycle_pattern': 'Cycle pattern',
      'family_planning_practice': 'Family planning practice',
      'family_planning_method': 'Family planning method',
      'family_planning_duration_months': 'Family planning duration',
      'mother_smokes': 'Mother smoking status',
      'husband_smokes': 'Husband smoking status',
      'husband_name': "Husband's full name",
      'husband_ic': "Husband's IC",
      'husband_phone': "Husband's phone",
      'husband_work': "Husband's occupation",
      'husband_work_address': "Husband's work address",
    };
    return labels[field] ?? field;
  }

  String _extractFirstName(String input) {
    if (input.contains('@')) return 'Mum';
    final parts = input.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'Mum';
  }

  String _monthName(int m) => [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ][m - 1];

  bool get _isProfileComplete => _totalFilled >= _totalFields;

  double get _completionPercent =>
      _totalFields == 0 ? 0 : _totalFilled / _totalFields;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE8A0A0)))
            : _error != null
                ? _buildError()
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFFD4537E),
                          onRefresh: _loadProfile,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                if (!_isProfileComplete) ...[
                                  _buildCompletionBanner(),
                                  const SizedBox(height: 12),
                                ],
                                _buildProgressCard(),
                                const SizedBox(height: 14),
                                _buildQuickActionsGrid(context),
                                const SizedBox(height: 14),
                                _buildTipCard(),
                                const SizedBox(height: 14),
                                _buildRecentActivity(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $_firstName!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _currentWeek != null
                    ? 'Week $_currentWeek · $_trimester'
                    : 'Welcome to MumCare',
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF9B8070)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF4A3728)),
            onPressed: () =>
                Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
    );
  }

  // ── Profile Completion Banner ───────────────────────────────────
  Widget _buildCompletionBanner() {
    final pct = (_completionPercent * 100).toInt();
    final remaining = _totalFields - _totalFilled;

    return Column(
      children: [
        // Main banner
        GestureDetector(
          onTap: () => setState(
              () => _showCompletionDetail = !_showCompletionDetail),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFFD0A0), width: 0.9),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Circle progress indicator
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: _completionPercent,
                            strokeWidth: 4,
                            backgroundColor:
                                const Color(0xFFFFD0A0).withOpacity(0.4),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFE87A30)),
                          ),
                          Center(
                            child: Text(
                              '$pct%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE87A30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete your profile',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5A3A10),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$remaining field${remaining == 1 ? '' : 's'} still needed · $_totalFilled of $_totalFields filled',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF8B6030)),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _showCompletionDetail ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more_rounded,
                          color: Color(0xFFE87A30), size: 22),
                    ),
                  ],
                ),
                // Mini progress bar
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _completionPercent,
                    minHeight: 5,
                    backgroundColor:
                        const Color(0xFFFFD0A0).withOpacity(0.4),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE87A30)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandable section breakdown
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _showCompletionDetail
              ? _buildSectionBreakdown()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSectionBreakdown() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        children: [
          ..._sectionCompletions.asMap().entries.map((entry) {
            final i = entry.key;
            final sc = entry.value;
            final isLast = i == _sectionCompletions.length - 1;
            return _buildSectionRow(sc, isLast: isLast);
          }),
          // CTA
          InkWell(
            onTap: () =>
                Navigator.pushNamed(context, '/profile-setup'),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFD4537E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionRow(_SectionCompletion sc, {bool isLast = false}) {
    final isDone = sc.filled == sc.total;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFFE6F5F0)
                          : const Color(0xFFFFF0E6),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      sc.section.icon,
                      size: 16,
                      color: isDone
                          ? const Color(0xFF4CAF82)
                          : const Color(0xFFE87A30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sc.section.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D1F17),
                              ),
                            ),
                            Text(
                              '${sc.filled}/${sc.total}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDone
                                    ? const Color(0xFF4CAF82)
                                    : const Color(0xFFE87A30),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: sc.filled / sc.total,
                            minHeight: 4,
                            backgroundColor:
                                const Color(0xFFE8DDD6),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDone
                                  ? const Color(0xFF4CAF82)
                                  : const Color(0xFFE87A30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDone) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF4CAF82), size: 18),
                  ],
                ],
              ),
              // Missing fields list (collapsed to max 3 with overflow)
              if (!isDone && sc.missingLabels.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildMissingFieldChips(sc.missingLabels),
              ],
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              thickness: 0.6,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFEDE6E0)),
        if (!isLast) const SizedBox(height: 2),
      ],
    );
  }

  Widget _buildMissingFieldChips(List<String> missing) {
    const maxShow = 4;
    final visible = missing.take(maxShow).toList();
    final overflow = missing.length - maxShow;

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...visible.map((label) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFFFD0A0), width: 0.7),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF8B5020)),
                ),
              )),
          if (overflow > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0EB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFE8DDD6), width: 0.7),
              ),
              child: Text(
                '+$overflow more',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9B8070)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Pregnancy progress card ────────────────────────────────────
  Widget _buildProgressCard() {
    final week = _currentWeek;
    final daysLeft = _daysRemaining;
    final progress = week != null ? week / 40.0 : 0.0;

    if (week == null) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/profile-setup'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E0D8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.child_friendly_outlined,
                  size: 36, color: Color(0xFF9B8070)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set your due date',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D1F17))),
                    SizedBox(height: 4),
                    Text(
                        'Add your EDD in your profile to see pregnancy progress here.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9B8070),
                            height: 1.4)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9B8070)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4537E), Color(0xFFE8748A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4537E).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pregnancy Progress',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(_trimester,
                      style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Week $week / 40',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% complete',
                style:
                    const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              if (daysLeft != null)
                Text(
                  '$daysLeft days to go',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
          if (_edd != null) ...[
            const SizedBox(height: 12),
            const Divider(
                color: Colors.white24, height: 0, thickness: 0.6),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Due ${_edd!.day} ${_monthName(_edd!.month)} ${_edd!.year}',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white70),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  // ── Quick Actions Grid ─────────────────────────────────────────
  Widget _buildQuickActionsGrid(BuildContext context) {
    final cards = [
      _QuickCard(
        icon: Icons.calendar_today_outlined,
        title: 'Next Appointment',
        subtitle: 'View schedule',
        route: '/appointment',
        iconColor: const Color(0xFF7B86CB),
        bgColor: const Color(0xFFEEEFF9),
      ),
      _QuickCard(
        icon: Icons.favorite_border,
        title: "Today's Health",
        subtitle: 'Log vitals',
        route: '/health',
        iconColor: const Color(0xFFD4537E),
        bgColor: const Color(0xFFFDE8EE),
      ),
      _QuickCard(
        icon: Icons.eco_outlined,
        title: 'Nutrition',
        subtitle: 'Track meals',
        route: '/nutrition',
        iconColor: const Color(0xFF5BB89A),
        bgColor: const Color(0xFFE6F5F0),
      ),
      _QuickCard(
        icon: Icons.medication_outlined,
        title: 'Medications',
        subtitle: 'View reminders',
        route: '/medicine',
        iconColor: const Color(0xFFE8A05A),
        bgColor: const Color(0xFFFFF0E6),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: cards.map((c) => _buildQuickCard(context, c)).toList(),
    );
  }

  Widget _buildQuickCard(BuildContext context, _QuickCard card) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, card.route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFE8DDD6), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: card.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(card.icon, color: card.iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(card.title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D1F17))),
            const SizedBox(height: 2),
            Text(card.subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9B8070))),
          ],
        ),
      ),
    );
  }

  // ── Tip card ───────────────────────────────────────────────────
  Widget _buildTipCard() {
    final week = _currentWeek;
    final tip = _getTipForWeek(week);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                size: 18, color: Color(0xFFE8A05A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  week != null ? 'Week $week Tip' : "Today's Tip",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D1F17)),
                ),
                const SizedBox(height: 4),
                Text(tip,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A6558),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTipForWeek(int? week) {
    if (week == null) {
      return 'Complete your profile to get personalised weekly tips for your pregnancy journey.';
    }
    if (week <= 4) return 'Take folic acid daily to support your baby\'s neural development in these early weeks.';
    if (week <= 8) return 'Morning sickness is common now. Try small, frequent meals and stay well hydrated.';
    if (week <= 12) return 'Your first trimester is nearly done! Schedule your first prenatal check-up if you haven\'t already.';
    if (week <= 16) return 'You may start feeling more energetic. Light exercise like walking is great for you and baby.';
    if (week <= 20) return 'You\'re halfway there! This is a great time for your anatomy scan to check baby\'s development.';
    if (week <= 24) return 'Your baby can now hear your voice. Talk and sing to them — they\'re listening!';
    if (week <= 28) return 'Start thinking about your birth plan. Discuss your preferences with your healthcare provider.';
    if (week <= 32) return 'Baby is growing fast! Make sure you\'re getting enough iron and calcium in your diet.';
    if (week <= 36) return 'Pack your hospital bag now. Include essentials for both you and your newborn.';
    return 'You\'re almost there! Rest when you can and keep in close contact with your healthcare provider.';
  }

  // ── Recent Activity ────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final activities = [
      _Activity(
          icon: Icons.favorite_border,
          title: 'Health logged',
          sub: 'Today'),
      _Activity(
          icon: Icons.medication_outlined,
          title: 'Folic acid reminder',
          sub: 'Due today · 8:00 AM'),
      _Activity(
          icon: Icons.calendar_today_outlined,
          title: 'Next appointment',
          sub: 'Tap to view schedule'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFE8DDD6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1F17))),
          const SizedBox(height: 12),
          ...activities.map((a) => _buildActivityRow(a)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(_Activity a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F3),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8DDD6)),
            ),
            child: Icon(a.icon,
                size: 17, color: const Color(0xFF4A3728)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D1F17))),
              Text(a.sub,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9B8070))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFD4537E), size: 40),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(
                  color: Color(0xFF9B8070), fontSize: 14)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadProfile();
            },
            child: const Text('Retry',
                style: TextStyle(color: Color(0xFFD4537E))),
          ),
        ],
      ),
    );
  }
}

// ── Helper models ──────────────────────────────────────────────
class _SectionCompletion {
  final _ProfileSection section;
  final int filled;
  final int total;
  final List<String> missingLabels;

  const _SectionCompletion({
    required this.section,
    required this.filled,
    required this.total,
    required this.missingLabels,
  });
}

class _QuickCard {
  final IconData icon;
  final String title, subtitle, route;
  final Color iconColor, bgColor;
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.iconColor,
    required this.bgColor,
  });
}

class _Activity {
  final IconData icon;
  final String title, sub;
  const _Activity(
      {required this.icon, required this.title, required this.sub});
}