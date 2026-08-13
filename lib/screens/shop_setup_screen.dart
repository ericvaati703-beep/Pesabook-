import 'package:flutter/material.dart';
import '../models/shop.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _shopNameController = TextEditingController();
  final _paymentNumberController = TextEditingController();

  String _paymentMethod = 'Till Number';

  @override
  void dispose() {
    _shopNameController.dispose();
    _paymentNumberController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_shopNameController.text.isEmpty ||
        _paymentNumberController.text.isEmpty) {
      return;
    }

    final shop = Shop(
      name: _shopNameController.text,
      paymentMethod: _paymentMethod,
      paymentNumber: _paymentNumberController.text,
    );

    Navigator.pop(context, shop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Setup'),
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
              value: _paymentMethod,
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
                setState(() {
                  _paymentMethod = value!;
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
                child: const Text('Save Shop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}