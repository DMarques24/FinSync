import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/presentation/pages/profile/components/settings_button.dart';
import 'package:finsync/presentation/pages/profile/components/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(
                imagePath: "assets/images/person.jpeg",
                name: "Diogo Marques",
                userName: "@DiogoMarques",
              ),

              const SizedBox(height: 30),

              Text(
                "Definições",
                style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
              ),

              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .03),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    SettingsButton(
                      icon: Icons.person_outline_rounded,
                      name: "Editar Perfil",
                    ),
                    Divider(height: 1),

                    SettingsButton(
                      icon: Icons.notifications_outlined,
                      name: "Notificações",
                    ),
                    Divider(height: 1),

                    SettingsButton(
                      icon: Icons.lock_outline_rounded,
                      name: "Segurança",
                    ),
                    Divider(height: 1),

                    SettingsButton(icon: Icons.dark_mode_outlined, name: "Tema"),
                    Divider(height: 1),

                    SettingsButton(icon: Icons.language_outlined, name: "Idioma"),
                    Divider(height: 1),

                    SettingsButton(
                      icon: Icons.help_outline_rounded,
                      name: "Ajuda",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    "Terminar Sessão",
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
