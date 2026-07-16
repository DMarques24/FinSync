import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/models/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthUserRemoteDatasourceImpl implements AuthUserRemoteDatasource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<String> signUp(AuthUser user) async {
    final response = await supabase.auth.signUp(
      email: user.email,
      password: user.password,
    );
    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Não foi possível obter o utilizador após o registo.');
    }
    return userId;
  }

  @override
  Future<void> signIn(AuthUser user) async {
    await supabase.auth.signInWithPassword(
      email: user.email,
      password: user.password,
    );
  }
}
