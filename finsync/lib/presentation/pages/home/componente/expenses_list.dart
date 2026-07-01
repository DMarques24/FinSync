import 'package:flutter/material.dart';
import 'package:finsync/presentation/pages/home/componente/card_list.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400, // Altura da lista
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Últimas Despesas",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: const [
                CardList(
                  nome: "McDonald's",
                  categoria: "Alimentação",
                  data: "Hoje • 13:40",
                  price: 14.50,
                  icon: Icons.fastfood,
                ),

                CardList(
                  nome: "Uber",
                  categoria: "Transportes",
                  data: "Ontem • 22:15",
                  price: 8.90,
                  icon: Icons.local_taxi,
                ),

                CardList(
                  nome: "Netflix",
                  categoria: "Subscrições",
                  data: "15 Jun",
                  price: 12.99,
                  icon: Icons.movie,
                ),

                CardList(
                  nome: "Continente",
                  categoria: "Supermercado",
                  data: "13 Jun",
                  price: 56.40,
                  icon: Icons.shopping_cart,
                ),

                CardList(
                  nome: "Amazon",
                  categoria: "Compras",
                  data: "10 Jun",
                  price: 39.99,
                  icon: Icons.shopping_bag,
                ),

                CardList(
                  nome: "Spotify",
                  categoria: "Subscrições",
                  data: "09 Jun",
                  price: 7.99,
                  icon: Icons.music_note,
                ),

                CardList(
                  nome: "Galp",
                  categoria: "Combustível",
                  data: "08 Jun",
                  price: 65.00,
                  icon: Icons.local_gas_station,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
