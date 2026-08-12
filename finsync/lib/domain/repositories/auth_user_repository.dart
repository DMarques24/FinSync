import 'package:finsync/domain/entities/auth_user.dart';

/// Resultado do registo. `needsEmailConfirmation` a `true` quer dizer que
/// a conta existe mas ainda não há sessão — falta confirmar o email.
class SignUpResult {
  final String userId;
  final bool needsEmailConfirmation;

  const SignUpResult({
    required this.userId,
    required this.needsEmailConfirmation,
  });
}

abstract class AuthUserRepository {
  Future<SignUpResult> signUp(AuthUserEntity user, {required String username});
  Future<void> signIn(AuthUserEntity user);
  Future<void> signOut();

  Future<void> resendConfirmationEmail(String email);

  Future<void> sendPasswordResetCode(String email);
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });
  Future<void> setNewPassword(String newPassword);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
