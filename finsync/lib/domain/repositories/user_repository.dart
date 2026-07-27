import 'dart:io';

import 'package:finsync/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUser();
  Future<void> insertUser(User user, String userId);
  Future<void> completeOnboarding(String userId, double balance);
  Future<void> adjustBalance(double delta);
  Future<void> updateProfile({required String username, String? avatarUrl});
  Future<String> uploadAvatar(File file);
}
