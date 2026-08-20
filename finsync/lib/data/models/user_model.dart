import 'package:finsync/domain/entities/user.dart';

class UserModel {
  final String username;
  final double balance;
  final bool isFirstLogin;
  final String? avatarUrl;
  final double monthlyIncome;

  UserModel({
    required this.username,
    required this.balance,
    this.isFirstLogin = true,
    this.avatarUrl,
    this.monthlyIncome = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'username': username,
      'balance': balance,
      'user_id': userId,
      'avatar_url': avatarUrl,
      'monthly_income': monthlyIncome,
    };
  }

  User toEntity() {
    return User(
      username: username,
      balance: balance,
      isFirstLogin: isFirstLogin,
      avatarUrl: avatarUrl,
      monthlyIncome: monthlyIncome,
    );
  }
}
