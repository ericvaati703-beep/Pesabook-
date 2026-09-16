import 'package:flutter/material.dart';

class AddNewDebtScreen extends StatefulWidget {
  final String customerName;
  final double currentBalance;

  const AddNewDebtScreen({
    super.key,
    required this.customerName,
    required this.currentBalance,
  });

  @override
  State<AddNewDebtScreen> createState() => _AddNewDebtScreenState();
}

class _AddNewDebtScreenState extends State<AddNewDebtScreen> {
  final TextEditingController _amountController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
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

  Future<void> _saveDebt() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Enter a valid debt amount.';
      });
      return;
    }

    final newBalance = widget.currentBalance + amount;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm new debt?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Customer', widget.customerName),
            _detail(
              'Current balance',
              widget.currentBalance <= 0
                  ? 'PAID'
                  : 'KES ${widget.currentBalance.toStringAsFixed(0)}',
            ),
            _detail('New debt', 'KES ${amount.toStringAsFixed(0)}'),
            _detail('New balance', 'KES ${newBalance.toStringAsFixed(0)}'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current balance: '
                  '${widget.currentBalance <= 0 ? 'PAID' : 'KES ${widget.currentBalance.toStringAsFixed(0)}'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
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
                labelText: 'Debt Amount (KES)',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
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