import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PesaBookApp());
}

class PesaBookApp extends StatelessWidget {
  const PesaBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PesaBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}