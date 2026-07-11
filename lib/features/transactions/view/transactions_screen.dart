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
import 'package:money_tracker_app/shared/widgets/confirm_dialog.dart';
import 'package:money_tracker_app/shared/widgets/empty_state.dart';
import 'package:money_tracker_app/shared/widgets/period_filter_section.dart';
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
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
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
    _searchFocusNode.dispose();
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
      _searchController.text = request.filters.searchQuery;
    }

    if (fromInit) {
      apply();
    } else {
      setState(apply);
    }

    if (request.expandFilters) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openFiltersSortSheet();
        }
      });
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

  void _openFiltersSortSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    final categoryController = TextEditingController(
      text: _filters.category?.title ?? '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void syncCategoryField() {
              categoryController.text = _filters.category?.title ?? '';
            }

            void onFiltersChanged(TransactionFilters filters) {
              _updateFilters(filters);
              syncCategoryField();
              setSheetState(() {});
            }

            Future<void> onClearFilters() async {
              await _confirmClearFilters();
              if (context.mounted) {
                syncCategoryField();
                setSheetState(() {});
              }
            }

            return _TransactionFiltersSortSheet(
              filters: _filters,
              categoryController: categoryController,
              onChanged: onFiltersChanged,
              onTypeChanged: (type) {
                _applyTypeFilter(type);
                syncCategoryField();
                setSheetState(() {});
              },
              onClear: _filters.hasActiveFilters ? onClearFilters : null,
            );
          },
        );
      },
    ).whenComplete(categoryController.dispose);
  }

  bool get _hasCustomSort =>
      _filters.sortOrder != TransactionSortOrder.newestFirst;

  bool get _hasActiveFiltersOrSort =>
      _filters.hasActiveFilters || _hasCustomSort;

  Future<void> _confirmClearFilters() async {
    if (!_filters.hasActiveFilters) return;

    final confirmed = await MConfirmDialog.show(
      context: context,
      title: 'Clear all filters?',
      message: 'This will reset search, type, period, and category.',
      confirmLabel: 'Clear',
      icon: Icons.filter_alt_off_outlined,
    );
    if (!confirmed || !mounted) return;

    _searchController.clear();
    _updateFilters(
      TransactionFilters(sortOrder: _filters.sortOrder),
    );
  }

  Future<void> _confirmDeleteTransaction(TransactionModel transaction) async {
    final confirmed = await MConfirmDialog.show(
      context: context,
      title: 'Delete transaction?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    context.read<TransactionBloc>().add(DeleteTransaction(transaction));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: tabScreenAppBar(
        context,
        title: 'Transactions',
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
            onPressed: _openFiltersSortSheet,
            tooltip: 'Filter & sort',
            icon: Badge(
              isLabelVisible: _hasActiveFiltersOrSort,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
          ),
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
                focusNode: _searchFocusNode,
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
            Expanded(
              child: filtered.isEmpty
                  ? MEmptyState(
                      compact: true,
                      icon: transactions.isEmpty
                          ? Icons.receipt_long_outlined
                          : Icons.search_off_outlined,
                      title: transactions.isEmpty
                          ? 'No transactions yet'
                          : 'No matches found',
                      subtitle: transactions.isEmpty
                          ? 'Tap + to record your first transaction'
                          : 'Try changing search or filters',
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
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                            Dismissible(
                              key: ValueKey(transaction.tId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                margin: const EdgeInsets.only(bottom: MSizes.sm),
                                padding: const EdgeInsets.only(right: MSizes.lg),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                await _confirmDeleteTransaction(transaction);
                                return false;
                              },
                              child: MTransactionTile(
                                icon: categoryIcons[
                                    transaction.category.iconIndex],
                                title: transaction.category.title,
                                note: transaction.note,
                                iconBgColor:
                                    Color(transaction.category.color),
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
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
    );
  }
}

class _TransactionFiltersSortSheet extends StatelessWidget {
  const _TransactionFiltersSortSheet({
    required this.filters,
    required this.categoryController,
    required this.onChanged,
    required this.onTypeChanged,
    this.onClear,
  });

  final TransactionFilters filters;
  final TextEditingController categoryController;
  final ValueChanged<TransactionFilters> onChanged;
  final ValueChanged<TransactionType?> onTypeChanged;
  final Future<void> Function()? onClear;

  Future<void> _openCategoryFilter(BuildContext context) async {
    final bloc = context.read<CategoryBloc>();
    final categories = await ensureCategoriesLoaded(bloc);
    if (!context.mounted) return;

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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final sectionTitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: MSizes.formLabelSize,
        );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MSizes.defaultSpace,
            MSizes.sm,
            MSizes.defaultSpace,
            MSizes.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter & sort',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: MSizes.lg),
              Text('Type', style: sectionTitleStyle),
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
              Text('Period', style: sectionTitleStyle),
              const SizedBox(height: MSizes.sm),
              PeriodFilterSection(
                filters: filters,
                onChanged: onChanged,
              ),
              const SizedBox(height: MSizes.md),
              MTextFormField(
                controller: categoryController,
                label: 'Category',
                hintText: 'All categories',
                prefixIcon: filters.category != null
                    ? categoryIcons[filters.category!.iconIndex]
                    : Icons.category_outlined,
                readOnly: true,
                suffixIcon: Icons.chevron_right,
                onTap: () => _openCategoryFilter(context),
              ),
              if (onClear != null) ...[
                const SizedBox(height: MSizes.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onClear,
                    child: const Text('Clear filters'),
                  ),
                ),
              ],
              const SizedBox(height: MSizes.lg),
              Text('Sort by', style: sectionTitleStyle),
              const SizedBox(height: MSizes.sm),
              SortOrderSection(
                sortOrder: filters.sortOrder,
                onChanged: (order) =>
                    onChanged(filters.copyWith(sortOrder: order)),
              ),
              const SizedBox(height: MSizes.lg),
            ],
          ),
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
