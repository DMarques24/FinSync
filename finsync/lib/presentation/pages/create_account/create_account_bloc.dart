import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/usecases/insert_user.dart';
import 'package:finsync/domain/usecases/sign_up_user.dart';
import 'package:finsync/presentation/pages/create_account/create_account_event.dart';
import 'package:finsync/presentation/pages/create_account/create_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final SignUpUser signUpUser;
  final InsertUser insertUser;

  CreateAccountBloc(this.signUpUser, this.insertUser)
    : super(CreateAccountInitialState()) {
    on<CreateAccountSubmitEvent>(_onCreateAccountSubmit);
  }

  Future<void> _onCreateAccountSubmit(
    CreateAccountSubmitEvent event,
    Emitter<CreateAccountState> emit,
  ) async {
    if (state is CreateAccountLoadingState) return;

    emit(CreateAccountLoadingState());
    try {
      final userId = await signUpUser(
        AuthUserEntity(email: event.email, password: event.password),
      );
      await insertUser(User(username: event.username, balance: 0), userId);
      emit(CreateAccountLoadedState());
    } catch (e) {
      emit(CreateAccountErrorState(AuthErrorTranslator.translate(e)));
    }
  }
}
