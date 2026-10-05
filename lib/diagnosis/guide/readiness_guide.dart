class GuideAction {
  const GuideAction({required this.domain, required this.text});

  final String domain;
  final String text;
}

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
