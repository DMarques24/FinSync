import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/sign_out_user.dart';

import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_state.dart';
import 'package:finsync/presentation/pages/profile/components/change_password_sheet.dart';
import 'package:finsync/presentation/pages/profile/components/edit_profile_form.dart';
import 'package:finsync/presentation/pages/profile/components/help_sheet.dart';
import 'package:finsync/presentation/pages/profile/components/language_picker_sheet.dart';
import 'package:finsync/presentation/pages/profile/components/notifications_sheet.dart';
import 'package:finsync/presentation/pages/profile/components/settings_button.dart';
import 'package:finsync/presentation/pages/profile/components/profile_header.dart';
import 'package:finsync/presentation/pages/profile/components/theme_picker_sheet.dart';
import 'package:finsync/presentation/pages/profile/components/currency_picker_sheet.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:finsync/presentation/pages/profile/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());

    final desireState = context.read<DesireBloc>().state;
    if (desireState is! DesireLoadedState) {
      context.read<DesireBloc>().add(GetAllDesiresEvent());
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terminar sessão"),
        content: const Text("Tens a certeza que queres sair da tua conta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Terminar Sessão",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _openSheet(Widget child, {bool isScrollControlled = true}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => child,
    );
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await sl<SignOutUser>()();

      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorTranslator.translate(e))),
      );
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            String displayName = '';
            String displayEmail = '';
            String displayBalance = '';
            String? avatarUrl;

            if (state is ProfileLoadedState) {
              displayName = state.user.username;
              displayEmail = state.email;
              displayBalance = AppCurrency.format(state.user.balance);
              avatarUrl = state.user.avatarUrl;
            }

            final homeState = context.watch<HomeBloc>().state;
            final expensesCount = homeState is HomeLoadedState
                ? homeState.expenses.length.toString()
                : '—';

            final desireState = context.watch<DesireBloc>().state;
            String desiresCount = '—';
            String savedAmount = '—';
            if (desireState is DesireLoadedState) {
              desiresCount = desireState.desire.length.toString();
              final totalSaved = desireState.desire.fold<double>(
                0,
                (sum, desire) => sum + desire.saved,
              );
              savedAmount = AppCurrency.format(totalSaved);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state is ProfileLoadingState)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  else if (state is ProfileErrorState)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ProfileHeader(
                      avatarUrl: avatarUrl,
                      name: displayName,
                      userName: displayEmail,
                      balance: displayBalance,
                      expensesCount: expensesCount,
                      desiresCount: desiresCount,
                      savedAmount: savedAmount,
                      onEditAvatar: () => _openSheet(
                        EditProfileForm(
                          currentUsername: displayName,
                          currentAvatarUrl: avatarUrl,
                        ),
                      ),
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
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      children: [
                        SettingsButton(
                          icon: Icons.person_outline_rounded,
                          name: "Editar Perfil",
                          onTap: () => _openSheet(
                            EditProfileForm(
                              currentUsername: displayName,
                              currentAvatarUrl: avatarUrl,
                            ),
                          ),
                        ),
                        const Divider(height: 1),

                        SettingsButton(
                          icon: Icons.notifications_outlined,
                          name: "Notificações",
                          onTap: () => _openSheet(const NotificationsSheet()),
                        ),
                        const Divider(height: 1),

                        SettingsButton(
                          icon: Icons.lock_outline_rounded,
                          name: "Segurança",
                          onTap: () =>
                              _openSheet(const ChangePasswordSheet()),
                        ),
                        const Divider(height: 1),

                        SettingsButton(
                          icon: Icons.dark_mode_outlined,
                          name: "Tema",
                          onTap: () =>
                              _openSheet(const ThemePickerSheet(), isScrollControlled: false),
                        ),
                        const Divider(height: 1),

                        SettingsButton(
                          icon: Icons.attach_money_rounded,
                          name: "Moeda",
                          onTap: () =>
                              _openSheet(const CurrencyPickerSheet()),
                        ),
                        const Divider(height: 1),

                        SettingsButton(
                          icon: Icons.language_outlined,
                          name: "Idioma",
                          onTap: () =>
                              _openSheet(const LanguagePickerSheet(), isScrollControlled: false),
                        ),
                        const Divider(height: 1),

                        SettingsButton(
                          icon: Icons.help_outline_rounded,
                          name: "Ajuda",
                          onTap: () => _openSheet(const HelpSheet()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _isLoggingOut ? null : _confirmLogout,
                      icon: _isLoggingOut
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                            ),
                      label: Text(
                        "Terminar Sessão",
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
