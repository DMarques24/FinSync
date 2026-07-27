import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = false;

  static const Color lightPrimary = Color(0xFF0F172A);
  static const Color lightSecondary = Color(0xFF4338CA);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightSuccess = Color(0xFF22C55E);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightWarning = Color(0xFFF59E0B);

  // Cores principais
  static Color get primary => isDark ? const Color(0xFF4338CA) : lightPrimary;
  static Color get secondary => lightSecondary; 

  // Fundo
  static Color get background =>
      isDark ? const Color(0xFF0F1115) : lightBackground;
  static Color get surface => isDark ? const Color(0xFF1A1C22) : lightSurface;

  // Texto
  static Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : lightPrimary;
  static Color get textSecondary =>
      isDark ? const Color(0xB3FFFFFF) : lightTextSecondary;
  static Color get textOnPrimary => const Color(0xFFFFFFFF);

  // Bordas e divisórias
  static Color get border => isDark ? const Color(0xFF32353D) : lightBorder;

  // Estados
  static Color get success => isDark ? const Color(0xFF4ADE80) : lightSuccess;
  static Color get error => isDark ? const Color(0xFFE57373) : lightError;
  static Color get warning =>
      isDark ? const Color(0xFFFBBF24) : lightWarning;
  static Color get info => secondary;

  // Desativado
  static Color get disabled =>
      isDark ? const Color(0xFF4B4F58) : const Color(0xFFCBD5E1);

  // Camadas / elevação suave (usado em cards e headers em destaque)
  static Color get surfaceElevated =>
      isDark ? const Color(0xFF20232B) : lightSurface;

  static const List<Color> lightChartPalette = [
    lightSecondary, // indigo
    lightSuccess, // verde
    lightWarning, // laranja
    lightError, // vermelho
    Color(0xFF0EA5E9), // azul
    Color(0xFFA855F7), // roxo
    Color(0xFFEC4899), // rosa
    Color(0xFF14B8A6), // verde-azulado
  ];

  static const List<Color> darkChartPalette = [
    Color(0xFF4338CA), // indigo (secondary)
    Color(0xFF4ADE80), // verde (success)
    Color(0xFFFBBF24), // laranja (warning)
    Color(0xFFE57373), // vermelho (error)
    Color(0xFF38BDF8), // azul
    Color(0xFFC084FC), // roxo
    Color(0xFFF472B6), // rosa
    Color(0xFF2DD4BF), // verde-azulado
  ];

  static List<Color> get chartPalette =>
      isDark ? darkChartPalette : lightChartPalette;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: .32)
          : const Color(0xFF0F172A).withValues(alpha: .06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: .24)
          : const Color(0xFF0F172A).withValues(alpha: .04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
