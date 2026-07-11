import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';

class TransactionLocalDatasource {
  TransactionLocalDatasource({required Box<TransactionModel> box}) : _box = box;

  final Box<TransactionModel> _box;

  List<TransactionModel> getAll() {
    return _box.values.toList();
  }

  Future<void> add(TransactionModel transaction) async {
    await _box.add(transaction);
  }

  Future<void> update(TransactionModel transaction) async {
    await _box.put(transaction.key, transaction);
  }

  Future<void> delete(TransactionModel transaction) async {
    await _box.delete(transaction.key);
  }

  Future<void> syncCategory(CategoryModel category) async {
    for (final transaction in _box.values) {
      if (transaction.category.cId == category.cId) {
        transaction.category.title = category.title;
        transaction.category.iconIndex = category.iconIndex;
        transaction.category.color = category.color;
        transaction.category.type = category.type;
        await _box.put(transaction.key, transaction);
      }
    }
  }

  bool hasTransactionsForCategory(String categoryId) {
    return _box.values.any((t) => t.category.cId == categoryId);
  }
}
