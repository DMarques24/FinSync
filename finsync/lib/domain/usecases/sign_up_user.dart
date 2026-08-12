import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/repositories/auth_user_repository.dart';

class SignUpUser {
  final AuthUserRepository authRepository;

  SignUpUser(this.authRepository);

  Future<SignUpResult> call(
    AuthUserEntity user, {
    required String username,
  }) {
    return authRepository.signUp(user, username: username);
  }
}
