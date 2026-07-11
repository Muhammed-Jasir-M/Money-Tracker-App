import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_tracker_app/core/constants/category_colors.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key, this.category, this.initialType});

  final CategoryModel? category;
  final TransactionType? initialType;

  bool get isEditing => category != null;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  int iconSelected = 0;
  Color selectedColor = categoryColorSwatches.first;
  TransactionType selectedType = TransactionType.expense;

  bool isCategoryLoading = false;

  final titleController = TextEditingController();

  TextStyle? _sectionLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: MSizes.formLabelSize,
        );
  }

  @override
  void dispose() {
    titleController.removeListener(_onTitleChanged);
    titleController.dispose();
    super.dispose();
  }

  void _onTitleChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    titleController.addListener(_onTitleChanged);

    if (widget.isEditing) {
      final category = widget.category!;
      titleController.text = category.title;
      iconSelected = category.iconIndex;
      selectedColor = Color(category.color);
      selectedType = category.type;
    } else if (widget.initialType != null) {
      selectedType = widget.initialType!;
    }
  }

  Future<void> _openCustomColorPicker() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Center(child: Text('Custom color')),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (value) {
                setState(() => selectedColor = value);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (titleController.text.trim().isEmpty) {
      MHelperFunctions.showSnackBar(
        message: 'Please enter a category name',
        context: context,
        title: 'Error',
        bgColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    setState(() => isCategoryLoading = true);

    if (widget.isEditing) {
      final category = widget.category!
        ..title = titleController.text.trim()
        ..iconIndex = iconSelected
        ..color = selectedColor.toARGB32()
        ..type = selectedType;

      context.read<CategoryBloc>().add(UpdateCategory(category));
      return;
    }

    context.read<CategoryBloc>().add(
          AddCategory(
            CategoryModel(
              title: titleController.text.trim(),
              iconIndex: iconSelected,
              color: selectedColor.toARGB32(),
              type: selectedType,
              cId: DateTime.now().millisecondsSinceEpoch.toString(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final previewTitle = titleController.text.trim().isEmpty
        ? 'Category name'
        : titleController.text.trim();
    final isDark = MHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: MAppBar(
        title: Text(
          widget.isEditing ? 'Edit Category' : 'Add Category',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: _sectionLabelStyle(context)),
            const SizedBox(height: MSizes.sm),
            MTransactionTile(
              icon: categoryIcons[iconSelected],
              title: previewTitle,
              showPriceDate: false,
              iconBgColor: selectedColor,
              onTap: null,
            ),
            const SizedBox(height: MSizes.spaceBtwSections),
            MTextFormField(
              controller: titleController,
              label: 'Name',
              hintText: 'e.g. Food, Travel',
              prefixIcon: Icons.category_rounded,
            ),
            const SizedBox(height: MSizes.spaceBtwItems),
            Text('Type', style: _sectionLabelStyle(context)),
            const SizedBox(height: MSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _TypeOption(
                    label: 'Income',
                    isSelected: selectedType == TransactionType.income,
                    color: Colors.green,
                    baseColor: isDark ? MColors.dark : MColors.light,
                    onTap: () => setState(
                      () => selectedType = TransactionType.income,
                    ),
                  ),
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: _TypeOption(
                    label: 'Expense',
                    isSelected: selectedType == TransactionType.expense,
                    color: Colors.red,
                    baseColor: isDark ? MColors.dark : MColors.light,
                    onTap: () => setState(
                      () => selectedType = TransactionType.expense,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MSizes.spaceBtwItems),
            Text('Icon', style: _sectionLabelStyle(context)),
            const SizedBox(height: MSizes.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: MSizes.sm,
                crossAxisSpacing: MSizes.sm,
              ),
              itemCount: categoryIcons.length,
              itemBuilder: (context, index) {
                final isSelected = iconSelected == index;

                return GestureDetector(
                  onTap: () => setState(() => iconSelected = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        categoryIcons[index],
                        size: 20,
                        color: isSelected
                            ? selectedColor
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: MSizes.spaceBtwItems),
            Text('Color', style: _sectionLabelStyle(context)),
            const SizedBox(height: MSizes.sm),
            Wrap(
              spacing: MSizes.sm,
              runSpacing: MSizes.sm,
              children: [
                ...categoryColorSwatches.map((color) {
                  final isSelected =
                      selectedColor.toARGB32() == color.toARGB32();

                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
                GestureDetector(
                  onTap: _openCustomColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.green,
                          Colors.blue,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MSizes.spaceBtwSections),
            BlocListener<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategorySuccess) {
                  if (widget.isEditing) {
                    context.read<TransactionBloc>().add(LoadTransaction());
                  }
                  MHelperFunctions.showSnackBar(
                    message: state.message,
                    context: context,
                    title: 'Success',
                    bgColor: Colors.green,
                    icon: Icons.check_circle,
                  );
                  Navigator.pop(context);
                } else if (state is CategoryError) {
                  setState(() => isCategoryLoading = false);
                }
              },
              child: MButton(
                onTap: isCategoryLoading ? null : _submit,
                width: double.infinity,
                height: 50,
                btnTitle: isCategoryLoading
                    ? widget.isEditing
                        ? 'Updating...'
                        : 'Adding...'
                    : widget.isEditing
                        ? 'Update category'
                        : 'Add category',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.baseColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final Color baseColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
