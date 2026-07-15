import 'package:finsync/data/models/auth_user_model.dart';
import 'package:finsync/data/models/user_model.dart';

abstract class AuthUserRemoteDatasource {
  Future<void> signUp(AuthUser user, UserModel usermodel);
  Future<void> signIn(AuthUser user);
}
