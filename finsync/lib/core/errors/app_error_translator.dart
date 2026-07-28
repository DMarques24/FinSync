import 'dart:async';
import 'dart:io';

import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorTranslator {
  AppErrorTranslator._();

  static String translate(Object error) {
    if (error is AuthException) return AuthErrorTranslator.translate(error);

    if (error is PostgrestException) return _fromPostgrest(error);

    if (error is StorageException) {
      return 'Não foi possível carregar o ficheiro. Tenta novamente.';
    }

    if (error is SocketException) {
      return 'Sem ligação à internet. Verifica a tua rede e tenta novamente.';
    }

    if (error is TimeoutException) {
      return 'O pedido demorou demasiado tempo. Tenta novamente.';
    }

    if (error is Exception) {
      final raw = error.toString().replaceFirst('Exception: ', '');
      if (_isOwnMessage(raw)) return raw;
    }

    final message = error.toString().toLowerCase();

    if (message.contains('failed host lookup') ||
        message.contains('socketexception') ||
        message.contains('network')) {
      return 'Sem ligação à internet. Verifica a tua rede e tenta novamente.';
    }
    if (message.contains('timeout')) {
      return 'O pedido demorou demasiado tempo. Tenta novamente.';
    }

    return 'Ocorreu um erro inesperado. Tenta novamente.';
  }

  static String _fromPostgrest(PostgrestException error) {
    switch (error.code) {
      case '23505': 
        return 'Esse registo já existe.';
      case '23503': 
        return 'Não é possível concluir: este item está ligado a outro.';
      case '42501': 
        return 'Não tens permissão para fazer isto.';
      case 'PGRST301':
        return 'A tua sessão expirou. Inicia sessão novamente.';
    }

    return 'Não foi possível guardar os dados. Tenta novamente.';
  }


  static bool _isOwnMessage(String raw) {
    if (raw.isEmpty || raw.length > 200) return false;
    if (raw.contains('Exception') || raw.contains('Error')) return false;
    if (RegExp(r'\b(code|statusCode|message):').hasMatch(raw)) return false;
    return true;
  }
}
