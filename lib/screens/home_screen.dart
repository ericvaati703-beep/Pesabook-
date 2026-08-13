import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/storage_service.dart';
import 'add_customer_screen.dart';
import 'customer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await StorageService.loadCustomers();

    setState(() {
      _customers.clear();
      _customers.addAll(customers);
    });
  }

  double get totalDebt =>
      _customers.fold(0, (sum, customer) => sum + customer.amount);

  Future<void> _addDebt() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );

    if (customer != null) {
      setState(() {
        _customers.add(customer);
      });

      await StorageService.saveCustomers(_customers);
    }
  }

  Future<void> _openCustomer(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerScreen(
          customer: customer,
        ),
      ),
    );

    await StorageService.saveCustomers(_customers);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PesaBook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Debt',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              'KES ${totalDebt.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _customers.isEmpty
                  ? const Center(
                child: Text(
                  'No debts yet.',
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];

                  return Card(
                    child: ListTile(
                      onTap: () => _openCustomer(customer),
                      title: Text(customer.name),
                      subtitle: Text(
                        customer.phone.isEmpty
                            ? 'No phone number'
                            : customer.phone,
                      ),
                      trailing: Text(
                        'KES ${customer.amount.toStringAsFixed(0)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addDebt,
                child: const Text('Add Debt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}