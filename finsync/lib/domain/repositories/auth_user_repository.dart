import 'package:finsync/domain/entities/auth_user.dart';

abstract class AuthUserRepository {
  Future<void> signUp(AuthUserEntity user);
  Future<void> signIn(AuthUserEntity user);
}
