import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/models/auth_user_model.dart';
import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/repositories/auth_user_repository.dart';

class AuthUserRepositoryImpl implements AuthUserRepository {
  final AuthUserRemoteDatasource remoteDatasource;

  AuthUserRepositoryImpl(this.remoteDatasource);

  @override
  Future<SignUpResult> signUp(
    AuthUserEntity user, {
    required String username,
  }) async {
    final outcome = await remoteDatasource.signUp(
      AuthUser(email: user.email, password: user.password),
      username: username,
    );

    return SignUpResult(
      userId: outcome.userId,
      needsEmailConfirmation: outcome.needsEmailConfirmation,
    );
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
  Future<void> deleteAccount() {
    return remoteDatasource.deleteAccount();
  }

  @override
  Future<void> resendConfirmationEmail(String email) {
    return remoteDatasource.resendConfirmationEmail(email);
  }

  @override
  Future<void> sendPasswordResetCode(String email) {
    return remoteDatasource.sendPasswordResetCode(email);
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    return remoteDatasource.verifyPasswordResetCode(email: email, code: code);
  }

  @override
  Future<void> setNewPassword(String newPassword) {
    return remoteDatasource.setNewPassword(newPassword);
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
