import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  bool isExpanded = false;
  int iconSelected = 0;
  Color selectedColor = Colors.blue;

  bool isCategoryLoading = false;

  final titleController = TextEditingController();
  final iconController = TextEditingController();
  final colorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Scaffold(
      // Appbar
      appBar: MAppBar(
        title: Text(
          'Add Category',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        showBackArrow: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(MSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title TextField
            MTextFormField(
              controller: titleController,
              hintText: 'Title',
              prefixIcon: Icons.category_rounded,
            ),

            const SizedBox(height: MSizes.spaceBtwItems),

            /// Icon TextField
            MTextFormField(
              hintText: 'Icon',
              controller: iconController,
              readOnly: true,
              onIconPressed: () => setState(() => isExpanded = !isExpanded),
              onTap: () => setState(() => isExpanded = !isExpanded),
              isOpened: isExpanded,
              prefixIcon: categoryIcons.isNotEmpty
                  ? categoryIcons[iconSelected]
                  : FontAwesomeIcons.icons,
              suffixIcon: isExpanded
                  ? CupertinoIcons.chevron_up
                  : CupertinoIcons.chevron_down,
            ),

            /// If Icon TextField is Opened it will open list of icons to select
            /// Else Empty Container
            if (isExpanded)
              Container(
                width: MHelperFunctions.screenWidth(context),
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? MColors.dark : MColors.light,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                    ),
                    itemCount: categoryIcons.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            iconSelected = index;
                            Timer(
                              Duration(seconds: 1),
                              () => setState(() => isExpanded = false),
                            );
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color: categoryIcons[iconSelected] ==
                                      categoryIcons[index]
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: FaIcon(
                              categoryIcons[index],
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: MSizes.spaceBtwItems),

            /// Color TextField
            MTextFormField(
              hintText: 'Color',
              controller: colorController,
              readOnly: true,
              prefixIcon: Icons.color_lens_rounded,
              suffixWidget: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
              onTap: () async {
                return showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Center(child: const Text('Pick a color')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ColorPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (value) {
                              setState(() => selectedColor = value);
                            },
                          ),

                          /// Save Button
                          MButton(
                            onTap: () => Navigator.pop(ctx),
                            btnTitle: "Save",
                            width: double.infinity,
                            height: 50,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: MSizes.spaceBtwSections),

            /// Save Button
            BlocListener<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategorySuccess) {
                  MHelperFunctions.showSnackBar(
                    message: state.message,
                    context: context,
                    title: "Success",
                    bgColor: Colors.green,
                    icon: Icons.check_circle,
                  );
                  Navigator.pop(context);
                } else if (state is CategoryError) {
                  setState(() => isCategoryLoading = false);
                }
              },
              child: Center(
                child: MButton(
                  onTap: () {
                    if (titleController.text.isEmpty) {
                      MHelperFunctions.showSnackBar(
                        message: 'Please fill all the fields',
                        context: context,
                        title: "Error",
                        bgColor: Colors.red,
                        icon: Icons.error,
                      );
                    } else {
                      setState(() => isCategoryLoading = false);
                    }

                    BlocProvider.of<CategoryBloc>(context).add(
                      AddCategory(
                        CategoryModel(
                          title: titleController.text,
                          iconIndex: iconSelected,
                          color: selectedColor.value,
                          cId: DateTime.now().millisecondsSinceEpoch.toString(),
                        ),
                      ),
                    );
                  },
                  width: double.infinity,
                  height: 50,
                  btnTitle: isCategoryLoading ? 'Adding...' : 'Add category',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
