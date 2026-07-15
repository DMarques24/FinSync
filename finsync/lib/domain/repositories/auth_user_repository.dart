import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/entities/user.dart';

abstract class AuthUserRepository {
  Future<void> signUp(AuthUserEntity userAuth, User user);
  Future<void> signIn(AuthUserEntity user);
}
