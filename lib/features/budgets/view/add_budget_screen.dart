import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/features/budgets/bloc/budget_bloc.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/widgets/category_picker_sheet.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';

enum _BudgetTarget { total, category }

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key, this.budget});

  final BudgetModel? budget;

  bool get isEditing => budget != null;

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryFieldKey = GlobalKey<FormFieldState<void>>();
  _BudgetTarget _target = _BudgetTarget.total;
  CategoryModel? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final budget = widget.budget!;
      _amountController.text =
          budget.amountLimit == budget.amountLimit.roundToDouble()
              ? budget.amountLimit.toInt().toString()
              : budget.amountLimit.toString();
      if (budget.categoryId == null) {
        _target = _BudgetTarget.total;
      } else {
        _target = _BudgetTarget.category;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  TextStyle? _sectionLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: MSizes.formLabelSize,
        );
  }

  Future<void> _resolveCategoryIfEditing() async {
    if (!widget.isEditing || widget.budget!.categoryId == null) return;

    final categories = await ensureCategoriesLoaded(context.read<CategoryBloc>());
    if (!mounted) return;

    final match = categories
        .where((c) => c.cId == widget.budget!.categoryId)
        .toList();
    if (match.isNotEmpty) {
      setState(() => _selectedCategory = match.first);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isEditing && _selectedCategory == null) {
      _resolveCategoryIfEditing();
    }
  }

  Future<void> _openCategoryPicker() async {
    final categories = await ensureCategoriesLoaded(context.read<CategoryBloc>());
    if (!mounted) return;

    final expenseCategories =
        categories.where((c) => c.type == TransactionType.expense).toList();

    final result = await showCategoryPickerSheet(
      context: context,
      categories: expenseCategories,
      selectedCategory: _selectedCategory,
      filterType: TransactionType.expense,
      allowAllOption: false,
      showAddButton: false,
      showTypeBadge: false,
      title: 'Budget category',
    );

    if (!mounted || result is! CategoryModel) return;
    setState(() => _selectedCategory = result);
    _categoryFieldKey.currentState?.validate();
  }

  double? _parseAmount() {
    return double.tryParse(_amountController.text.trim());
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState!.validate() &&
        (_target != _BudgetTarget.category ||
            (_categoryFieldKey.currentState?.validate() ?? false));
    if (!isValid) return;

    final amount = _parseAmount();
    if (amount == null) return;

    setState(() => _isLoading = true);

    if (widget.isEditing) {
      final budget = widget.budget!
        ..amountLimit = amount
        ..categoryId =
            _target == _BudgetTarget.total ? null : _selectedCategory!.cId;
      context.read<BudgetBloc>().add(UpdateBudget(budget));
    } else {
      final budget = BudgetModel(
        bId: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId:
            _target == _BudgetTarget.total ? null : _selectedCategory!.cId,
        amountLimit: amount,
      );
      context.read<BudgetBloc>().add(AddBudget(budget));
    }

    if (!mounted) return;

    await context.read<BudgetBloc>().stream.firstWhere(
          (s) => s is BudgetSuccess || s is BudgetError,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final state = context.read<BudgetBloc>().state;
    if (state is BudgetSuccess) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MAppBar(
        showBackArrow: true,
        title: Text(
          widget.isEditing ? 'Edit Budget' : 'Add Budget',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(MSizes.defaultSpace),
          children: [
            Text('Budget for', style: _sectionLabelStyle(context)),
            const SizedBox(height: MSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _TargetChip(
                    label: 'Total expenses',
                    selected: _target == _BudgetTarget.total,
                    onTap: () => setState(() {
                      _target = _BudgetTarget.total;
                      _selectedCategory = null;
                      _categoryFieldKey.currentState?.validate();
                    }),
                  ),
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: _TargetChip(
                    label: 'Category',
                    selected: _target == _BudgetTarget.category,
                    onTap: () => setState(() => _target = _BudgetTarget.category),
                  ),
                ),
              ],
            ),
            if (_target == _BudgetTarget.category) ...[
              const SizedBox(height: MSizes.md),
              FormField<void>(
                key: _categoryFieldKey,
                validator: (_) {
                  if (_selectedCategory == null) {
                    return 'Choose a category for this budget';
                  }
                  return null;
                },
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MTextFormField(
                        label: 'Category',
                        hintText: _selectedCategory?.title ?? 'Select category',
                        prefixIcon: Icons.category_outlined,
                        readOnly: true,
                        suffixIcon: Icons.chevron_right,
                        onTap: _openCategoryPicker,
                      ),
                      if (field.hasError) ...[
                        const SizedBox(height: MSizes.xs),
                        Padding(
                          padding: const EdgeInsets.only(left: MSizes.sm),
                          child: Text(
                            field.errorText!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: MSizes.md),
            MTextFormField(
              controller: _amountController,
              label: 'Monthly limit',
              hintText: 'e.g. 8000',
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a budget limit greater than zero';
                }
                return null;
              },
            ),
          const SizedBox(height: MSizes.sm),
          Text(
            'Tracks spending for the current calendar month.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: MSizes.xl),
          MButton(
            btnTitle: widget.isEditing ? 'Save budget' : 'Add budget',
            width: double.infinity,
            height: 50,
            onTap: _isLoading ? null : _save,
          ),
        ],
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
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
