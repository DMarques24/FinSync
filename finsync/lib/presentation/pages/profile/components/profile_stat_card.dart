import 'package:flutter/material.dart';

/// Pequeno cartão de estatística usado dentro do [ProfileHeader], sobre o
/// fundo em gradiente do cabeçalho do perfil.
class ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStatCard({super.key, required this.title, required this.value});

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
