import 'package:finsync/data/models/auth_user_model.dart';

/// O que o registo devolve.
///
/// Com a confirmação de email ligada, criar a conta não abre sessão — daí
/// não bastar devolver o id.
class SignUpOutcome {
  final String userId;
  final bool needsEmailConfirmation;

  const SignUpOutcome({
    required this.userId,
    required this.needsEmailConfirmation,
  });
}

abstract class AuthUserRemoteDatasource {
  Future<SignUpOutcome> signUp(AuthUser user, {required String username});
  Future<void> signIn(AuthUser user);
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
