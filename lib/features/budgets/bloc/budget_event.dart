part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class AddBudget extends BudgetEvent {
  AddBudget(this.budget);

  final BudgetModel budget;

  @override
  List<Object?> get props => [budget];
}

class UpdateBudget extends BudgetEvent {
  UpdateBudget(this.budget);

  final BudgetModel budget;

  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  DeleteBudget(this.budget);

  final BudgetModel budget;

  @override
  List<Object?> get props => [budget];
}
