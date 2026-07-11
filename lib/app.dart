import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/app_branding.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/security/lock_gate.dart';
import 'package:money_tracker_app/core/theme/theme.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/features/shell/view/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state is SettingsLoaded ? state.settings : null;
        final themeMode = settings?.themeMode ?? ThemeMode.system;
        final currencySymbol = settings?.currencySymbol ?? '₹';

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppBranding.displayName,
          themeMode: themeMode,
          theme: MAppTheme.lightTheme,
          darkTheme: MAppTheme.darkTheme,
          builder: (context, child) {
            return CurrencyScope(
              symbol: currencySymbol,
              child: LockGate(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const MainScreen(),
        );
      },
    );
  }
}
