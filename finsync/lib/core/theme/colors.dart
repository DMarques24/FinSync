import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = false;

  // Cores principais
  static Color get primary =>
      isDark ? const Color(0xFF4F8CFF) : const Color(0xFF0F172A);
  static Color get secondary =>
      isDark ? const Color(0xFF4F8CFF) : const Color(0xFF4338CA);

  // Fundo
  static Color get background =>
      isDark ? const Color(0xFF0F1115) : const Color(0xFFF8FAFC);
  static Color get surface =>
      isDark ? const Color(0xFF1A1C22) : const Color(0xFFFFFFFF);

  // Texto
  static Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      isDark ? const Color(0xB3FFFFFF) : const Color(0xFF64748B);
  static Color get textOnPrimary => const Color(0xFFFFFFFF);

  // Bordas e divisórias
  static Color get border =>
      isDark ? const Color(0xFF32353D) : const Color(0xFFE2E8F0);

  // Estados
  static Color get success =>
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
  static Color get error =>
      isDark ? const Color(0xFFE57373) : const Color(0xFFEF4444);
  static Color get warning =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
  static Color get info => secondary;

  // Desativado
  static Color get disabled =>
      isDark ? const Color(0xFF4B4F58) : const Color(0xFFCBD5E1);
}
