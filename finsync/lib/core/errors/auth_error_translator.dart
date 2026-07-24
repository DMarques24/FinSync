import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduz erros de autenticação do Supabase (e outros erros comuns) para
/// mensagens em português, percebíveis por quem está a usar a app.
///
/// Sem isto, o utilizador via coisas como:
/// "AuthApiException(message: Password should be at least 6 characters,
/// statusCode: 422, code: weak_password)" — o que não ajuda ninguém.
class AuthErrorTranslator {
  AuthErrorTranslator._();

  static String translate(Object error) {
    if (error is AuthException) {
      return _fromAuthException(error);
    }

    final message = error.toString().toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network')) {
      return 'Sem ligação à internet. Verifica a tua rede e tenta novamente.';
    }

    if (message.contains('timeout')) {
      return 'O pedido demorou demasiado tempo. Tenta novamente.';
    }

    return 'Ocorreu um erro inesperado. Tenta novamente.';
  }

  static String _fromAuthException(AuthException error) {
    switch (error.code) {
      case 'weak_password':
        return 'A password tem de ter pelo menos 6 caracteres.';

      case 'user_already_exists':
      case 'email_exists':
        return 'Já existe uma conta com este email.';

      case 'invalid_credentials':
        return 'Email ou password incorretos.';

      case 'email_not_confirmed':
        return 'Confirma o teu email antes de iniciares sessão.';

      case 'invalid_email':
        return 'O email introduzido não é válido.';

      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Demasiadas tentativas. Aguarda um pouco antes de tentar novamente.';

      case 'signup_disabled':
        return 'O registo de novas contas está temporariamente desativado.';

      case 'same_password':
        return 'A nova password tem de ser diferente da atual.';

      case 'user_not_found':
        return 'Não existe nenhuma conta com este email.';
    }

    // Fallback: sem código conhecido, tentamos apanhar pela mensagem.
    final message = error.message.toLowerCase();

    if (message.contains('password') && message.contains('6 characters')) {
      return 'A password tem de ter pelo menos 6 caracteres.';
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Já existe uma conta com este email.';
    }
    if (message.contains('invalid login credentials')) {
      return 'Email ou password incorretos.';
    }
    if (message.contains('rate limit')) {
      return 'Demasiadas tentativas. Aguarda um pouco antes de tentar novamente.';
    }

    return 'Não foi possível concluir o pedido. Tenta novamente.';
  }
}
