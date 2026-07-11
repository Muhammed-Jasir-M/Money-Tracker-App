import 'package:money_tracker_app/data/datasources/budget_local_datasource.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';

class BudgetRepository {
  BudgetRepository({
    required BudgetLocalDatasource datasource,
  }) : _datasource = datasource;

  final BudgetLocalDatasource _datasource;

  Future<List<BudgetModel>> getAll() async {
    return _datasource.getAll();
  }

  Future<void> add(BudgetModel budget) async {
    await _datasource.add(budget);
  }

  Future<void> update(BudgetModel budget) async {
    await _datasource.update(budget);
  }

  Future<void> delete(BudgetModel budget) async {
    await _datasource.delete(budget);
  }

  Future<void> clearAll() async {
    await _datasource.clearAll();
  }

  Future<void> deleteByCategoryId(String categoryId) async {
    await _datasource.deleteByCategoryId(categoryId);
  }

  bool hasBudgetForCategory(String? categoryId, {String? excludeBudgetId}) {
    return _datasource.getAll().any(
          (budget) =>
              budget.categoryId == categoryId &&
              (excludeBudgetId == null || budget.bId != excludeBudgetId),
        );
  }
}
