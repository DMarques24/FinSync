import 'package:finsync/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUser();
}
