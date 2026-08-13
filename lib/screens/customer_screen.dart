import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../services/sms_service.dart';
import 'record_payment_screen.dart';
import 'add_new_debt_screen.dart';

class CustomerScreen extends StatefulWidget {
  final Customer customer;

  const CustomerScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  Future<void> _recordPayment() async {
    final payment = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordPaymentScreen(),
      ),
    );

    if (payment != null) {
      setState(() {
        widget.customer.amount -= payment;

        if (widget.customer.amount < 0) {
          widget.customer.amount = 0;
        }

        widget.customer.transactions.add(
          Transaction(
            type: 'Payment',
            amount: payment,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _addNewDebt() async {
    final debt = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewDebtScreen(),
      ),
    );

    if (debt != null) {
      setState(() {
        widget.customer.amount += debt;

        widget.customer.transactions.add(
          Transaction(
            type: 'Debt',
            amount: debt,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _sendReminder() async {
    await SmsService.sendReminder(
      phoneNumber: widget.customer.phone,
      customerName: widget.customer.name,
      amount: widget.customer.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customer.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              widget.customer.phone,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            const Text(
              'Current Balance',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              'KES ${widget.customer.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _recordPayment,
                child: const Text('Record Payment'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addNewDebt,
                child: const Text('Add New Debt'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendReminder,
                child: const Text('Send Reminder'),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: widget.customer.transactions.isEmpty
                  ? const Center(
                child: Text('No transactions yet.'),
              )
                  : ListView.builder(
                itemCount: widget.customer.transactions.length,
                itemBuilder: (context, index) {
                  final transaction =
                  widget.customer.transactions[index];

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        transaction.type == 'Debt'
                            ? Icons.add_circle
                            : Icons.remove_circle,
                      ),
                      title: Text(transaction.type),
                      subtitle: Text(
                        'KES ${transaction.amount.toStringAsFixed(0)}\n'
                            '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} '
                            '${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}