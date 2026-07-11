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
import 'package:money_tracker_app/features/categories/view/add_category_screen.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/radio_button.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

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

  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _transactionType = TransactionType.income;
  CategoryModel _selectedCategory = CategoryModel.empty();
  DateTime _selectedDateTime = DateTime.now();

  bool isLoading = false;
  bool isExpanded = false;

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
    _categoryController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
              MTextFormField(
                controller: _categoryController,
                hintText: 'Category',
                readOnly: true,
                prefixIcon: _selectedCategory != CategoryModel.empty()
                    ? categoryIcons[_selectedCategory.iconIndex]
                    : FontAwesomeIcons.list,
                isOpened: isExpanded,
                suffixIcon: FontAwesomeIcons.plus,
                onTap: () => setState(() => isExpanded = !isExpanded),
                onIconPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCategoryScreen(),
                    ),
                  );

                  if (mounted) {
                    context.read<CategoryBloc>().add(LoadCategories());
                  }
                },
              ),
              if (isExpanded)
                Container(
                  width: MHelperFunctions.screenWidth(context),
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? MColors.dark : MColors.light,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is CategoryLoaded) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: state.categories.length,
                            itemBuilder: (context, index) {
                              final reversedCategories =
                                  state.categories.reversed.toList();
                              final category = reversedCategories[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                    _categoryController.text = category.title;
                                    isExpanded = false;
                                  });
                                },
                                child: MTransactionTile(
                                  icon: categoryIcons[category.iconIndex],
                                  title: category.title,
                                  showPriceDate: false,
                                  iconBgColor: Color(category.color),
                                ),
                              );
                            },
                          );
                        } else if (state is CategoryError) {
                          return Center(
                            child: Text(
                              'Error: ${state.message}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No Categories Found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MTextFormField(
                controller: _amountController,
                hintText: 'Amount',
                prefixIcon: FontAwesomeIcons.indianRupeeSign,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              Row(
                children: [
                  MRadioButton(
                    title: TransactionType.income.name,
                    value: TransactionType.income,
                    transactionType: _transactionType,
                    onChanged: (value) =>
                        setState(() => _transactionType = value!),
                  ),
                  const SizedBox(width: MSizes.sm),
                  MRadioButton(
                    title: TransactionType.expense.name,
                    value: TransactionType.expense,
                    transactionType: _transactionType,
                    onChanged: (value) =>
                        setState(() => _transactionType = value!),
                  ),
                ],
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MTextFormField(
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
                hintText: 'Note (optional)',
                prefixIcon: FontAwesomeIcons.noteSticky,
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              Center(
                child: MButton(
                  btnTitle: isLoading
                      ? isEditing
                          ? 'Updating...'
                          : 'Creating...'
                      : isEditing
                          ? 'Update Transaction'
                          : 'Create Transaction',
                  width: 180,
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
