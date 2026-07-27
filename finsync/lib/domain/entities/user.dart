class User {
  final String username;
  final double balance;
  final bool isFirstLogin;
  final String? avatarUrl;

  User({
    required this.username,
    required this.balance,
    this.isFirstLogin = true,
    this.avatarUrl,
  });
}
