import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/models/auth_user_model.dart';
import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/repositories/auth_user_repository.dart';

class AuthUserRepositoryImpl implements AuthUserRepository {
  final AuthUserRemoteDatasource remoteDatasource;

  AuthUserRepositoryImpl(this.remoteDatasource);

  @override
  Future<String> signUp(AuthUserEntity user) async {
    final model = AuthUser(email: user.email, password: user.password);
    return await remoteDatasource.signUp(model);
  }

  @override
  Future<void> signIn(AuthUserEntity user) async {
    final model = AuthUser(email: user.email, password: user.password);
    await remoteDatasource.signIn(model);
  }

  @override
  Future<void> signOut() async {
    await remoteDatasource.signOut();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await remoteDatasource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
