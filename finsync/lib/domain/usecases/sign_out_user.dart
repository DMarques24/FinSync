import 'package:finsync/domain/repositories/auth_user_repository.dart';

class SignOutUser {
  final AuthUserRepository authRepository;

  SignOutUser(this.authRepository);

  Future<void> call() async {
    return await authRepository.signOut();
  }
}
