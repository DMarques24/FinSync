import 'package:finsync/domain/entities/user.dart';

class UserModel {
  final String username;
  final double balance;

  UserModel({required this.username, required this.balance});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {'username': username, 'balance': balance, 'user_id': userId};
  }

  User toEntity() {
    return User(username: username, balance: balance);
  }
}
