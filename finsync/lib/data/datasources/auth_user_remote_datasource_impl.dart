import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/models/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthUserRemoteDatasourceImpl implements AuthUserRemoteDatasource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<SignUpOutcome> signUp(
    AuthUser user, {
    required String username,
  }) async {
    final response = await supabase.auth.signUp(
      email: user.email,
      password: user.password,
      // O nome vai nos metadados e não numa inserção nossa em `profiles`.
      // Com a confirmação de email ligada, o registo não devolve sessão —
      // e sem sessão a inserção seria recusada pelas políticas de acesso.
      // Quem cria o perfil é o gatilho na base de dados, que corre do lado
      // do servidor e tem sempre os dados à mão.
      data: {'username': username},
    );

    final created = response.user;
    if (created == null) {
      throw Exception('Não foi possível criar a conta. Tenta novamente.');
    }

    return SignUpOutcome(
      userId: created.id,
      // Sem sessão = à espera de confirmação. É assim que se distingue um
      // projeto com confirmação ligada de um sem ela, sem ter de perguntar
      // à configuração.
      needsEmailConfirmation: response.session == null,
    );
  }

  @override
  Future<void> signIn(AuthUser user) async {
    await supabase.auth.signInWithPassword(
      email: user.email,
      password: user.password,
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    await supabase.auth.resend(type: OtpType.signup, email: email);
  }

  @override
  Future<void> sendPasswordResetCode(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    // Abre uma sessão temporária de recuperação. É essa sessão que autoriza
    // o `setNewPassword` a seguir — sem ela, definir a password nova seria
    // uma operação sem dono.
    await supabase.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: code,
    );
  }

  @override
  Future<void> setNewPassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = supabase.auth.currentUser?.email;
    if (email == null) {
      throw Exception('Sessão inválida. Faz login novamente.');
    }

    await supabase.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );

    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
