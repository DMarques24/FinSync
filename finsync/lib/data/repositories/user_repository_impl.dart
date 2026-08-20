import 'dart:io';

import 'package:finsync/data/datasources/user_remote_datasource.dart';
import 'package:finsync/data/models/user_model.dart';
import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl(this.remoteDatasource);
  @override
  Future<List<User>> getUser() async {
    final models = await remoteDatasource.getUser();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> insertUser(User user, String userId) async {
    final model = UserModel(username: user.username, balance: user.balance);
    await remoteDatasource.insertUser(model, userId);
  }

  @override
  Future<void> completeOnboarding(
    String userId, {
    required double balance,
    required double monthlyIncome,
  }) async {
    await remoteDatasource.completeOnboarding(
      userId,
      balance: balance,
      monthlyIncome: monthlyIncome,
    );
  }

  @override
  Future<void> adjustBalance(double delta) async {
    await remoteDatasource.adjustBalance(delta);
  }

  @override
  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    await remoteDatasource.updateProfile(
      username: username,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<String> uploadAvatar(File file) async {
    return await remoteDatasource.uploadAvatar(file);
  }
}
