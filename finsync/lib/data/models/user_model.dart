class UserModel {
  final String userName;
  final double balance;

  UserModel({required this.userName, required this.balance});

  Map<String, dynamic> toJson(String userId) {
    return {'username': userName, 'user_id': userId, 'balance': 0};
  }
}
