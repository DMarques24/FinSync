import 'package:finsync/data/models/auth_user_model.dart';

abstract class AuthUserRemoteDatasource {
  Future<String> signUp(AuthUser user);
  Future<void> signIn(AuthUser user);
}
