import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/usecases/sign_up_user.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_event.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAcountBloc extends Bloc<CreateAcountEvent, CreateAcountState> {
  final SignUpUser signUpUser;

  CreateAcountBloc(this.signUpUser) : super(CreateAcountInitialState()) {
    on<CreateAcountSubmitEvent>(_onCreateAcountSubmit);
  }

  Future<void> _onCreateAcountSubmit(
    CreateAcountSubmitEvent event,
    Emitter<CreateAcountState> emit,
  ) async {
    emit(CreateAcountLoadingState());
    try {
      await signUpUser(
        AuthUserEntity(email: event.email, password: event.password),
        User(userName: event.userName, balance: 0),
      );
      emit(CreateAcountLoadedState());
    } catch (e) {
      emit(CreateAcountErrorState(e.toString()));
    }
  }
}
