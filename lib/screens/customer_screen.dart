import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import 'record_payment_screen.dart';
import 'add_new_debt_screen.dart';
import 'send_reminder_screen.dart';
import 'edit_customer_screen.dart';

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
        builder: (context) => RecordPaymentScreen(
          currentBalance: widget.customer.amount,
        ),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendReminderScreen(
          customer: widget.customer,
        ),
      ),
    );
  }

  Future<void> _editCustomer() async {
    final updatedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(
          customer: widget.customer,
        ),
      ),
    );

    if (updatedCustomer == null) return;

    if (!mounted) return;

    Navigator.pop(context, updatedCustomer);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} '
        '${date.year} • $hour:$minute $period';
  }

  double _balanceAfterTransaction(int index) {
    double balance = 0;

    for (int i = 0; i <= index; i++) {
      final transaction = widget.customer.transactions[i];

      if (transaction.type == 'Debt') {
        balance += transaction.amount;
      } else if (transaction.type == 'Payment') {
        balance -= transaction.amount;
      }
    }

    if (balance < 0) {
      balance = 0;
    }

    return balance;
  }

  Widget _buildTransactionCard(
      Transaction transaction,
      double balanceAfter,
      ) {
    final bool isDebt = transaction.type == 'Debt';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(
            isDebt
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
        ),
        title: Text(
          isDebt ? 'Debt Added' : 'Payment Received',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${_formatDate(transaction.date)}\n'
              'Balance: KES ${balanceAfter.toStringAsFixed(0)}',
        ),
        trailing: Text(
          '${isDebt ? '+' : '-'} KES '
              '${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDebt ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaid = widget.customer.amount <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            onPressed: _editCustomer,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit customer',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              widget.customer.phone.isEmpty
                  ? 'No phone number'
                  : widget.customer.phone,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              isPaid
                  ? 'PAID'
                  : 'KES ${widget.customer.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPaid ? null : _recordPayment,
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

            if (widget.customer.transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No transactions yet.'),
                ),
              )
            else
              ListView.builder(
                itemCount: widget.customer.transactions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final transactionIndex =
                      widget.customer.transactions.length -
                          1 -
                          index;

                  final transaction =
                  widget.customer.transactions[
                  transactionIndex];

                  final balanceAfter =
                  _balanceAfterTransaction(
                    transactionIndex,
                  );

                  return _buildTransactionCard(
                    transaction,
                    balanceAfter,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}