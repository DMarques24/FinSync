abstract class CreateAccountState {}

class CreateAccountInitialState extends CreateAccountState {}

class CreateAccountLoadingState extends CreateAccountState {}

class CreateAccountLoadedState extends CreateAccountState {}

class CreateAccountErrorState extends CreateAccountState {
  final String message;

  CreateAccountErrorState(this.message);
}
