import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finsync/domain/usecases/get_user.dart';
import 'package:finsync/domain/usecases/update_user_profile.dart';
import 'package:finsync/domain/usecases/upload_avatar_image.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:finsync/presentation/pages/profile/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUser getUser;
  final UpdateUserProfile updateUserProfile;
  final UploadAvatarImage uploadAvatarImage;

  ProfileBloc(this.getUser, this.updateUserProfile, this.uploadAvatarImage)
    : super(ProfileInitialState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final users = await getUser();
      final email = Supabase.instance.client.auth.currentUser?.email ?? '';
      if (users.isNotEmpty) {
        emit(ProfileLoadedState(user: users.first, email: email));
      } else {
        emit(ProfileErrorState('Perfil não encontrado.'));
      }
    } catch (e) {
      emit(ProfileErrorState(AppErrorTranslator.translate(e)));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      String? avatarUrl;
      if (event.avatarFile != null) {
        avatarUrl = await uploadAvatarImage(event.avatarFile!);
      }

      await updateUserProfile(username: event.username, avatarUrl: avatarUrl);

      final users = await getUser();
      final email = Supabase.instance.client.auth.currentUser?.email ?? '';
      if (users.isNotEmpty) {
        emit(ProfileLoadedState(user: users.first, email: email));
      }

      event.completer?.complete();
    } catch (e) {
      event.completer?.completeError(e);
    }
  }
}
