import 'package:finsync/domain/entities/user.dart';

abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final User user;
  final String email;

  ProfileLoadedState({required this.user, required this.email});
}

class ProfileErrorState extends ProfileState {
  final String message;

  ProfileErrorState(this.message);
}
