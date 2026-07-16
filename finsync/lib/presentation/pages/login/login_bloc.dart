import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/usecases/sign_in_user.dart';
import 'package:finsync/presentation/pages/login/login_event.dart';
import 'package:finsync/presentation/pages/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUser signInUser;

  LoginBloc(this.signInUser) : super(LoginInitialState()) {
    on<LoginSubmitEvent>(_onLoginSubmit);
  }

  Future<void> _onLoginSubmit(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoadingState());
    try {
      await signInUser(
        AuthUserEntity(email: event.email, password: event.password),
      );
      emit(LoginLoadedState());
    } catch (e) {
      emit(LoginErrorState(e.toString()));
    }
  }
}
