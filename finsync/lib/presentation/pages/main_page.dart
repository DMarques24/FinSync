import 'package:finsync/presentation/pages/home/componente/add_expenses.dart';
import 'package:flutter/material.dart';
import 'package:finsync/presentation/pages/home/home_page.dart';
import 'package:liquid_glass_bar/liquid_glass_bar.dart';
import 'package:finsync/presentation/pages/profile/profile_page.dart';
import 'package:finsync/presentation/pages/search/search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final pages = const [HomePage(), SearchPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'FinSync',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddExpenses(),
          );
        },
        child: const Icon(Icons.add),
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
      ),
      extendBody: true,
      body: pages[currentIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: LiquidGlassBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            LiquidGlassBarItem(iconData: Icons.home, label: 'Home'),
            LiquidGlassBarItem(iconData: Icons.search, label: 'Search'),
            LiquidGlassBarItem(iconData: Icons.person, label: 'Profile'),
          ],
          style: LiquidGlassBarStyle(
            activeColor: Colors.blue,
            inactiveColor: Colors.grey,
          ),
        ),
      ),
    );
  }
}
