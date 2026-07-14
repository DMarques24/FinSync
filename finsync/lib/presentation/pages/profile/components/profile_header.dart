import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class PhotoName extends StatelessWidget {
  final String imagePath;
  final String name;
  final String userName;

  const PhotoName({
    super.key,
    required this.imagePath,
    required this.name,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,

                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: AssetImage(imagePath),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(7),

                  decoration: BoxDecoration(
                    color: AppColors.secondary,

                    shape: BoxShape.circle,

                    border: Border.all(color: Colors.white, width: 2),
                  ),

                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            name,
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 6),

          Text(
            userName,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoCard(title: "Despesas", value: "128"),
              _InfoCard(title: "Desejos", value: "12"),
              _InfoCard(title: "Poupado", value: "€2.4k"),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
