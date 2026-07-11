part of 'budget_bloc.dart';

abstract class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  BudgetLoaded(this.budgets);

  final List<BudgetModel> budgets;

  @override
  List<Object?> get props => [budgets];
}

class BudgetSuccess extends BudgetState {
  BudgetSuccess({
    required this.budgets,
    required this.message,
  });

  final List<BudgetModel> budgets;
  final String message;

  @override
  List<Object?> get props => [budgets, message];
}

class BudgetError extends BudgetState {
  BudgetError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
