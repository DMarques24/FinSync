import 'package:flutter/material.dart';
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

  final pages = const [HomePage(), DesirePage(), ProfilePage()];

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

        title: Text(
          "FinSync",
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
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

          items: const [
            LiquidGlassBarItem(iconData: Icons.home_rounded, label: "Home"),
            LiquidGlassBarItem(
              iconData: Icons.favorite_rounded,
              label: "Goals",
            ),
            LiquidGlassBarItem(
              iconData: Icons.person_rounded,
              label: "Profile",
            ),
          ],

          style: const LiquidGlassBarStyle(
            activeColor: AppColors.secondary,
            inactiveColor: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
