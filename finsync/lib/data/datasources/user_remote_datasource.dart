import 'package:finsync/data/models/user_model.dart';

abstract class UserRemoteDatasource {
  Future<List<UserModel>> getUser();

  Future<void> insertUser(UserModel user, String userId);
}
