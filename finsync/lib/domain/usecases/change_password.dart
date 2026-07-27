import 'package:finsync/domain/repositories/auth_user_repository.dart';

class ChangePassword {
  final AuthUserRepository authRepository;

  ChangePassword(this.authRepository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    await authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
