import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/componente/desire_componente.dart';
import 'package:flutter/widgets.dart';

class DesiresList extends StatelessWidget {
  final List<Desire> desires;

  const DesiresList({super.key, required this.desires});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...desires.map(
            (desire) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DesireComponent(
                image: desire.image,
                name: desire.name,
                price: desire.price,
                //  saved: desire.saved,
                date: _formatDate(desire.date),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
