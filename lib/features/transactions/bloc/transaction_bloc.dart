import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Box<TransactionModel> transactionBox;

  TransactionBloc({required this.transactionBox})
      : super(TransactionInitial()) {
    on<LoadTransaction>(_onLoadTransaction);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);

    add(LoadTransaction());
  }

  Future<void> _onLoadTransaction(
    LoadTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = transactionBox.values.toList();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await transactionBox.add(event.transaction);
      final transactions = transactionBox.values.toList();
      emit(TransactionSuccess(
        transactions: transactions,
        message: "Transaction added successfully",
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final key = event.transaction.key;
      await transactionBox.put(key, event.transaction);
      final transactions = transactionBox.values.toList();
      emit(TransactionSuccess(
        transactions: transactions,
        message: "Transaction updated successfully",
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final key = event.transaction.key;
      await transactionBox.delete(key);
      final transactions = transactionBox.values.toList();
      emit(TransactionSuccess(
        transactions: transactions,
        message: "Transaction deleted successfully",
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
