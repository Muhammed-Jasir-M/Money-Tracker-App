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
import 'package:money_tracker_app/features/settings/view/manage_categories_screen.dart';
import 'package:money_tracker_app/features/shell/models/transactions_navigation_request.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';
import 'package:money_tracker_app/features/transactions/view/transaction_detail_screen.dart';
import 'package:money_tracker_app/features/transactions/view/widgets/category_picker_sheet.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    this.navigationRequest,
    this.onNavigationRequestHandled,
  });

  final TransactionsNavigationRequest? navigationRequest;
  final VoidCallback? onNavigationRequestHandled;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionFilters _filters = const TransactionFilters();
  bool _filtersExpanded = false;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _applyNavigationRequest(fromInit: true);
  }

  @override
  void didUpdateWidget(TransactionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationRequest != oldWidget.navigationRequest) {
      _applyNavigationRequest();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyNavigationRequest({bool fromInit = false}) {
    final request = widget.navigationRequest;
    if (request == null) {
      return;
    }

    void apply() {
      _filters = request.filters;
      _filtersExpanded = request.expandFilters;
      _searchController.text = request.filters.searchQuery;
    }

    if (fromInit) {
      apply();
    } else {
      setState(apply);
    }

    final onHandled = widget.onNavigationRequestHandled;
    if (onHandled != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          onHandled();
        }
      });
    }
  }

  void _updateFilters(TransactionFilters filters) {
    setState(() => _filters = filters);
  }

  void _collapseFilters() {
    if (_filtersExpanded) {
      setState(() => _filtersExpanded = false);
    }
  }

  void _applyTypeFilter(TransactionType? type) {
    var next = _filters.copyWith(
      type: type,
      clearType: type == null,
    );

    if (next.category != null &&
        type != null &&
        next.category!.type != type) {
      next = next.copyWith(clearCategory: true);
    }

    _updateFilters(next);
  }

  void _toggleFilters() {
    setState(() => _filtersExpanded = !_filtersExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MAppBar(
        centerTitle: false,
        titleSpacing: MSizes.defaultSpace,
        title: Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              MHelperFunctions.navigateToScreen(
                context,
                const ManageCategoriesScreen(),
              );
            },
            tooltip: 'Manage categories',
            icon: const Icon(Icons.category_outlined),
          ),
          IconButton(
            onPressed: _toggleFilters,
            tooltip: 'Filters',
            icon: Badge(
              isLabelVisible: _filters.hasActiveFilters,
              smallSize: 8,
              child: Icon(
                _filtersExpanded ? Icons.filter_list_off : Icons.filter_list,
              ),
            ),
          ),
          const SizedBox(width: MSizes.sm),
        ],
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
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
                MSizes.sm,
                MSizes.defaultSpace,
                MSizes.sm,
              ),
              child: MTextFormField(
                controller: _searchController,
                label: 'Search',
                hintText: 'Note, amount, or category',
                prefixIcon: Icons.search,
                suffixIcon: _filters.searchQuery.isNotEmpty
                    ? Icons.close
                    : null,
                onIconPressed: _filters.searchQuery.isNotEmpty
                    ? () {
                        _searchController.clear();
                        _updateFilters(
                          _filters.copyWith(searchQuery: ''),
                        );
                      }
                    : null,
                onChanged: (value) =>
                    _updateFilters(_filters.copyWith(searchQuery: value)),
              ),
            ),
            if (_filtersExpanded) ...[
              const SizedBox(height: MSizes.sm),
              _TransactionFiltersPanel(
                filters: _filters,
                onChanged: _updateFilters,
                onTypeChanged: _applyTypeFilter,
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
            ],
            Expanded(
              child: GestureDetector(
                onTap: _collapseFilters,
                behavior: HitTestBehavior.translucent,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification &&
                        _filtersExpanded) {
                      _collapseFilters();
                    }
                    return false;
                  },
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
                              note: transaction.note,
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
                ),
            ),
          ],
        );
      },
    ),
    );
  }
}

class _TransactionFiltersPanel extends StatelessWidget {
  const _TransactionFiltersPanel({
    required this.filters,
    required this.onChanged,
    required this.onTypeChanged,
  });

  final TransactionFilters filters;
  final ValueChanged<TransactionFilters> onChanged;
  final ValueChanged<TransactionType?> onTypeChanged;

  Future<void> _openCategoryFilter(BuildContext context) async {
    final bloc = context.read<CategoryBloc>();
    var state = bloc.state;

    if (state is! CategoryLoaded) {
      bloc.add(LoadCategories());
      await bloc.stream.firstWhere(
        (s) => s is CategoryLoaded || s is CategoryError,
      );
      if (!context.mounted) return;
      state = bloc.state;
    }

    final categories =
        state is CategoryLoaded ? state.categories : <CategoryModel>[];

    final result = await showCategoryPickerSheet(
      context: context,
      categories: categories,
      selectedCategory: filters.category,
      filterType: filters.type,
      allowAllOption: true,
      showAddButton: false,
      showTypeBadge: false,
      title: 'Filter by category',
    );

    if (!context.mounted || result == null) return;

    if (result == 'all') {
      onChanged(filters.copyWith(clearCategory: true));
      return;
    }

    onChanged(filters.copyWith(category: result as CategoryModel));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MSizes.defaultSpace),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MSizes.md),
        decoration: BoxDecoration(
          color: isDark ? MColors.dark : MColors.light,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: MSizes.formLabelSize,
                  ),
            ),
            const SizedBox(height: MSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _FilterOptionChip(
                    label: 'All',
                    selected: filters.type == null,
                    onTap: () => onTypeChanged(null),
                  ),
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: _FilterOptionChip(
                    label: 'Income',
                    selected: filters.type == TransactionType.income,
                    selectedColor: Colors.green,
                    onTap: () => onTypeChanged(TransactionType.income),
                  ),
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: _FilterOptionChip(
                    label: 'Expense',
                    selected: filters.type == TransactionType.expense,
                    selectedColor: Colors.red,
                    onTap: () => onTypeChanged(TransactionType.expense),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MSizes.md),
            Text(
              'Period',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: MSizes.formLabelSize,
                  ),
            ),
            const SizedBox(height: MSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _FilterOptionChip(
                    label: 'All time',
                    selected:
                        filters.dateFilter == TransactionDateFilter.all,
                    onTap: () => onChanged(
                      filters.copyWith(
                        dateFilter: TransactionDateFilter.all,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: _FilterOptionChip(
                    label: 'This week',
                    selected: filters.dateFilter ==
                        TransactionDateFilter.thisWeek,
                    onTap: () => onChanged(
                      filters.copyWith(
                        dateFilter: TransactionDateFilter.thisWeek,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: _FilterOptionChip(
                    label: 'This month',
                    selected: filters.dateFilter ==
                        TransactionDateFilter.thisMonth,
                    onTap: () => onChanged(
                      filters.copyWith(
                        dateFilter: TransactionDateFilter.thisMonth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MSizes.md),
            MTextFormField(
              label: 'Category',
              hintText: filters.category?.title ?? 'All categories',
              prefixIcon: filters.category != null
                  ? categoryIcons[filters.category!.iconIndex]
                  : Icons.category_outlined,
              readOnly: true,
              suffixIcon: Icons.chevron_right,
              onTap: () => _openCategoryFilter(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? Theme.of(context).colorScheme.primary;
    final isDark = MHelperFunctions.isDarkMode(context);
    final baseColor = isDark ? MColors.bgDark : MColors.bgLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.15) : baseColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? accent : null,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
