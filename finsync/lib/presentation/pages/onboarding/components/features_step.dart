import 'package:finsync/presentation/pages/onboarding/components/feature_row.dart';
import 'package:flutter/material.dart';

class FeaturesStep extends StatelessWidget {
  const FeaturesStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Como funciona 🚀",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Tudo o que precisas está a um toque de distância.",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 32),

          const FeatureRow(
            icon: Icons.home_rounded,
            title: "Home",
            description: "Regista e acompanha as tuas despesas do dia a dia.",
          ),

          const SizedBox(height: 24),

          const FeatureRow(
            icon: Icons.favorite_rounded,
            title: "Goals",
            description: "Define objetivos de poupança e vê o progresso.",
          ),

          const SizedBox(height: 24),

          const FeatureRow(
            icon: Icons.person_rounded,
            title: "Profile",
            description: "Consulta o teu saldo e gere os dados da tua conta.",
          ),
        ],
      ),
    );
  }
}
