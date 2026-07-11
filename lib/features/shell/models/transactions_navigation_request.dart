import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class TransactionsNavigationRequest {
  const TransactionsNavigationRequest({
    required this.filters,
    this.expandFilters = false,
  });

  final TransactionFilters filters;
  final bool expandFilters;
}
