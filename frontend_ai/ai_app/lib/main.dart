import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/main_layout.dart';

void main() {
  runApp(const MyAIApp());
}

class MyAIApp extends StatelessWidget {
  const MyAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'MyAI Platform',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const MainLayout(),
        );
      },
    );
  }
}
