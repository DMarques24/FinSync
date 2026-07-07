import 'package:flutter/material.dart';

class BtnSettings extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback? onTap;

  const BtnSettings({
    super.key,
    required this.icon,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon),

            const SizedBox(width: 12),

            Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
