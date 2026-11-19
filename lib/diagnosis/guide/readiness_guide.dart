/// 영역별 실천 문장. domain은 life/economy/responsibility.
class GuideAction {
  const GuideAction({required this.domain, required this.text});

  final String domain;
  final String text;
}

/// 화면에 보여줄 안내. fromModel이 false면 로컬 문구다.
class ReadinessGuide {
  const ReadinessGuide({
    required this.summary,
    required this.actions,
    required this.housingNote,
    required this.boundary,
    required this.fromModel,
  });

  final String summary;
  final List<GuideAction> actions;
  final String housingNote;
  final String boundary;
  final bool fromModel;
}
