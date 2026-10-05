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
  const DiagnosisPage({super.key, this.guideService, this.dogsApi});

  final ReadinessGuideService? guideService;
  final DogsApiClient? dogsApi;

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
      appBar: AppBar(title: Text(_section == 0 ? '사전 자가점검' : '7일 기록')),
      body: _section == 0 ? _selfCheckBody() : _practiceBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _section,
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
        Text('1인 가구 예비 반려인', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('사전 자가점검으로 생활, 경제, 책임 점수를 계산합니다. 주거 점수는 참고로만 보여 줍니다.'),
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
        Text('7일 평균 기록', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text(
          '자가점검 화면과 별도로 입력합니다. 자가점검이 있으면 같은 알고리즘이 생활 영역의 돌봄 점수표로 비교하고, 종합 점수는 바꾸지 않습니다.',
        ),
        const SizedBox(height: 16),
        _numberField(_plannedWalkController, '계획 산책 시간', '분'),
        _numberField(_actualWalkController, '실제 산책 시간', '분'),
        _numberField(_plannedCareController, '계획 돌봄 시간', '분'),
        _numberField(_actualCareController, '실제 돌봄 시간', '분'),
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
          child: const Text('7일 기록 반영'),
        ),
        if (_practiceResult != null && practice != null) ...[
          const SizedBox(height: 24),
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
          Text('자가점검 대비 7일 돌봄: ${practice.careClaimText}'),
          Text(
            practice.gap.hasOverestimate
                ? '7일 계획보다 실제 기록이 낮습니다. 종합 점수는 그대로입니다.'
                : '7일 계획과 실제 기록의 차이는 기준 안입니다. 종합 점수는 그대로입니다.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '종합 ${result.totalScore}점',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(result.labelText, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text('생활 ${result.lifeScore}점'),
        Text('경제 ${result.economyScore}점'),
        Text('책임 ${result.responsibilityScore}점'),
        Text('주거 ${result.housingScore}점 · 참고'),
        if (result.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final warning in result.warnings) Text(warning.message),
        ],
        const SizedBox(height: 16),
        if (loadingGuide) const Text('안내를 만들고 있습니다.'),
        if (guide != null) ...[
          Text(guide!.fromModel ? 'Gemini 안내' : '엔진 안내'),
          const SizedBox(height: 8),
          Text(guide!.summary),
          const SizedBox(height: 8),
          for (final action in guide!.actions) ...[
            Text(action.text),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 8),
          Text(guide!.housingNote),
          const SizedBox(height: 8),
          Text(guide!.boundary),
        ],
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
}
