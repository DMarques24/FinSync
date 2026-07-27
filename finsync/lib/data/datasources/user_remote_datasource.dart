import 'dart:io';

import 'package:finsync/data/models/user_model.dart';

abstract class UserRemoteDatasource {
  Future<List<UserModel>> getUser();

  Future<void> insertUser(UserModel user, String userId);

  Future<void> completeOnboarding(String userId, double balance);

  Future<void> adjustBalance(double delta);

  Future<void> updateProfile({required String username, String? avatarUrl});

  Future<String> uploadAvatar(File file);
}
