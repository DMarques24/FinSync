import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finsync/domain/usecases/get_user.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:finsync/presentation/pages/profile/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUser getUser;

  ProfileBloc(this.getUser) : super(ProfileInitialState()) {
    on<LoadProfileEvent>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final users = await getUser();
      final email =
          Supabase.instance.client.auth.currentUser?.email ?? '';
      if (users.isNotEmpty) {
        emit(ProfileLoadedState(user: users.first, email: email));
      } else {
        emit(ProfileErrorState('Perfil não encontrado.'));
      }
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }
}
