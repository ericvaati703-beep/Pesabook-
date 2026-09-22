import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/storage_service.dart';
import 'add_customer_screen.dart';
import 'customer_screen.dart';
import 'shop_setup_screen.dart';
import 'customers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Customer> _customers = [];

  bool _isSearching = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();

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

  double get totalDebt {
    return _customers.fold(
      0,
          (sum, customer) => sum + customer.amount,
    );
  }

  List<Customer> get _activeCustomers {
    final query = _searchController.text.trim().toLowerCase();

    final activeCustomers = _customers.where((customer) {
      if (customer.amount <= 0) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final name = customer.name.toLowerCase();
      final phone = customer.phone.toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();

    activeCustomers.sort(
          (a, b) => b.amount.compareTo(a.amount),
    );

    return activeCustomers;
  }

  Future<void> _addDebt() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    );

    if (customer == null) return;

    setState(() {
      _customers.add(customer);
    });

    await StorageService.saveCustomers(_customers);
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

    if (updatedCustomer != null) {
      final index = _customers.indexOf(customer);

      if (index != -1) {
        setState(() {
          _customers[index] = updatedCustomer;
        });
      }
    }

    await StorageService.saveCustomers(_customers);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _openShopSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopSetupScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _closeSearch() {
    _searchController.clear();

    setState(() {
      _isSearching = false;
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _onNavigationTapped(int index) async {
    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomersScreen(),
        ),
      );

      await _loadCustomers();

      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });

      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCustomerCard(Customer customer) {
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
          [
            if (customer.phone.isEmpty) 'No phone number' else customer.phone,
            if (customer.debtAgeLabel.isNotEmpty) customer.debtAgeLabel,
          ].join(' · '),
        ),
        trailing: Text(
          'KES ${customer.amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCustomers = _activeCustomers;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search customers...',
            border: InputBorder.none,
          ),
        )
            : const Text(
          'PesaBook',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSearching)
            IconButton(
              onPressed: _closeSearch,
              icon: const Icon(Icons.close),
              tooltip: 'Close search',
            )
          else ...[
            IconButton(
              onPressed: _startSearch,
              icon: const Icon(Icons.search),
              tooltip: 'Search customers',
            ),
            IconButton(
              onPressed: _openShopSettings,
              icon: const Icon(Icons.settings),
              tooltip: 'Shop settings',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isSearching) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Money Owed to You',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KES ${totalDebt.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your debt book — track who owes you and record payments.',
                      style: TextStyle(
                        fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
            if (activeCustomers.isNotEmpty)
              const Text(
                'Customers Who Owe You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (activeCustomers.isNotEmpty) const SizedBox(height: 12),
            Expanded(
              child: activeCustomers.isEmpty
                  ? Center(
                child: Text(
                  _isSearching
                      ? 'No customers found.'
                      : 'No customers owe you money.',
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: activeCustomers.length,
                itemBuilder: (context, index) {
                  return _buildCustomerCard(
                    activeCustomers[index],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _addDebt,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Debt',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavigationTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Customers',
          ),
        ],
      ),
    );
  }
}