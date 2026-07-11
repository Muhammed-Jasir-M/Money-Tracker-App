import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/repositories/category_repository.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required CategoryRepository repository,
    required TransactionRepository transactionRepository,
  })  : _repository = repository,
        _transactionRepository = transactionRepository,
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);

    add(LoadCategories());
  }

  final CategoryRepository _repository;
  final TransactionRepository _transactionRepository;

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAll();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await _repository.add(event.category);
      final categories = await _repository.getAll();
      emit(CategorySuccess(
        categories: categories,
        message: 'Category added successfully',
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await _repository.update(event.category);
      await _transactionRepository.syncCategory(event.category);
      final categories = await _repository.getAll();
      emit(CategorySuccess(
        categories: categories,
        message: 'Category updated successfully',
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (_transactionRepository.hasTransactionsForCategory(event.category.cId)) {
        emit(CategoryError(
          'Cannot delete a category that has transactions',
        ));
        final categories = await _repository.getAll();
        emit(CategoryLoaded(categories));
        return;
      }

      emit(CategoryLoading());
      await _repository.delete(event.category);
      final categories = await _repository.getAll();
      emit(CategorySuccess(
        categories: categories,
        message: 'Category deleted successfully',
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
      final categories = await _repository.getAll();
      emit(CategoryLoaded(categories));
    }
  }
}
