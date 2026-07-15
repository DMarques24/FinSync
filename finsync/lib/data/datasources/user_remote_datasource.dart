import 'package:finsync/data/models/user_model.dart';

abstract class UserRemoteDatasource {
  Future<List<UserModel>> getUser();
}
