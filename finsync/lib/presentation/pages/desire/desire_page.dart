import 'package:finsync/presentation/pages/desire/componente/add_desire.dart';
import 'package:finsync/presentation/pages/desire/componente/desire_componente.dart';
import 'package:flutter/material.dart';

class DesirePage extends StatefulWidget {
  const DesirePage({super.key});

  @override
  State<DesirePage> createState() => _DesirePageState();
}

class _DesirePageState extends State<DesirePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "✨ Os teus desejos",
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            Text("Poupa para aquilo que realmente queres."),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const AddDesire(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Novo desejo"),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  DesireComponent(
                    image: const AssetImage(
                      "/Users/diogomomarques/Desktop/Diogo/FinSync/finsync/assets/images/mac.webp",
                    ),
                    name: "MacBook Pro M4",
                    price: 2499,
                    date: DateTime.now(),
                  ),

                  DesireComponent(
                    image: const AssetImage(
                      "/Users/diogomomarques/Desktop/Diogo/FinSync/finsync/assets/images/iphone17pro.webp",
                    ),
                    name: "iPhone 18 Pro",
                    price: 1399,
                    date: DateTime.now(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
