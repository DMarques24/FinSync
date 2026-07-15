import 'package:finsync/data/models/auth_user_model.dart';

abstract class AuthUserRemoteDatasource {
  Future<void> signUp(AuthUser user);
  Future<void> signIn(AuthUser user);
}
