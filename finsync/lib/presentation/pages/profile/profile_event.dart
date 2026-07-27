import 'dart:async';
import 'dart:io';

abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String username;
  final File? avatarFile;
  final Completer<void>? completer;

  UpdateProfileEvent(this.username, {this.avatarFile, this.completer});
}
