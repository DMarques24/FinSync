import 'package:finsync/domain/repositories/auth_user_repository.dart';

/// Apaga a conta e todos os dados que lhe pertencem.
///
/// Existe porque a Apple obriga: uma app que deixa criar conta tem de
/// deixar apagá-la de dentro da própria app, sem obrigar a escrever para
/// o suporte. Sem isto, a submissão é recusada.
class DeleteAccount {
  final AuthUserRepository authRepository;

  DeleteAccount(this.authRepository);

  Future<void> call() {
    return authRepository.deleteAccount();
  }
}
