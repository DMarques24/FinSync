import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/onboarding/components/feature_row.dart';
import 'package:flutter/material.dart';

class FeaturesStep extends StatelessWidget {
  const FeaturesStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Como funciona 🚀", style: AppTextStyles.headingLarge),

          const SizedBox(height: 8),

          Text(
            "Tudo o que precisas está a um toque de distância.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          FeatureRow(
            icon: Icons.home_rounded,
            title: "Home",
            description: "Regista e acompanha as tuas despesas do dia a dia.",
          ),

          const SizedBox(height: 24),

          FeatureRow(
            icon: Icons.favorite_rounded,
            title: "Goals",
            description: "Define objetivos de poupança e vê o progresso.",
          ),

          const SizedBox(height: 24),

          FeatureRow(
            icon: Icons.person_rounded,
            title: "Profile",
            description: "Consulta o teu saldo e gere os dados da tua conta.",
          ),
        ],
      ),
    );
  }
}
