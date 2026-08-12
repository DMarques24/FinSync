import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/usecases/sign_up_user.dart';
import 'package:finsync/presentation/pages/create_account/create_account_event.dart';
import 'package:finsync/presentation/pages/create_account/create_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final SignUpUser signUpUser;

  CreateAccountBloc(this.signUpUser) : super(CreateAccountInitialState()) {
    on<CreateAccountSubmitEvent>(_onCreateAccountSubmit);
  }

  Future<void> _onCreateAccountSubmit(
    CreateAccountSubmitEvent event,
    Emitter<CreateAccountState> emit,
  ) async {
    if (state is CreateAccountLoadingState) return;

    emit(CreateAccountLoadingState());
    try {
      // Já não há inserção em `profiles` a seguir ao registo. Com a
      // confirmação de email ligada não existe sessão nesta altura, e sem
      // sessão as políticas de acesso recusavam a escrita — era esse o
      // erro 400 de há umas semanas. O perfil passou a ser criado por um
      // gatilho na base de dados, a partir do nome que vai nos metadados.
      final result = await signUpUser(
        AuthUserEntity(email: event.email, password: event.password),
        username: event.username,
      );

      emit(
        result.needsEmailConfirmation
            ? CreateAccountAwaitingConfirmationState(event.email)
            : CreateAccountLoadedState(),
      );
    } catch (e) {
      emit(CreateAccountErrorState(AppErrorTranslator.translate(e)));
    }
  }
}
