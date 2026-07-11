import 'package:hive_flutter/hive_flutter.dart';
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
}
