import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'card_list.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Últimas Despesas",
            style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
          ),

          const SizedBox(height: 20),

          const CardList(
            nome: "McDonald's",
            categoria: "Alimentação",
            data: "Hoje • 13:40",
            price: 14.50,
            icon: Icons.fastfood_rounded,
          ),

          CardList(
            nome: "Uber",
            categoria: "Transportes",
            data: "Ontem • 22:15",
            price: 8.90,
            icon: Icons.local_taxi_rounded,
          ),

          CardList(
            nome: "Netflix",
            categoria: "Subscrições",
            data: "15 Jun",
            price: 12.99,
            icon: Icons.movie_rounded,
          ),

          CardList(
            nome: "Continente",
            categoria: "Supermercado",
            data: "13 Jun",
            price: 56.40,
            icon: Icons.shopping_cart_rounded,
          ),

          CardList(
            nome: "Spotify",
            categoria: "Subscrições",
            data: "09 Jun",
            price: 7.99,
            icon: Icons.music_note_rounded,
          ),

          CardList(
            nome: "Galp",
            categoria: "Combustível",
            data: "08 Jun",
            price: 65,
            icon: Icons.local_gas_station_rounded,
          ),
        ],
      ),
    );
  }
}
