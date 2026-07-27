import 'package:finsync/presentation/pages/analytics/analytics_page.dart';
import 'package:flutter/material.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/presentation/pages/desire/desire_page.dart';
import 'package:finsync/presentation/pages/home/components/add_expense_form.dart';
import 'package:finsync/presentation/pages/home/home_page.dart';
import 'package:finsync/presentation/pages/profile/profile_page.dart';

import 'package:liquid_glass_bar/liquid_glass_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    AnalyticsPage(),
    DesirePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 17,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              tr('main_nav.app_name'),
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),
          ],
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[currentIndex],
      ),

      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              heroTag: "addExpense",
              elevation: 8,
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: const Icon(Icons.add, size: 28),

              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.surface,

                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),

                  builder: (_) => const AddExpenseForm(),
                );
              },
            )
          : null,

      extendBody: true,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        child: LiquidGlassBar(
          currentIndex: currentIndex,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          items: [
            LiquidGlassBarItem(iconData: Icons.home_rounded, label: tr('main_nav.home')),
            LiquidGlassBarItem(iconData: Icons.analytics, label: tr('main_nav.analytics')),
            LiquidGlassBarItem(
              iconData: Icons.favorite_rounded,
              label: tr('main_nav.goals'),
            ),
            LiquidGlassBarItem(
              iconData: Icons.person_rounded,
              label: tr('main_nav.profile'),
            ),
          ],

          style: LiquidGlassBarStyle(
            activeColor: AppColors.secondary,
            inactiveColor: AppColors.textSecondary,
            liquidGlassSettings: LiquidGlassSettings(
              glassColor: AppColors.isDark
                  ? Colors.black.withValues(alpha: .35)
                  : Colors.white.withValues(alpha: .8),
            ),
          ),
        ),
      ),
    );
  }
}
