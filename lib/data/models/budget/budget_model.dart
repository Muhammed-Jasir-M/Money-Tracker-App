import 'package:hive_flutter/hive_flutter.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String bId;

  /// Null means total monthly expense budget.
  @HiveField(1)
  String? categoryId;

  @HiveField(2)
  double amountLimit;

  BudgetModel({
    required this.bId,
    this.categoryId,
    required this.amountLimit,
  });
}
