import 'dart:io';

import 'package:finsync/domain/repositories/user_repository.dart';

class UploadAvatarImage {
  final UserRepository userRepository;

  UploadAvatarImage(this.userRepository);

  Future<String> call(File file) async {
    return await userRepository.uploadAvatar(file);
  }
}
