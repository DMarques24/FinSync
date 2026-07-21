import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/usecases/get_user.dart';
import 'package:finsync/domain/usecases/sign_in_user.dart';
import 'package:finsync/presentation/pages/login/login_event.dart';
import 'package:finsync/presentation/pages/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUser signInUser;
  final GetUser getUser;

  LoginBloc(this.signInUser, this.getUser) : super(LoginInitialState()) {
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
      final users = await getUser();
      final isFirstLogin = users.isNotEmpty ? users.first.isFirstLogin : false;
      emit(LoginLoadedState(isFirstLogin: isFirstLogin));
    } catch (e) {
      emit(LoginErrorState(e.toString()));
    }
  }
}
