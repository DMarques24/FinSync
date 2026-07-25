import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Linha selecionável usada dentro do [ThemePickerSheet] para escolher entre
/// claro / escuro / automático.
class ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ThemeOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.secondary : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondary.withValues(alpha: .10)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),

              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
