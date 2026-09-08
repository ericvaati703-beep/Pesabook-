import 'package:flutter/material.dart';

class RecordPaymentScreen extends StatefulWidget {
  final double currentBalance;

  const RecordPaymentScreen({
    super.key,
    required this.currentBalance,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final TextEditingController _paymentController =
  TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  void _savePayment() {
    final payment = double.tryParse(
      _paymentController.text.trim(),
    );

    if (payment == null || payment <= 0) {
      setState(() {
        _errorMessage = 'Enter a valid payment amount.';
      });
      return;
    }

    if (payment > widget.currentBalance) {
      setState(() {
        _errorMessage =
        'Payment cannot be more than KES '
            '${widget.currentBalance.toStringAsFixed(0)}.';
      });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current balance: KES '
                  '${widget.currentBalance.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _paymentController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Payment Amount (KES)',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
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