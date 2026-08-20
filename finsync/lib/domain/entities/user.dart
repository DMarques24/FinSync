class User {
  final String username;
  final double balance;
  final bool isFirstLogin;
  final String? avatarUrl;

  /// Quanto a pessoa recebe por mes, em euros.
  ///
  /// Perguntado no tutorial. Zero quer dizer "nao disse" — e nesse caso as
  /// analises voltam a somar as receitas registadas, como faziam antes.
  final double monthlyIncome;

  User({
    required this.username,
    required this.balance,
    this.isFirstLogin = true,
    this.avatarUrl,
    this.monthlyIncome = 0,
  });

  bool get hasDeclaredIncome => monthlyIncome > 0;
}
