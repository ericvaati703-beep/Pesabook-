import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/storage_service.dart';
import 'customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final List<Customer> _customers = [];

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadCustomers();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadCustomers() async {
    final customers = await StorageService.loadCustomers();

    if (!mounted) return;

    setState(() {
      _customers
        ..clear()
        ..addAll(customers);
    });
  }

  List<Customer> get _filteredCustomers {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return List<Customer>.from(_customers);
    }

    return _customers.where((customer) {
      final name = customer.name.toLowerCase();
      final phone = customer.phone.toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  Future<void> _openCustomer(Customer customer) async {
    final updatedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerScreen(
          customer: customer,
        ),
      ),
    );

    // If CustomerScreen was closed with the Back button,
    // updatedCustomer can be null. But the original customer
    // object may already have been changed in memory.
    final customerToSave = updatedCustomer ?? customer;

    final index = _customers.indexOf(customer);

    if (index != -1) {
      setState(() {
        _customers[index] = customerToSave;
      });
    }

    // Save the updated customer list.
    await StorageService.saveCustomers(_customers);

    if (!mounted) return;

    // Return the updated customer to HomeScreen.
    Navigator.pop(context, customerToSave);
  }

  Widget _buildCustomerCard(Customer customer) {
    final bool isPaid = customer.amount <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => _openCustomer(customer),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          customer.phone.isEmpty
              ? 'No phone number'
              : customer.phone,
        ),
        trailing: Text(
          isPaid
              ? 'PAID'
              : 'KES ${customer.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isPaid ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filteredCustomers;

    final owingCustomers = customers
        .where((customer) => customer.amount > 0)
        .toList();

    // Highest debt first.
    owingCustomers.sort(
          (a, b) => b.amount.compareTo(a.amount),
    );

    final paidCustomers = customers
        .where((customer) => customer.amount <= 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: customers.isEmpty
                  ? const Center(
                child: Text(
                  'No customers found.',
                  style: TextStyle(fontSize: 17),
                ),
              )
                  : ListView(
                children: [
                  // -------------------------
                  // CUSTOMERS WHO OWE
                  // -------------------------
                  if (owingCustomers.isNotEmpty) ...[
                    const Text(
                      'Customers Who Owe You',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...owingCustomers.map(
                          (customer) =>
                          _buildCustomerCard(customer),
                    ),
                  ],

                  // -------------------------
                  // PAID CUSTOMERS
                  // -------------------------
                  if (paidCustomers.isNotEmpty) ...[
                    if (owingCustomers.isNotEmpty)
                      const SizedBox(height: 20),

                    const Text(
                      'Paid Customers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...paidCustomers.map(
                          (customer) =>
                          _buildCustomerCard(customer),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}