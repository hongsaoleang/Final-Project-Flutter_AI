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
    return MaterialApp(
      title: 'MyAI Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}
