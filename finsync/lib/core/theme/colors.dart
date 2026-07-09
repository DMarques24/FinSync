import 'package:flutter/widgets.dart';

class AppColors {
  AppColors._();

  // Cores principais
  static const Color primary = Color(0xFF0F172A); // Azul escuro
  static const Color secondary = Color(0xFF4338CA); // Índigo

  // Fundo
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  // Texto
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Bordas e divisórias
  static const Color border = Color(0xFFE2E8F0);

  // Estados
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = secondary;

  // Desativado
  static const Color disabled = Color(0xFFCBD5E1);
}
