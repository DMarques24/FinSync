import 'package:flutter/material.dart';

class DesireComponent extends StatelessWidget {
  final ImageProvider image;
  final String name;
  final double price;
  final DateTime date;
  final VoidCallback? onTap;

  const DesireComponent({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image(
                  image: image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${price.toStringAsFixed(2)} €",
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Adicionado em ${date.day}/${date.month}/${date.year}",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
