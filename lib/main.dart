import 'package:flutter/material.dart';
import 'qibla_screen.dart';

void main() {
  runApp(const QiblatApp());
}

class QiblatApp extends StatelessWidget {
  const QiblatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qiblat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          surface: Color(0xFF1A1A2E),
        ),
      ),
      home: const QiblaScreen(),
    );
  }
}
