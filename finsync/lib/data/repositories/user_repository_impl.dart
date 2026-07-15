import 'package:finsync/data/datasources/user_remote_datasource.dart';
import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl(this.remoteDatasource);
  @override
  Future<List<User>> getUser() async {
    final models = await remoteDatasource.getUser();
    return models.map((model) => model.toEntity()).toList();
  }
}
