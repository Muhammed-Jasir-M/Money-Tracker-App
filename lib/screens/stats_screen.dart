import 'package:flutter/material.dart';
import 'package:money_tracker_app/screens/tabbar_tabs/expense_screen.dart';
import 'package:money_tracker_app/screens/tabbar_tabs/income_screen.dart';
import 'package:money_tracker_app/utils/constants/colors.dart';
import 'package:money_tracker_app/utils/constants/sizes.dart';
import 'package:money_tracker_app/utils/helper_functions.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Padding(
      padding: EdgeInsets.all(MSizes.defaultSpace),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isDark ? MColors.dark : MColors.light,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: TabBar(
                controller: tabController,
                indicatorColor:
                    isDark ? MColors.primary : MColors.secondary,
                labelColor: isDark ? MColors.secondary : MColors.primary,
                unselectedLabelColor:
                    isDark ? MColors.secondary : MColors.primary,
                dividerHeight: 0,
                indicatorWeight: 2,
                indicator: BoxDecoration(
                  color: isDark
                      ? MColors.bgDark.withValues(alpha: 1.0)
                      : MColors.bgLight.withValues(alpha: 1.0),
                  borderRadius: BorderRadius.circular(5),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(5),
                tabs: const [
                  Tab(text: 'Income'),
                  Tab(text: 'Expense'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                IncomeScreen(),
                ExpenseScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
