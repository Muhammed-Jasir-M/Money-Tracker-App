import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/app.dart';
import 'package:money_tracker_app/core/bloc/simple_bloc_observer.dart';
import 'package:money_tracker_app/core/storage/hive_box_helper.dart';
import 'package:money_tracker_app/data/datasources/budget_local_datasource.dart';
import 'package:money_tracker_app/data/datasources/category_local_datasource.dart';
import 'package:money_tracker_app/data/datasources/settings_local_datasource.dart';
import 'package:money_tracker_app/data/datasources/transaction_local_datasource.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/data/repositories/budget_repository.dart';
import 'package:money_tracker_app/data/repositories/category_repository.dart';
import 'package:money_tracker_app/data/repositories/settings_repository.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';
import 'package:money_tracker_app/data/seed/default_categories.dart';
import 'package:money_tracker_app/features/budgets/bloc/budget_bloc.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  final transactionBox =
      await openBoxSafely<TransactionModel>('transactions');
  final categoryBox = await openBoxSafely<CategoryModel>('categories');
  final budgetBox = await openBoxSafely<BudgetModel>('budgets');
  final settingsBox = await openUntypedBoxSafely('app_settings');

  final transactionRepository = TransactionRepository(
    datasource: TransactionLocalDatasource(box: transactionBox),
  );
  final categoryRepository = CategoryRepository(
    datasource: CategoryLocalDatasource(box: categoryBox),
  );
  final budgetRepository = BudgetRepository(
    datasource: BudgetLocalDatasource(box: budgetBox),
  );
  final settingsRepository = SettingsRepository(
    datasource: SettingsLocalDatasource(box: settingsBox),
  );
  final initialSettings = settingsRepository.getSettingsSync();

  await GoogleFonts.pendingFonts([
    GoogleFonts.poppins(),
    GoogleFonts.lato(),
  ]);

  await DefaultCategoriesSeeder.seedIfEmpty(
    categoryRepository: categoryRepository,
  );

  Bloc.observer = SimpleBlocObserver();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TransactionBloc(repository: transactionRepository),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(
            repository: categoryRepository,
            transactionRepository: transactionRepository,
            budgetRepository: budgetRepository,
          ),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(repository: budgetRepository),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            repository: settingsRepository,
            initialSettings: initialSettings,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
