import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:money_tracker_app/core/storage/receipt_storage.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required TransactionRepository repository,
    ReceiptStorage? receiptStorage,
  })  : _repository = repository,
        _receiptStorage = receiptStorage ?? ReceiptStorage(),
        super(TransactionInitial()) {
    on<LoadTransaction>(_onLoadTransaction);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);

    add(LoadTransaction());
  }

  final TransactionRepository _repository;
  final ReceiptStorage _receiptStorage;

  TransactionRepository get repository => _repository;

  Future<void> _onLoadTransaction(
    LoadTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getAll();
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
      await _repository.add(event.transaction);
      final transactions = await _repository.getAll();
      emit(TransactionSuccess(
        transactions: transactions,
        message: 'Transaction added successfully',
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
      await _repository.update(event.transaction);
      final transactions = await _repository.getAll();
      emit(TransactionSuccess(
        transactions: transactions,
        message: 'Transaction updated successfully',
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
      await _receiptStorage.deleteForTransaction(event.transaction.tId);
      await _repository.delete(event.transaction);
      final transactions = await _repository.getAll();
      emit(TransactionSuccess(
        transactions: transactions,
        message: 'Transaction deleted successfully',
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
