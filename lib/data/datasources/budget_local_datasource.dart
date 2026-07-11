import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';

class BudgetLocalDatasource {
  BudgetLocalDatasource({required Box<BudgetModel> box}) : _box = box;

  final Box<BudgetModel> _box;

  List<BudgetModel> getAll() {
    return _box.values.toList();
  }

  Future<void> add(BudgetModel budget) async {
    await _box.add(budget);
  }

  Future<void> update(BudgetModel budget) async {
    await _box.put(budget.key, budget);
  }

  Future<void> delete(BudgetModel budget) async {
    await _box.delete(budget.key);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> deleteByCategoryId(String categoryId) async {
    final toDelete =
        _box.values.where((b) => b.categoryId == categoryId).toList();
    for (final budget in toDelete) {
      await _box.delete(budget.key);
    }
  }
}
