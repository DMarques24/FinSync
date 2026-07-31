/// De quanto em quanto tempo a app volta a perguntar se a compra ainda faz
/// sentido.
///
/// Os valores são poucos de propósito: dar um campo livre em dias obrigava
/// a pessoa a decidir um número que não sabe justificar.
enum ReviewInterval {
  biweekly(15),
  monthly(30),
  quarterly(90);

  final int days;

  const ReviewInterval(this.days);

  String get labelKey => 'desire.interval_$name';

  static ReviewInterval fromDays(int? days) {
    if (days == null) return ReviewInterval.monthly;

    for (final interval in ReviewInterval.values) {
      if (interval.days == days) return interval;
    }
    return ReviewInterval.monthly;
  }
}

/// Uma resposta à pergunta periódica "isto ainda faz sentido?".
class DesireReview {
  final DateTime at;
  final bool stillWanted;

  const DesireReview({required this.at, required this.stillWanted});

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'keep': stillWanted,
  };

  factory DesireReview.fromJson(Map<String, dynamic> json) {
    return DesireReview(
      at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
      stillWanted: json['keep'] as bool? ?? true,
    );
  }
}
