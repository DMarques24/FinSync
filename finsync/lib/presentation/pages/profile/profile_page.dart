import 'package:finsync/presentation/pages/profile/componente/btn_settings.dart';
import 'package:finsync/presentation/pages/profile/componente/photo_name.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PhotoName(
              image: Image.asset(
                "/Users/diogomomarques/Desktop/Diogo/FinSync/finsync/assets/images/person.jpeg",
              ),
              name: "Diogo Marques",
              userName: "@DiogoMarques",
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Definições",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView(
                  children: const [
                    BtnSettings(
                      icon: Icons.edit_outlined,
                      name: "Editar Perfil",
                    ),
                    Divider(height: 1),

                    BtnSettings(
                      icon: Icons.notifications_outlined,
                      name: "Notificações",
                    ),
                    Divider(height: 1),

                    BtnSettings(icon: Icons.lock_outline, name: "Segurança"),
                    Divider(height: 1),

                    BtnSettings(icon: Icons.dark_mode_outlined, name: "Tema"),
                    Divider(height: 1),

                    BtnSettings(icon: Icons.language_outlined, name: "Idioma"),
                    Divider(height: 1),

                    BtnSettings(icon: Icons.help_outline, name: "Ajuda"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Sair", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
