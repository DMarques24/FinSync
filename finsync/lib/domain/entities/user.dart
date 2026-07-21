class User {
  final String username;
  final double balance;
  final bool isFirstLogin;

  User({
    required this.username,
    required this.balance,
    this.isFirstLogin = true,
  });
}
