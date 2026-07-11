import 'package:hive_flutter/hive_flutter.dart';

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

  CategoryModel({
    required this.cId,
    required this.title,
    required this.iconIndex,
    required this.color,
  });

  static CategoryModel empty() {
    return CategoryModel(
      cId: '',
      title: '',
      iconIndex: 0,
      color: 0,
    );
  }
}
