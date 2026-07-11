import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/theme/theme.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/features/shell/view/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final themeMode = state is SettingsLoaded
            ? state.settings.themeMode
            : ThemeMode.system;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Money Manager App',
          themeMode: themeMode,
          theme: MAppTheme.lightTheme,
          darkTheme: MAppTheme.darkTheme,
          home: const MainScreen(),
        );
      },
    );
  }
}
