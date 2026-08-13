import 'package:flutter/material.dart';

class AddNewDebtScreen extends StatefulWidget {
  const AddNewDebtScreen({super.key});

  @override
  State<AddNewDebtScreen> createState() => _AddNewDebtScreenState();
}

class _AddNewDebtScreenState extends State<AddNewDebtScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveDebt() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      return;
    }

    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Debt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Debt Amount (KES)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDebt,
                child: const Text('Save Debt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}