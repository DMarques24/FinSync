import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/desire_review.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

/// Guarda a resposta à pergunta periódica "isto ainda faz sentido?".
///
/// Responder — seja o que for — reinicia o contador. Dizer que não quer
/// não apaga o desejo: essa decisão é da pessoa, e fica registada para ela
/// poder ver, daqui a uns meses, quantas vezes hesitou antes de comprar.
class RegisterDesireReview {
  final DesireRepository repository;

  RegisterDesireReview(this.repository);

  Future<void> call({
    required Desire desire,
    required bool stillWanted,
    DateTime? at,
  }) {
    return repository.registerReview(
      desire,
      DesireReview(at: at ?? DateTime.now(), stillWanted: stillWanted),
    );
  }
}
