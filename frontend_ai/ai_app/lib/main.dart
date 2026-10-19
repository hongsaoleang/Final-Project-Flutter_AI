import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/main_layout.dart';

void main() {
  runApp(const DerLengApp());
}

class DerLengApp extends StatelessWidget {
  const DerLengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'DER LENG',
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
