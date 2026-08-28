import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/shop_setup_screen.dart';
import 'services/storage_service.dart';

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
      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkShopSetup();
  }

  Future<void> _checkShopSetup() async {
    final shop = await StorageService.loadShop();

    if (!mounted) return;

    if (shop == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShopSetupScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}