import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/presentation/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';

/// Esqueleto da Home: reproduz o cartão de saldo e algumas linhas de
/// despesa, para o ecrã não mudar de forma quando os dados chegam.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.bottomNavClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 180, height: 30, radius: AppRadius.xs),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(width: 110, height: 16, radius: AppRadius.xs),

          const SizedBox(height: AppSpacing.xxl),

          // Cartão do saldo.
          SkeletonBox(height: 210, radius: AppRadius.xxl),

          const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),

          // Cartão das últimas despesas.
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 160, height: 22, radius: AppRadius.xs),
                const SizedBox(height: AppSpacing.xl),
                for (var i = 0; i < 4; i++) ...[
                  const _ExpenseRowSkeleton(),
                  if (i < 3) const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRowSkeleton extends StatelessWidget {
  const _ExpenseRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 52, height: 52, radius: AppRadius.md),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 140, height: 16, radius: AppRadius.xs),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(width: 90, height: 20, radius: AppRadius.sm),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(width: 70, height: 12, radius: AppRadius.xs),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const SkeletonBox(width: 64, height: 18, radius: AppRadius.xs),
        ],
      ),
    );
  }
}
