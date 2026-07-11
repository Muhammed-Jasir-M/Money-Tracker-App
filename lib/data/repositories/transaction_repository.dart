import 'package:money_tracker_app/data/datasources/transaction_local_datasource.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';

class TransactionRepository {
  TransactionRepository({
    required TransactionLocalDatasource datasource,
  }) : _datasource = datasource;

  final TransactionLocalDatasource _datasource;

  Future<List<TransactionModel>> getAll() async {
    return _datasource.getAll();
  }

  Future<void> add(TransactionModel transaction) async {
    await _datasource.add(transaction);
  }

  Future<void> update(TransactionModel transaction) async {
    await _datasource.update(transaction);
  }

  Future<void> delete(TransactionModel transaction) async {
    await _datasource.delete(transaction);
  }
}
