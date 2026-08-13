import 'package:flutter/material.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final TextEditingController _paymentController = TextEditingController();

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  void _savePayment() {
    final payment = double.tryParse(_paymentController.text);

    if (payment == null || payment <= 0) {
      return;
    }

    Navigator.pop(context, payment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Amount (KES)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePayment,
                child: const Text('Save Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}