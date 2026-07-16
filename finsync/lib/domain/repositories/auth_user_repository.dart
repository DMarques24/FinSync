import 'package:finsync/domain/entities/auth_user.dart';

abstract class AuthUserRepository {
  Future<String> signUp(AuthUserEntity user);
  Future<void> signIn(AuthUserEntity user);
}
