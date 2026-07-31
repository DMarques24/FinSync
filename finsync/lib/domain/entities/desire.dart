import 'package:finsync/domain/entities/desire_reflection.dart';
import 'package:finsync/domain/entities/desire_review.dart';

class Desire {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final String? image;
  final double saved;

  /// O que a pessoa respondeu antes de criar este desejo.
  final DesireReflection reflection;

  final ReviewInterval reviewInterval;

  /// Quando foi a última vez que confirmou que ainda o quer. `null` quer
  /// dizer que ainda não houve nenhuma reavaliação — nesse caso conta a
  /// data da reflexão inicial.
  final DateTime? lastReviewedAt;

  final List<DesireReview> reviews;

  Desire({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.image,
    this.saved = 0,
    this.reflection = DesireReflection.empty,
    this.reviewInterval = ReviewInterval.monthly,
    this.lastReviewedAt,
    this.reviews = const [],
  });

  // ── Progresso ──────────────────────────────────────────────────────

  double get remaining => (price - saved).clamp(0, double.infinity);

  double get progress => price <= 0 ? 0 : (saved / price).clamp(0.0, 1.0);

  bool get isComplete => price > 0 && saved >= price;

  // ── Ritmo ──────────────────────────────────────────────────────────

  /// Meses até à data-objetivo, nunca menos de um. Dizer "faltam 0 meses"
  /// e dividir por zero não ajuda; se a data já passou, o que falta é para
  /// já — e é isso que um mês representa.
  int monthsUntilGoal({DateTime? from}) {
    final now = from ?? DateTime.now();
    final months = (date.year - now.year) * 12 + (date.month - now.month);

    return months < 1 ? 1 : months;
  }

  /// Quanto é preciso pôr de lado por mês para lá chegar a tempo.
  double monthlyTarget({DateTime? from}) {
    if (isComplete) return 0;
    return remaining / monthsUntilGoal(from: from);
  }

  /// Ritmo a que se tem poupado, medido pelas poupanças já feitas.
  ///
  /// Conta a partir da primeira poupança e não da criação do desejo: quem
  /// criou o objetivo há seis meses e começou a poupar ontem não está a
  /// poupar a um sexto do que pôs de lado.
  double monthlyPace(List<DesireSavingPoint> savings, {DateTime? until}) {
    if (savings.isEmpty) return 0;

    final now = until ?? DateTime.now();
    final first = savings
        .map((saving) => saving.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final elapsed = (now.year - first.year) * 12 + (now.month - first.month);
    final months = elapsed < 1 ? 1 : elapsed;

    final total = savings.fold<double>(
      0,
      (sum, saving) => sum + saving.amount,
    );

    return total / months;
  }

  /// O ritmo atual chega à data-objetivo?
  bool isOnTrack(List<DesireSavingPoint> savings, {DateTime? from}) {
    if (isComplete) return true;

    final pace = monthlyPace(savings, until: from);
    if (pace <= 0) return false;

    return pace >= monthlyTarget(from: from);
  }

  // ── Reavaliação ────────────────────────────────────────────────────

  DateTime? get nextReviewDate {
    final reference = lastReviewedAt ?? reflection.answeredAt;
    if (reference == null) return null;

    return reference.add(Duration(days: reviewInterval.days));
  }

  bool needsReview({DateTime? now}) {
    if (isComplete) return false;

    final next = nextReviewDate;
    if (next == null) return false;

    return !next.isAfter(now ?? DateTime.now());
  }

  Desire copyWith({
    double? saved,
    DateTime? lastReviewedAt,
    List<DesireReview>? reviews,
  }) {
    return Desire(
      id: id,
      name: name,
      price: price,
      date: date,
      image: image,
      saved: saved ?? this.saved,
      reflection: reflection,
      reviewInterval: reviewInterval,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviews: reviews ?? this.reviews,
    );
  }
}

/// O mínimo que o cálculo de ritmo precisa de saber sobre uma poupança.
/// Evita que `Desire` dependa de `DesireSaving`, que vive noutra tabela e
/// nem sempre está carregado.
class DesireSavingPoint {
  final DateTime date;
  final double amount;

  const DesireSavingPoint({required this.date, required this.amount});
}
