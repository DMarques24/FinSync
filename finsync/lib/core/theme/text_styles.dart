import 'package:flutter/material.dart';
import 'colors.dart';


class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headingLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingMedium => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingSmall => TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall =>
      TextStyle(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get labelSmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: .2,
  );
}
