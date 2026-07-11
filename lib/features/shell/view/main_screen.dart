import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/dashboard/view/home_screen.dart';
import 'package:money_tracker_app/features/budgets/view/manage_budgets_screen.dart';
import 'package:money_tracker_app/features/settings/view/manage_categories_screen.dart';
import 'package:money_tracker_app/features/settings/view/settings_screen.dart';
import 'package:money_tracker_app/features/shell/models/transactions_navigation_request.dart';
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
  int _transactionsScreenVersion = 0;
  TransactionsNavigationRequest? _transactionsRequest;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openTransactions(TransactionsNavigationRequest request) {
    setState(() {
      _transactionsRequest = request;
      _transactionsScreenVersion++;
      _currentIndex = 1;
    });
  }

  void _clearTransactionsRequest() {
    if (_transactionsRequest != null) {
      setState(() => _transactionsRequest = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onViewAllTransactions: () => _switchTab(1),
        onOpenBudgets: () {
          MHelperFunctions.navigateToScreen(
            context,
            const ManageBudgetsScreen(),
          );
        },
        onOpenCategories: () {
          MHelperFunctions.navigateToScreen(
            context,
            const ManageCategoriesScreen(),
          );
        },
      ),
      TransactionsScreen(
        key: ValueKey(_transactionsScreenVersion),
        navigationRequest: _transactionsRequest,
        onNavigationRequestHandled: _clearTransactionsRequest,
      ),
      StatsScreen(
        onOpenTransactions: (filters) => _openTransactions(
          TransactionsNavigationRequest(filters: filters),
        ),
      ),
      const SettingsScreen(),
    ];

    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      bottomNavigationBar: MBottomNavbar(
        currentIndex: _currentIndex,
        onIndexChange: _switchTab,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          keyboardVisible ? null : const MFloatingActionButton(),
      body: SafeArea(child: screens[_currentIndex]),
    );
  }
}
