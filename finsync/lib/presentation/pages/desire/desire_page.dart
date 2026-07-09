import 'package:finsync/presentation/pages/desire/componente/desire_componente.dart';
import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/presentation/pages/desire/componente/add_desire.dart';

class DesirePage extends StatefulWidget {
  const DesirePage({super.key});

  @override
  State createState() => _DesirePageState();
}

class _DesirePageState extends State {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Os teus desejos ✨",
              style: AppTextStyles.headingLarge.copyWith(fontSize: 30),
            ),

            const SizedBox(height: 8),

            Text(
              "Define objetivos e acompanha aquilo que queres comprar.",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    builder: (context) => const AddDesire(),
                  );
                },

                icon: const Icon(Icons.add_rounded),

                label: const Text("Adicionar desejo"),
              ),
            ),

            const SizedBox(height: 30),

            Text("Os teus objetivos", style: AppTextStyles.headingMedium),

            const SizedBox(height: 18),

            const DesireComponent(
              image: AssetImage(
                "/Users/diogomomarques/Desktop/Diogo/FinSync/finsync/assets/images/mac.webp",
              ),
              name: "MacBook Pro M4",
              price: 2499,
              saved: 950,
              date: "31 Dez 2026",
            ),

            DesireComponent(
              image: const AssetImage(
                "/Users/diogomomarques/Desktop/Diogo/FinSync/finsync/assets/images/iphone17pro.webp",
              ),
              name: "iPhone 18 Pro",
              price: 1399,
              saved: 320,
              date: "15 Ago 2026",
            ),
          ],
        ),
      ),
    );
  }
}
