import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/theme/theme.dart';
import 'package:money_tracker_app/features/shell/view/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Manager App',
      themeMode: ThemeMode.system,
      theme: MAppTheme.lightTheme,
      darkTheme: MAppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
