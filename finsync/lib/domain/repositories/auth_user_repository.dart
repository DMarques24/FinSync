import 'package:finsync/domain/entities/auth_user.dart';

abstract class AuthUserRepository {
  Future<String> signUp(AuthUserEntity user);
  Future<void> signIn(AuthUserEntity user);
  Future<void> signOut();
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
