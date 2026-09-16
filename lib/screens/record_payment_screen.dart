import 'package:flutter/material.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String customerName;
  final double currentBalance;

  const RecordPaymentScreen({
    super.key,
    required this.customerName,
    required this.currentBalance,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final TextEditingController _paymentController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePayment() async {
    final payment = double.tryParse(_paymentController.text.trim());

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

    final newBalance = widget.currentBalance - payment;
    final newBalanceLabel = newBalance <= 0
        ? 'PAID'
        : 'KES ${newBalance.toStringAsFixed(0)}';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm payment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Customer', widget.customerName),
            _detail(
              'Current balance',
              'KES ${widget.currentBalance.toStringAsFixed(0)}',
            ),
            _detail('Payment', 'KES ${payment.toStringAsFixed(0)}'),
            _detail('New balance', newBalanceLabel),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

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