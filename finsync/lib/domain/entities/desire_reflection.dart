/// As perguntas que a app faz antes de deixar criar um desejo.
///
/// A ordem importa: começa no mais objetivo (precisas mesmo?) e acaba no
/// mais revelador (já esperaste?). Quem responde de seguida costuma
/// perceber sozinho, a meio da lista, que afinal não quer aquilo.
enum ReflectionQuestion {
  survival,
  lifestyle,
  dream,
  afford,
  waited;

  String get labelKey => 'desire.reflection_q_$name';
  String get hintKey => 'desire.reflection_h_$name';
}

/// Respostas às perguntas de reflexão, com a pontuação que delas resulta.
class DesireReflection {
  final Map<ReflectionQuestion, bool> answers;
  final DateTime? answeredAt;

  const DesireReflection({this.answers = const {}, this.answeredAt});

  static const empty = DesireReflection();

  bool? answerTo(ReflectionQuestion question) => answers[question];

  bool get isComplete => answers.length == ReflectionQuestion.values.length;

  /// Um ponto por cada "sim". Não há perguntas com peso diferente de
  /// propósito — assim que uma vale mais do que outra, a pontuação passa a
  /// ser uma opinião nossa sobre o que a pessoa devia querer.
  int get score => answers.values.where((answer) => answer).length;

  int get maxScore => ReflectionQuestion.values.length;

  ReflectionVerdict get verdict {
    if (!isComplete) return ReflectionVerdict.unanswered;
    if (score <= 1) return ReflectionVerdict.impulse;
    if (score <= 3) return ReflectionVerdict.think;
    return ReflectionVerdict.worthwhile;
  }

  DesireReflection copyWith({
    ReflectionQuestion? question,
    bool? answer,
    DateTime? answeredAt,
  }) {
    final updated = Map<ReflectionQuestion, bool>.from(answers);
    if (question != null && answer != null) updated[question] = answer;

    return DesireReflection(
      answers: updated,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  Map<String, dynamic> toJson() => {
    for (final entry in answers.entries) entry.key.name: entry.value,
    if (answeredAt != null) 'answered_at': answeredAt!.toIso8601String(),
  };

  factory DesireReflection.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return empty;

    final answers = <ReflectionQuestion, bool>{};
    for (final question in ReflectionQuestion.values) {
      final value = json[question.name];
      if (value is bool) answers[question] = value;
    }

    return DesireReflection(
      answers: answers,
      answeredAt: DateTime.tryParse(json['answered_at']?.toString() ?? ''),
    );
  }
}

/// O que a app diz sobre a pontuação. Nunca impede a compra — só devolve
/// à pessoa aquilo que ela própria acabou de responder.
// Os nomes são de uma só palavra de propósito: entram directamente nas
// chaves de tradução (`verdict_<nome>_title`), e um nome em camelCase
// obrigaria a converter a caixa em cada chamada.
enum ReflectionVerdict {
  unanswered,
  impulse,
  think,
  worthwhile;

  String get titleKey => 'desire.verdict_${name}_title';
  String get messageKey => 'desire.verdict_${name}_message';
}
