import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/edit_transaction_screen.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final isIncome = transaction.type == TransactionType.income;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: 'Error',
            bgColor: Colors.red,
            icon: Icons.error,
          );
        } else if (state is TransactionSuccess) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: 'Success',
            bgColor: Colors.green,
            icon: Icons.check_circle,
          );
          if (state.message.contains('deleted')) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: MAppBar(
          showBackArrow: true,
          title: Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(MSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MSizes.defaultSpace),
                decoration: BoxDecoration(
                  color: isDark ? MColors.dark : MColors.light,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Color(transaction.category.color),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        categoryIcons[transaction.category.iconIndex],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: MSizes.md),
                    Text(
                      transaction.category.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: MSizes.sm),
                    Text(
                      '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: MSizes.xs),
                    Text(
                      transaction.type.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: MColors.outline,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MSizes.spaceBtwSections),
              _DetailRow(
                label: 'Date',
                value: MHelperFunctions.formatDate(transaction.dateTime),
              ),
              _DetailRow(
                label: 'Time',
                value: MHelperFunctions.formatTime(transaction.dateTime),
              ),
              if (transaction.note.isNotEmpty)
                _DetailRow(
                  label: 'Note',
                  value: transaction.note,
                ),
              const SizedBox(height: MSizes.spaceBtwSections),
              Row(
                children: [
                  Expanded(
                    child: MButton(
                      btnTitle: 'Edit',
                      width: double.infinity,
                      height: 48,
                      onTap: () {
                        MHelperFunctions.navigateToScreen(
                          context,
                          EditTransactionScreen(transaction: transaction),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: MSizes.md),
                  Expanded(
                    child: MButton(
                      btnTitle: 'Delete',
                      width: double.infinity,
                      height: 48,
                      onTap: () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context
                    .read<TransactionBloc>()
                    .add(DeleteTransaction(transaction));
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MColors.outline,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
