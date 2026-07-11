import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/transactions/view/add_transaction_screen.dart';

class MFloatingActionButton extends StatelessWidget {
  const MFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: MColors.primary,
      onPressed: () {
        MHelperFunctions.navigateToScreen(context, AddTransactionScreen());
      },
      shape: CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: MColors.floatingButtonGradient),
        child: Icon(CupertinoIcons.add),
      ),
    );
  }
}
