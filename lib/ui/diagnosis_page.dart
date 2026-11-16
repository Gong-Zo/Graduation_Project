import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/dogs_api_client.dart';
import '../diagnosis/care_profile.dart';
import '../diagnosis/guide/readiness_guide.dart';
import '../diagnosis/guide/readiness_guide_service.dart';
import '../diagnosis/readiness_engine.dart';
import '../diagnosis/readiness_result.dart';
import 'linked_data_panel.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({
    super.key,
    this.guideService,
    this.dogsApi,
    this.initialSection = 0,
  });

  final ReadinessGuideService? guideService;
  final DogsApiClient? dogsApi;
  final int initialSection;

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  final _engine = const ReadinessEngine();
  final _absenceController = TextEditingController(text: '8');
  final _careController = TextEditingController(text: '60');
  final _outingController = TextEditingController(text: '3');
  final _budgetController = TextEditingController(text: '100000');
  final _plannedWalkController = TextEditingController();
  final _actualWalkController = TextEditingController();
  final _plannedCareController = TextEditingController();
  final _actualCareController = TextEditingController();

  HousingType _housingType = HousingType.studio;
  PetPolicy _petPolicy = PetPolicy.unknown;
  EmergencyFund _emergencyFund = EmergencyFund.partial;
  IncomeShockCapacity _incomeShock = IncomeShockCapacity.partial;
  AllergyLevel _allergy = AllergyLevel.none;
  bool _walkAccess = false;
  bool _noiseSensitive = true;
  bool _initialCost = false;
  bool _longTermPlan = false;
  bool _careContinuity = false;
  bool _loadingGuide = false;
  bool _loadingPractice = false;
  int _section = 0;
  String? _inputError;
  String? _practiceError;
  CareProfile? _profile;
  ReadinessResult? _result;
  ReadinessResult? _practiceResult;
  ReadinessGuide? _guide;
  ReadinessGuide? _practiceGuide;

  @override
  void dispose() {
    _absenceController.dispose();
    _careController.dispose();
    _outingController.dispose();
    _budgetController.dispose();
    _plannedWalkController.dispose();
    _actualWalkController.dispose();
    _plannedCareController.dispose();
    _actualCareController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection.clamp(0, 1).toInt();
  }

  Future<void> _evaluate() async {
    final absence = int.tryParse(_absenceController.text.trim());
    final care = int.tryParse(_careController.text.trim());
    final outing = int.tryParse(_outingController.text.trim());
    final budget = int.tryParse(_budgetController.text.trim());
    if (absence == null ||
        care == null ||
        outing == null ||
        budget == null ||
        absence < 0 ||
        absence > 24 ||
        care < 0 ||
        outing < 0 ||
        outing > 7 ||
        budget < 0) {
      setState(() {
        _inputError = '부재 시간, 돌봄 시간, 외출 일수, 월 예산을 숫자로 입력해 주세요.';
      });
      return;
    }

    final profile = CareProfile(
      housingType: _housingType,
      petPolicy: _petPolicy,
      walkAccess: _walkAccess,
      noiseSensitive: _noiseSensitive,
      absenceHours: absence,
      careMinutes: care,
      outingDaysPerWeek: outing,
      monthlyBudgetKrw: budget,
      canCoverInitialCost: _initialCost,
      emergencyFund: _emergencyFund,
      incomeShockCapacity: _incomeShock,
      hasLongTermPlan: _longTermPlan,
      hasCareContinuity: _careContinuity,
      allergy: _allergy,
    );
    final result = _engine.evaluate(profile);

    setState(() {
      _inputError = null;
      _practiceError = null;
      _profile = profile;
      _result = result;
      _practiceResult = null;
      _practiceGuide = null;
      _guide = null;
      _loadingGuide = true;
    });

    await _loadGuide(result);
  }

  Future<void> _applyPractice() async {
    final profile = _profile;
    if (profile == null) {
      setState(() {
        _practiceError = '자가점검을 먼저 계산하면 7일 기록과 비교할 수 있습니다.';
      });
      return;
    }
    final gap = _readGap();
    if (gap == null) {
      setState(() {
        _practiceError = '계획 산책, 실제 산책, 계획 돌봄, 실제 돌봄을 모두 숫자로 입력해 주세요.';
      });
      return;
    }

    final result = _engine.evaluate(profile, gap: gap);
    setState(() {
      _practiceError = null;
      _practiceResult = result;
      _practiceGuide = null;
      _loadingPractice = true;
    });
    final guide = await (widget.guideService ?? ReadinessGuideService())
        .explain(result);
    if (!mounted) return;
    setState(() {
      _practiceGuide = guide;
      _loadingPractice = false;
    });
  }

  Future<void> _loadGuide(ReadinessResult result) async {
    final guide = await (widget.guideService ?? ReadinessGuideService())
        .explain(result);
    if (!mounted) return;
    setState(() {
      _guide = guide;
      _loadingGuide = false;
    });
  }

  GapInput? _readGap() {
    final plannedWalk = int.tryParse(_plannedWalkController.text.trim());
    final actualWalk = int.tryParse(_actualWalkController.text.trim());
    final plannedCare = int.tryParse(_plannedCareController.text.trim());
    final actualCare = int.tryParse(_actualCareController.text.trim());
    if (plannedWalk == null ||
        actualWalk == null ||
        plannedCare == null ||
        actualCare == null ||
        plannedWalk < 0 ||
        actualWalk < 0 ||
        plannedCare < 0 ||
        actualCare < 0) {
      return null;
    }
    return GapInput(
      plannedWalkMinutes: plannedWalk,
      actualWalkMinutes: actualWalk,
      plannedCareMinutes: plannedCare,
      actualCareMinutes: actualCare,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5EF),
        title: Text(_section == 0 ? '사전 자가점검' : '7일 기록 비교'),
      ),
      body: _section == 0 ? _selfCheckBody() : _practiceBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _section,
        backgroundColor: Colors.white,
        onDestinationSelected: (index) => setState(() => _section = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: '자가점검',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: '7일 기록',
          ),
        ],
      ),
    );
  }

  Widget _selfCheckBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _introCard(
          icon: Icons.fact_check_outlined,
          title: '나의 양육 준비 살펴보기',
          description: '생활과 경제, 돌봄 준비를 간단히 입력해 점수를 확인해요. 주거 점수는 참고로만 보여 줍니다.',
        ),
        const SizedBox(height: 20),
        _numberField(_absenceController, '하루 부재 시간', '0~24시간'),
        _numberField(_careController, '확보 가능한 돌봄 시간', '분'),
        _numberField(_outingController, '주간 외출 일수', '0~7일'),
        _numberField(_budgetController, '월 양육 예산', '원'),
        const SizedBox(height: 8),
        _dropdown<HousingType>(
          label: '주거 형태',
          value: _housingType,
          items: const {
            HousingType.studio: '원룸',
            HousingType.officetel: '오피스텔',
            HousingType.apartment: '아파트',
            HousingType.house: '주택',
          },
          onChanged: (value) => setState(() => _housingType = value),
        ),
        _dropdown<PetPolicy>(
          label: '반려동물 사육',
          value: _petPolicy,
          items: const {
            PetPolicy.allowed: '가능',
            PetPolicy.unknown: '불명',
            PetPolicy.forbidden: '불가',
          },
          onChanged: (value) => setState(() => _petPolicy = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('산책 환경이 있다'),
          value: _walkAccess,
          onChanged: (value) => setState(() => _walkAccess = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('소음에 취약한 환경이다'),
          value: _noiseSensitive,
          onChanged: (value) => setState(() => _noiseSensitive = value),
        ),
        _dropdown<EmergencyFund>(
          label: '비상 의료비',
          value: _emergencyFund,
          items: const {
            EmergencyFund.none: '없음',
            EmergencyFund.partial: '일부',
            EmergencyFund.ready: '확보',
          },
          onChanged: (value) => setState(() => _emergencyFund = value),
        ),
        _dropdown<IncomeShockCapacity>(
          label: '소득이 줄어도 양육비를 유지',
          value: _incomeShock,
          items: const {
            IncomeShockCapacity.cannot: '어렵다',
            IncomeShockCapacity.partial: '일부 가능하다',
            IncomeShockCapacity.canMaintain: '유지할 수 있다',
          },
          onChanged: (value) => setState(() => _incomeShock = value),
        ),
        _dropdown<AllergyLevel>(
          label: '알레르기',
          value: _allergy,
          items: const {
            AllergyLevel.none: '없음',
            AllergyLevel.mild: '약함',
            AllergyLevel.severe: '심함',
          },
          onChanged: (value) => setState(() => _allergy = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('초기 비용을 부담할 수 있다'),
          value: _initialCost,
          onChanged: (value) => setState(() => _initialCost = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('장기 양육 계획이 있다'),
          value: _longTermPlan,
          onChanged: (value) => setState(() => _longTermPlan = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('생활이 바뀌어도 돌봄을 이어 갈 사람이 있다'),
          value: _careContinuity,
          onChanged: (value) => setState(() => _careContinuity = value),
        ),
        const SizedBox(height: 8),
        if (_inputError != null) ...[
          const SizedBox(height: 8),
          Text(
            _inputError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loadingGuide ? null : _evaluate,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFF2F6F4E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('자가점검 계산'),
        ),
        if (_result != null) ...[
          const SizedBox(height: 24),
          _ResultView(
            result: _result!,
            guide: _guide,
            loadingGuide: _loadingGuide,
            profile: _profile!,
            dogsApi: widget.dogsApi,
          ),
        ],
      ],
    );
  }

  Widget _practiceBody() {
    final practice = _practiceResult?.practice;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _introCard(
          icon: Icons.calendar_month_outlined,
          title: '7일 생활 기록 비교',
          description:
              '계획한 산책·돌봄 시간과 실제 기록을 비교해요. 먼저 사전 자가점검을 계산하면 준비 상태와 함께 살펴볼 수 있습니다.',
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE8E6DE)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _numberField(_plannedWalkController, '계획 산책 시간', '분'),
                _numberField(_actualWalkController, '실제 산책 시간', '분'),
                _numberField(_plannedCareController, '계획 돌봄 시간', '분'),
                _numberField(_actualCareController, '실제 돌봄 시간', '분'),
              ],
            ),
          ),
        ),
        if (_practiceError != null) ...[
          const SizedBox(height: 8),
          Text(
            _practiceError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _loadingPractice ? null : _applyPractice,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFF2F6F4E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('7일 기록 반영'),
        ),
        if (_practiceResult != null && practice != null) ...[
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE8E6DE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '비교 결과',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '종합 ${_practiceResult!.totalScore}점',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '생활 영역 · 자가점검 돌봄 ${practice.statedCareMinutes}분 '
                    '(${practice.statedCarePoints}점)',
                  ),
                  Text(
                    '7일 실제 돌봄 ${practice.actualCareMinutes}분 '
                    '(같은 기준 참고 ${practice.observedCarePoints}점)',
                  ),
                  const SizedBox(height: 8),
                  Text('자가점검 대비 7일 돌봄: ${practice.careClaimText}'),
                  const SizedBox(height: 8),
                  Text(
                    practice.gap.hasOverestimate
                        ? '7일 계획보다 실제 기록이 낮습니다. 종합 점수는 그대로입니다.'
                        : '7일 계획과 실제 기록의 차이는 기준 안입니다. 종합 점수는 그대로입니다.',
                  ),
                ],
              ),
            ),
          ),
          if (_loadingPractice) ...[
            const SizedBox(height: 16),
            const Text('안내를 만들고 있습니다.'),
          ],
          if (_practiceGuide != null) ...[
            const SizedBox(height: 16),
            Text(_practiceGuide!.fromModel ? 'Gemini 안내' : '엔진 안내'),
            const SizedBox(height: 8),
            Text(_practiceGuide!.summary),
            const SizedBox(height: 8),
            Text(_practiceGuide!.boundary),
          ],
        ],
      ],
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _introCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: const Color(0xFFEAF1E8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: const Color(0xFF2F6F4E)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF24352A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: const Color(0xFF5F6A60),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final entry in items.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.guide,
    required this.loadingGuide,
    required this.profile,
    required this.dogsApi,
  });

  final ReadinessResult result;
  final ReadinessGuide? guide;
  final bool loadingGuide;
  final CareProfile profile;
  final DogsApiClient? dogsApi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE8E6DE)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEAF1E8),
                      border: Border.all(color: primary, width: 5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${result.totalScore}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF24352A),
                          ),
                        ),
                        const Text('종합 점수'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    '종합 ${result.totalScore}점',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    result.labelText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _scoreBar(context, '생활', result.lifeScore),
                _scoreBar(context, '경제', result.economyScore),
                _scoreBar(context, '책임', result.responsibilityScore),
                const SizedBox(height: 10),
                Text('주거 ${result.housingScore}점 · 참고'),
                if (result.warnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final warning in result.warnings)
                    _infoLine(
                      Icons.warning_amber_rounded,
                      warning.message,
                      const Color(0xFFB96835),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (loadingGuide)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('안내를 만들고 있습니다.'),
                ],
              ),
            ),
          ),
        if (guide != null)
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE8E6DE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide!.fromModel ? 'Gemini 안내' : '엔진 안내',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(guide!.summary),
                  for (final action in guide!.actions)
                    _infoLine(Icons.check_circle_outline, action.text, primary),
                  const SizedBox(height: 6),
                  Text(guide!.housingNote),
                  const SizedBox(height: 8),
                  Text(
                    guide!.boundary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5F6A60),
                    ),
                  ),
                ],
              ),
            ),
          ),
        LinkedDataPanel(
          key: ValueKey(
            '${profile.absenceHours}-${profile.careMinutes}-${profile.outingDaysPerWeek}-${profile.monthlyBudgetKrw}-${profile.noiseSensitive}-${profile.housingType}',
          ),
          profile: profile,
          dogsApi: dogsApi,
        ),
      ],
    );
  }

  Widget _scoreBar(BuildContext context, String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 9,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: const Color(0xFFE7E9E3),
              ),
            ),
          ),
          SizedBox(width: 46, child: Text('$value점', textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
