import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/models/auth_user_model.dart';
import 'package:finsync/domain/entities/auth_user.dart';
import 'package:finsync/domain/repositories/auth_user_repository.dart';

class AuthUserRepositoryImpl implements AuthUserRepository {
  final AuthUserRemoteDatasource remoteDatasource;

  AuthUserRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> signUp(AuthUserEntity user) async {
    final model = AuthUser(email: user.email, password: user.password);
    await remoteDatasource.signUp(model);
  }

  @override
  Future<void> signIn(AuthUserEntity user) async {
    final model = AuthUser(email: user.email, password: user.password);
    await remoteDatasource.signIn(model);
  }
}
