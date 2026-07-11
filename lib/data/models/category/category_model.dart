import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String cId;

  @HiveField(1)
  String title;

  @HiveField(2)
  int iconIndex;

  @HiveField(3)
  int color;

  @HiveField(4)
  TransactionType type;

  CategoryModel({
    required this.cId,
    required this.title,
    required this.iconIndex,
    required this.color,
    this.type = TransactionType.expense,
  });

  static CategoryModel empty() {
    return CategoryModel(
      cId: '',
      title: '',
      iconIndex: 0,
      color: 0,
      type: TransactionType.expense,
    );
  }
}
