import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/app.dart';
import 'package:money_tracker_app/core/bloc/simple_bloc_observer.dart';
import 'package:money_tracker_app/data/datasources/category_local_datasource.dart';
import 'package:money_tracker_app/data/datasources/transaction_local_datasource.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/data/repositories/category_repository.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';

Future<void> main() async {
  // Add Widgets Binding
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  final transactionBox = await Hive.openBox<TransactionModel>('transactions');
  final categoryBox = await Hive.openBox<CategoryModel>('categories');

  final transactionRepository = TransactionRepository(
    datasource: TransactionLocalDatasource(box: transactionBox),
  );
  final categoryRepository = CategoryRepository(
    datasource: CategoryLocalDatasource(box: categoryBox),
  );

  Bloc.observer = SimpleBlocObserver();

  // Run the MyApp
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionBloc(repository: transactionRepository),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(repository: categoryRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
