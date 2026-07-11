import 'package:flutter/material.dart';
import 'package:money_tracker_app/features/dashboard/view/home_screen.dart';
import 'package:money_tracker_app/features/settings/view/settings_screen.dart';
import 'package:money_tracker_app/features/stats/view/stats_screen.dart';
import 'package:money_tracker_app/features/transactions/view/transactions_screen.dart';
import 'package:money_tracker_app/shared/widgets/bottom_navbar.dart';
import 'package:money_tracker_app/shared/widgets/floating_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onViewAllTransactions: () => _switchTab(1),
        onOpenSettings: () => _switchTab(3),
      ),
      const TransactionsScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: MBottomNavbar(
        currentIndex: _currentIndex,
        onIndexChange: _switchTab,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 3 ? null : const MFloatingActionButton(),
      body: SafeArea(child: screens[_currentIndex]),
    );
  }
}
