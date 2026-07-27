import 'package:finsync/domain/repositories/user_repository.dart';

class UpdateUserProfile {
  final UserRepository userRepository;

  UpdateUserProfile(this.userRepository);

  Future<void> call({required String username, String? avatarUrl}) async {
    await userRepository.updateProfile(
      username: username,
      avatarUrl: avatarUrl,
    );
  }
}
