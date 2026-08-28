import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _shopNameController = TextEditingController();
  final _paymentNumberController = TextEditingController();

  String _paymentMethod = 'Till Number';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final shop = await StorageService.loadShop();

    if (!mounted) return;

    if (shop != null) {
      _shopNameController.text = shop.name;
      _paymentNumberController.text = shop.paymentNumber;
      _paymentMethod = shop.paymentMethod;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _paymentNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (_shopNameController.text.trim().isEmpty ||
        _paymentNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    final shop = Shop(
      name: _shopNameController.text.trim(),
      paymentMethod: _paymentMethod,
      paymentNumber: _paymentNumberController.text.trim(),
    );

    await StorageService.saveShop(shop);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shop details saved.'),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shop Setup'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final hasExistingShop =
        _shopNameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hasExistingShop ? 'Shop Settings' : 'Shop Setup',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Till Number',
                  child: Text('Till Number'),
                ),
                DropdownMenuItem(
                  value: 'PayBill',
                  child: Text('PayBill'),
                ),
                DropdownMenuItem(
                  value: 'Phone Number',
                  child: Text('Phone Number'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _paymentMethod = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _paymentNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveShop,
                child: Text(
                  hasExistingShop
                      ? 'Save Changes'
                      : 'Save Shop',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}