import 'package:flutter/material.dart';
import 'package:money_tracker_app/screens/transaction_form/widget/transaction_form.dart';
import 'package:money_tracker_app/widgets/appbar.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MAppBar(
        showBackArrow: true,
        title: Text(
          'Add Transaction',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: const SingleChildScrollView(
        child: MTransactionForm(isEditing: false),
      ),
    );
  }
}
