import 'package:finsync/presentation/pages/home/componente/card_cash_flow.dart';
import 'package:finsync/presentation/pages/home/componente/expenses_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: const [
            CardCashFlow(cashIn: 1000, cashOut: 20),
            SizedBox(height: 8),
            Text("Gastos:"),
            SizedBox(height: 8),
            ExpensesList(),
          ],
        ),
      ),
    );
  }
}
