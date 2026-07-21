abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginLoadedState extends LoginState {
  final bool isFirstLogin;

  LoginLoadedState({this.isFirstLogin = false});
}

class LoginErrorState extends LoginState {
  final String message;

  LoginErrorState(this.message);
}
