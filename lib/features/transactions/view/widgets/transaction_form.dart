import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/widgets/category_picker_sheet.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';

class MTransactionForm extends StatefulWidget {
  const MTransactionForm({
    super.key,
    this.transaction,
    required this.isEditing,
  });

  final TransactionModel? transaction;
  final bool isEditing;

  @override
  State<MTransactionForm> createState() => _MTransactionFormState();
}

class _MTransactionFormState extends State<MTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _transactionType = TransactionType.income;
  CategoryModel _selectedCategory = CategoryModel.empty();
  DateTime _selectedDateTime = DateTime.now();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());

    if (widget.isEditing && widget.transaction != null) {
      final transaction = widget.transaction!;

      _selectedCategory = transaction.category;
      _categoryController.text = transaction.category.title;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note;
      _selectedDateTime = transaction.dateTime;
      _transactionType = transaction.type;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openCategoryPicker() async {
    final bloc = context.read<CategoryBloc>();
    final categories = await ensureCategoriesLoaded(bloc);
    if (!mounted) return;

    final result = await showCategoryPickerSheet(
      context: context,
      categories: categories,
      selectedCategory: _selectedCategory == CategoryModel.empty()
          ? null
          : _selectedCategory,
      filterType: _transactionType,
    );

    if (!mounted) return;

    if (result is CategoryModel) {
      setState(() {
        _selectedCategory = result;
        _categoryController.text = result.title;
      });
    } else if (result == null) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  void _setTransactionType(TransactionType type) {
    setState(() {
      _transactionType = type;
      if (_selectedCategory != CategoryModel.empty() &&
          _selectedCategory.type != type) {
        _selectedCategory = CategoryModel.empty();
        _categoryController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final isEditing = widget.isEditing;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoading) {
          setState(() => isLoading = true);
        } else if (state is TransactionSuccess) {
          setState(() => isLoading = false);
          Navigator.pop(context);
        } else if (state is TransactionError) {
          setState(() => isLoading = false);
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: 'Error',
            bgColor: Colors.red,
            icon: Icons.error,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(MSizes.defaultSpace),
        child: Form(
          key: _formKey,
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
                    child: _TypeChip(
                      label: 'Income',
                      isSelected: _transactionType == TransactionType.income,
                      color: Colors.green,
                      onTap: () => _setTransactionType(TransactionType.income),
                    ),
                  ),
                  const SizedBox(width: MSizes.sm),
                  Expanded(
                    child: _TypeChip(
                      label: 'Expense',
                      isSelected: _transactionType == TransactionType.expense,
                      color: Colors.red,
                      onTap: () => _setTransactionType(TransactionType.expense),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              Text(
                'Amount',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: MSizes.formLabelSize,
                    ),
              ),
              const SizedBox(height: MSizes.sm),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: const Icon(
                    FontAwesomeIcons.indianRupeeSign,
                    size: 20,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? MColors.dark : MColors.light,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MTextFormField(
                controller: _categoryController,
                label: 'Category',
                hintText: 'Tap to select',
                readOnly: true,
                prefixIcon: _selectedCategory != CategoryModel.empty()
                    ? categoryIcons[_selectedCategory.iconIndex]
                    : FontAwesomeIcons.list,
                suffixIcon: Icons.chevron_right,
                onTap: _openCategoryPicker,
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MTextFormField(
                label: 'Date',
                hintText: DateFormat('dd/MM/yyyy').format(_selectedDateTime),
                prefixIcon: FontAwesomeIcons.calendar,
                readOnly: true,
                onTap: () async {
                  final pickerDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (pickerDate != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        pickerDate.year,
                        pickerDate.month,
                        pickerDate.day,
                        _selectedDateTime.hour,
                        _selectedDateTime.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MTextFormField(
                label: 'Time',
                hintText: DateFormat('hh:mm a').format(_selectedDateTime),
                prefixIcon: FontAwesomeIcons.clock,
                readOnly: true,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        _selectedDateTime.year,
                        _selectedDateTime.month,
                        _selectedDateTime.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MTextFormField(
                controller: _noteController,
                label: 'Note',
                hintText: 'Optional',
                prefixIcon: FontAwesomeIcons.noteSticky,
              ),
              const SizedBox(height: MSizes.spaceBtwSections),
              Center(
                child: MButton(
                  btnTitle: isLoading
                      ? isEditing
                          ? 'Updating...'
                          : 'Creating...'
                      : isEditing
                          ? 'Update Transaction'
                          : 'Create Transaction',
                  width: double.infinity,
                  height: 50,
                  onTap: isLoading ? null : _validateAndSubmitTask,
                ),
              ),
              const SizedBox(height: MSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndSubmitTask() {
    if (_selectedCategory == CategoryModel.empty()) {
      MHelperFunctions.showSnackBar(
        message: 'Please select a category',
        context: context,
        title: 'Error',
        bgColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      MHelperFunctions.showSnackBar(
        message: 'Please enter a valid amount',
        context: context,
        title: 'Error',
        bgColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    final bloc = context.read<TransactionBloc>();

    if (widget.isEditing && widget.transaction != null) {
      widget.transaction!
        ..category = _selectedCategory
        ..amount = amount
        ..dateTime = _selectedDateTime
        ..type = _transactionType
        ..note = _noteController.text.trim();
      bloc.add(UpdateTransaction(widget.transaction!));
    } else {
      bloc.add(
        AddTransaction(
          TransactionModel(
            tId: DateTime.now().millisecondsSinceEpoch.toString(),
            category: _selectedCategory,
            amount: amount,
            dateTime: _selectedDateTime,
            type: _transactionType,
            note: _noteController.text.trim(),
          ),
        ),
      );
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final baseColor = isDark ? MColors.dark : MColors.light;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : baseColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? color : null,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
