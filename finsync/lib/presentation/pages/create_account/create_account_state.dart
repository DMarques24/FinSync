abstract class CreateAccountState {}

class CreateAccountInitialState extends CreateAccountState {}

class CreateAccountLoadingState extends CreateAccountState {}

/// Conta criada e sessão aberta — a confirmação de email está desligada no
/// projeto. Segue direto para o login.
class CreateAccountLoadedState extends CreateAccountState {}

/// Conta criada mas ainda sem sessão: falta abrir o email e confirmar.
class CreateAccountAwaitingConfirmationState extends CreateAccountState {
  final String email;

  CreateAccountAwaitingConfirmationState(this.email);
}

class CreateAccountErrorState extends CreateAccountState {
  final String message;

  CreateAccountErrorState(this.message);
}
