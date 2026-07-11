import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';
import 'package:money_tracker_app/data/repositories/budget_repository.dart';

part 'budget_event.dart';
part 'budget_state.dart';

List<BudgetModel>? budgetsFromState(BudgetState state) {
  return switch (state) {
    BudgetLoaded(:final budgets) => budgets,
    BudgetSuccess(:final budgets) => budgets,
    _ => null,
  };
}

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc({
    required BudgetRepository repository,
  })  : _repository = repository,
        super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);

    add(LoadBudgets());
  }

  final BudgetRepository _repository;

  BudgetRepository get repository => _repository;

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getAll();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError('Failed to load budgets: ${e.toString()}'));
    }
  }

  Future<void> _onAddBudget(
    AddBudget event,
    Emitter<BudgetState> emit,
  ) async {
    if (_repository.hasBudgetForCategory(event.budget.categoryId)) {
      emit(BudgetError(
        event.budget.categoryId == null
            ? 'A total expense budget already exists'
            : 'This category already has a budget',
      ));
      final budgets = await _repository.getAll();
      emit(BudgetLoaded(budgets));
      return;
    }

    emit(BudgetLoading());
    try {
      await _repository.add(event.budget);
      final budgets = await _repository.getAll();
      emit(BudgetSuccess(
        budgets: budgets,
        message: 'Budget added successfully',
      ));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    if (_repository.hasBudgetForCategory(
      event.budget.categoryId,
      excludeBudgetId: event.budget.bId,
    )) {
      emit(BudgetError(
        event.budget.categoryId == null
            ? 'A total expense budget already exists'
            : 'This category already has a budget',
      ));
      final budgets = await _repository.getAll();
      emit(BudgetLoaded(budgets));
      return;
    }

    emit(BudgetLoading());
    try {
      await _repository.update(event.budget);
      final budgets = await _repository.getAll();
      emit(BudgetSuccess(
        budgets: budgets,
        message: 'Budget updated successfully',
      ));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      await _repository.delete(event.budget);
      final budgets = await _repository.getAll();
      emit(BudgetSuccess(
        budgets: budgets,
        message: 'Budget deleted successfully',
      ));
    } catch (e) {
      emit(BudgetError(e.toString()));
      final budgets = await _repository.getAll();
      emit(BudgetLoaded(budgets));
    }
  }
}
