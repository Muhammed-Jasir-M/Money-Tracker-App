import 'package:money_tracker_app/data/datasources/category_local_datasource.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';

class CategoryRepository {
  CategoryRepository({
    required CategoryLocalDatasource datasource,
  }) : _datasource = datasource;

  final CategoryLocalDatasource _datasource;

  Future<List<CategoryModel>> getAll() async {
    return _datasource.getAll();
  }

  Future<void> add(CategoryModel category) async {
    await _datasource.add(category);
  }

  Future<void> update(CategoryModel category) async {
    await _datasource.update(category);
  }

  Future<void> delete(CategoryModel category) async {
    await _datasource.delete(category);
  }

  Future<void> clearAll() async {
    await _datasource.clearAll();
  }
}
