import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';

class CategoryLocalDatasource {
  CategoryLocalDatasource({required Box<CategoryModel> box}) : _box = box;

  final Box<CategoryModel> _box;

  List<CategoryModel> getAll() {
    return _box.values.toList();
  }

  Future<void> add(CategoryModel category) async {
    await _box.add(category);
  }

  Future<void> update(CategoryModel category) async {
    await _box.put(category.key, category);
  }

  Future<void> delete(CategoryModel category) async {
    await _box.delete(category.key);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
