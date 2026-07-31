/// Uma vez em que se guardou dinheiro para um desejo.
///
/// Vive numa tabela própria e não apenas no total `saved` porque é isso
/// que permite mostrar o histórico e o gráfico — um total não tem forma.
class DesireSaving {
  final int id;
  final int desireId;
  final double amount;
  final DateTime date;

  const DesireSaving({
    required this.id,
    required this.desireId,
    required this.amount,
    required this.date,
  });
}
