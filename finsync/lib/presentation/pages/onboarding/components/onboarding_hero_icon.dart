import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:flutter/material.dart';


class OnboardingHeroIcon extends StatelessWidget {
  final IconData icon;

  const OnboardingHeroIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: .18),
            AppColors.secondary.withValues(alpha: .06),
          ],
        ),
        borderRadius: AppRadius.all(26),
        border: Border.all(color: AppColors.secondary.withValues(alpha: .18)),
      ),
      
      child: ExcludeSemantics(
        child: Icon(icon, size: 42, color: AppColors.secondary),
      ),
    );
  }
}
