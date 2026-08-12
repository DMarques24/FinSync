import 'package:finsync/domain/repositories/auth_user_repository.dart';

class ResendConfirmationEmail {
  final AuthUserRepository authRepository;

  ResendConfirmationEmail(this.authRepository);

  Future<void> call(String email) {
    return authRepository.resendConfirmationEmail(email);
  }
}
