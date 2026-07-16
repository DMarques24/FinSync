import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/usecases/insert_user.dart';
import 'package:finsync/domain/usecases/sign_up_user.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_event.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAcountBloc extends Bloc<CreateAcountEvent, CreateAcountState> {
  final SignUpUser signUpUser;
  final InsertUser insertUser;

  CreateAcountBloc(this.signUpUser, this.insertUser)
    : super(CreateAcountInitialState()) {
    on<CreateAcountSubmitEvent>(_onCreateAcountSubmit);
  }

  Future<void> _onCreateAcountSubmit(
    CreateAcountSubmitEvent event,
    Emitter<CreateAcountState> emit,
  ) async {
    if (state is CreateAcountLoadingState) return;

    emit(CreateAcountLoadingState());
    try {
      final userId = await signUpUser(
        AuthUserEntity(email: event.email, password: event.password),
      );
      await insertUser(User(username: event.username, balance: 0), userId);
      emit(CreateAcountLoadedState());
    } catch (e) {
      emit(CreateAcountErrorState(e.toString()));
    }
  }
}
