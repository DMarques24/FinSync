class Desire {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final String? image;
  final double saved;

  Desire({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.image,
    this.saved = 0,
  });
}
