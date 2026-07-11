import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';
import 'package:money_tracker_app/features/transactions/view/transaction_detail_screen.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  TransactionFilters _filters = const TransactionFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters(TransactionFilters filters) {
    setState(() => _filters = filters);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: 'Error',
            bgColor: Colors.red,
            icon: Icons.error,
          );
        }
      },
      builder: (context, state) {
        if (state is TransactionLoading || state is TransactionInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = switch (state) {
          TransactionLoaded(:final transactions) => transactions,
          TransactionSuccess(:final transactions) => transactions,
          _ => <TransactionModel>[],
        };

        final filtered = _filters.apply(transactions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MSizes.defaultSpace,
                MSizes.defaultSpace,
                MSizes.defaultSpace,
                MSizes.sm,
              ),
              child: Text(
                'Transactions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MSizes.defaultSpace,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by category, note, amount...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _filters.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _updateFilters(_filters.copyWith(searchQuery: ''));
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: MHelperFunctions.isDarkMode(context)
                      ? MColors.dark
                      : MColors.light,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) =>
                    _updateFilters(_filters.copyWith(searchQuery: value)),
              ),
            ),
            const SizedBox(height: MSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MSizes.defaultSpace,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeFilterDropdown(
                      selectedType: _filters.type,
                      onChanged: (type) => _updateFilters(
                        _filters.copyWith(
                          type: type,
                          clearType: type == null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: MSizes.sm),
                  Expanded(
                    child: _CategoryFilterDropdown(
                      selectedCategory: _filters.category,
                      onChanged: (category) => _updateFilters(
                        _filters.copyWith(
                          category: category,
                          clearCategory: category == null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MSizes.sm),
            _DateFilterChips(
              selectedFilter: _filters.dateFilter,
              onChanged: (filter) =>
                  _updateFilters(_filters.copyWith(dateFilter: filter)),
            ),
            if (_filters.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MSizes.defaultSpace,
                  vertical: MSizes.xs,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _updateFilters(const TransactionFilters());
                    },
                    child: const Text('Clear filters'),
                  ),
                ),
              ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        transactions.isEmpty
                            ? 'No transactions yet'
                            : 'No transactions match your filters',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(MSizes.defaultSpace),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final transaction = filtered[index];
                        final showHeader = index == 0 ||
                            !MHelperFunctions.isSameDay(
                              transaction.dateTime,
                              filtered[index - 1].dateTime,
                            );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  MHelperFunctions.formatDateHeader(
                                    transaction.dateTime,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            MTransactionTile(
                              icon: categoryIcons[
                                  transaction.category.iconIndex],
                              title: transaction.category.title,
                              iconBgColor: Color(transaction.category.color),
                              amount: transaction.amount,
                              time: MHelperFunctions.formatTime(
                                transaction.dateTime,
                              ),
                              type: transaction.type,
                              onTap: () {
                                MHelperFunctions.navigateToScreen(
                                  context,
                                  TransactionDetailScreen(
                                    transaction: transaction,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TypeFilterDropdown extends StatelessWidget {
  const _TypeFilterDropdown({
    required this.selectedType,
    required this.onChanged,
  });

  final TransactionType? selectedType;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TransactionType?>(
      value: selectedType,
      decoration: _filterDecoration(context),
      items: const [
        DropdownMenuItem(
          value: null,
          child: Text('All types'),
        ),
        DropdownMenuItem(
          value: TransactionType.income,
          child: Text('Income'),
        ),
        DropdownMenuItem(
          value: TransactionType.expense,
          child: Text('Expense'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _CategoryFilterDropdown extends StatelessWidget {
  const _CategoryFilterDropdown({
    required this.selectedCategory,
    required this.onChanged,
  });

  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = switch (state) {
          CategoryLoaded(:final categories) => categories,
          CategorySuccess(:final categories) => categories,
          _ => <CategoryModel>[],
        };

        return DropdownButtonFormField<String?>(
          value: selectedCategory?.cId,
          decoration: _filterDecoration(context),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All categories'),
            ),
            ...categories.map(
              (category) => DropdownMenuItem(
                value: category.cId,
                child: Text(
                  category.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: categories.isEmpty
              ? null
              : (value) {
                  if (value == null) {
                    onChanged(null);
                    return;
                  }
                  final category = categories.firstWhere(
                    (item) => item.cId == value,
                  );
                  onChanged(category);
                },
        );
      },
    );
  }
}

InputDecoration _filterDecoration(BuildContext context) {
  return InputDecoration(
    filled: true,
    fillColor: MHelperFunctions.isDarkMode(context)
        ? MColors.dark
        : MColors.light,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

class _DateFilterChips extends StatelessWidget {
  const _DateFilterChips({
    required this.selectedFilter,
    required this.onChanged,
  });

  final TransactionDateFilter selectedFilter;
  final ValueChanged<TransactionDateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: MSizes.defaultSpace),
      child: Row(
        children: [
          _FilterChip(
            label: 'All time',
            selected: selectedFilter == TransactionDateFilter.all,
            onTap: () => onChanged(TransactionDateFilter.all),
          ),
          const SizedBox(width: MSizes.sm),
          _FilterChip(
            label: 'This week',
            selected: selectedFilter == TransactionDateFilter.thisWeek,
            onTap: () => onChanged(TransactionDateFilter.thisWeek),
          ),
          const SizedBox(width: MSizes.sm),
          _FilterChip(
            label: 'This month',
            selected: selectedFilter == TransactionDateFilter.thisMonth,
            onTap: () => onChanged(TransactionDateFilter.thisMonth),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}
