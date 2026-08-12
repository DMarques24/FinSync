import 'package:finsync/domain/repositories/auth_user_repository.dart';

/// Recuperação de password por código enviado para o email.
///
/// Três passos, cada um com o seu método: pedir o código, validá-lo (o que
/// abre uma sessão temporária) e definir a password nova. Escolhemos código
/// em vez de link porque um link tem de abrir a app — e isso obriga a
/// configuração nativa em iOS e Android que dá muito mais problemas do que
/// escrever seis dígitos.
class RecoverPassword {
  final AuthUserRepository authRepository;

  RecoverPassword(this.authRepository);

  Future<void> sendCode(String email) {
    return authRepository.sendPasswordResetCode(email);
  }

  Future<void> verifyCode({required String email, required String code}) {
    return authRepository.verifyPasswordResetCode(email: email, code: code);
  }

  Future<void> setNewPassword(String newPassword) {
    return authRepository.setNewPassword(newPassword);
  }
}
