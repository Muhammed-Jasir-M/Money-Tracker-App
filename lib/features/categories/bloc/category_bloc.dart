import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final Box<CategoryModel> categoryBox;

  CategoryBloc({required this.categoryBox}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);

    add(LoadCategories());
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = categoryBox.values.toList();
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
      await categoryBox.add(event.category);
      final categories = categoryBox.values.toList();
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
      final key = event.category.key;
      await categoryBox.put(key, event.category);

      final categories = categoryBox.values.toList();
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
    emit(CategoryLoading());
    try {
      final key = event.category.key;
      await categoryBox.delete(key);
      final categories = categoryBox.values.toList();
      emit(CategorySuccess(
        categories: categories,
        message: 'Category deleted successfully',
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
