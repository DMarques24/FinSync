import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/repositories/auth_user_repository.dart';

class SignUpUser {
  final AuthUserRepository authRepository;

  SignUpUser(this.authRepository);

  Future<void> call(AuthUserEntity userAuth, User user) async {
    return await authRepository.signUp(userAuth, user);
  }
}
