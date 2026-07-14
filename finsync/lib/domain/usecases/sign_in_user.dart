import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/repositories/auth_user_repository.dart';

class SignInUser {
  final AuthUserRepository authRepository;

  SignInUser(this.authRepository);

  Future<void> call(AuthUserEntity user) async {
    return await authRepository.signIn(user);
  }
}
