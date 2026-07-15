import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/models/auth_user_model.dart';
import 'package:finsync/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthUserRemoteDatasourceImpl implements AuthUserRemoteDatasource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<void> signUp(AuthUser user, UserModel usermodel) async {
    try {
      final response = await supabase.auth.signUp(
        email: user.email,
        password: user.password,
      );

      final authUser = response.user;

      if (authUser == null) {
        throw Exception('Erro ao criar utilizador');
      }

      await supabase.from('profiles').insert(usermodel.toJson(authUser.id));
    } on AuthApiException catch (e) {
      if (e.statusCode == '429') {
        throw Exception(
          'Demasiados pedidos de registo. Por favor aguarda alguns minutos e tenta novamente.',
        );
      }
      throw Exception(e.message);
    }
  }

  @override
  Future<void> signIn(AuthUser user) async {
    try {
      await supabase.auth.signInWithPassword(
        email: user.email,
        password: user.password,
      );
    } on AuthApiException catch (e) {
      if (e.statusCode == '429') {
        throw Exception(
          'Demasiados pedidos de login. Por favor aguarda alguns minutos e tenta novamente.',
        );
      }
      throw Exception(e.message);
    }
  }
}
