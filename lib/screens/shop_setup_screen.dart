import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _shopNameController = TextEditingController();
  final _paymentNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _paymentMethod = 'None';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedShop();
  }

  Future<void> _loadSavedShop() async {
    final shop = await StorageService.loadShop();

    if (!mounted) return;

    if (shop != null) {
      _shopNameController.text = shop.name;
      _paymentMethod = shop.paymentMethod.isEmpty ? 'None' : shop.paymentMethod;
      _paymentNumberController.text = shop.paymentNumber;
      if (shop.accountNumber != null) {
        _accountNumberController.text = shop.accountNumber!;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _paymentNumberController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  bool get _hasPaymentMethod => _paymentMethod != 'None';

  bool get _isPayBill => _paymentMethod == 'M-Pesa PayBill';

  String get _paymentNumberLabel {
    switch (_paymentMethod) {
      case 'M-Pesa Till Number':
        return 'Till Number';
      case 'M-Pesa PayBill':
        return 'Business Number';
      case 'Pochi la Biashara':
        return 'Business Phone Number';
      case 'Phone Number':
        return 'Phone Number';
      default:
        return 'Payment Number';
    }
  }

  String get _paymentNumberHint {
    switch (_paymentMethod) {
      case 'M-Pesa Till Number':
        return 'Enter your M-Pesa Till Number';
      case 'M-Pesa PayBill':
        return 'Enter your PayBill Business Number';
      case 'Pochi la Biashara':
        return 'Enter your business phone number';
      case 'Phone Number':
        return 'Enter your phone number';
      default:
        return 'Enter payment number';
    }
  }

  Future<void> _saveShop() async {
    final shopName = _shopNameController.text.trim();
    final paymentNumber = _paymentNumberController.text.trim();
    final accountNumber = _accountNumberController.text.trim();

    if (shopName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your shop name.'),
        ),
      );
      return;
    }

    if (_hasPaymentMethod && paymentNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the payment number, or choose None.'),
        ),
      );
      return;
    }

    if (_isPayBill && accountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the PayBill Account Number.'),
        ),
      );
      return;
    }

    final shop = Shop(
      name: shopName,
      paymentMethod: _hasPaymentMethod ? _paymentMethod : '',
      paymentNumber: _hasPaymentMethod ? paymentNumber : '',
      accountNumber: _isPayBill ? accountNumber : null,
    );

    await StorageService.saveShop(shop);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shop details saved.'),
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shop Setup'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method (optional)',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'None',
                  child: Text('None — no payment details'),
                ),
                DropdownMenuItem(
                  value: 'M-Pesa Till Number',
                  child: Text('M-Pesa Till Number'),
                ),
                DropdownMenuItem(
                  value: 'M-Pesa PayBill',
                  child: Text('M-Pesa PayBill'),
                ),
                DropdownMenuItem(
                  value: 'Pochi la Biashara',
                  child: Text('Pochi la Biashara'),
                ),
                DropdownMenuItem(
                  value: 'Phone Number',
                  child: Text('Phone Number'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _paymentMethod = value;
                  _paymentNumberController.clear();
                  _accountNumberController.clear();
                });
              },
            ),

            if (_hasPaymentMethod) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _paymentNumberController,
                keyboardType: _paymentMethod == 'M-Pesa Till Number' ||
                    _paymentMethod == 'M-Pesa PayBill'
                    ? TextInputType.number
                    : TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _paymentNumberLabel,
                  hintText: _paymentNumberHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],

            if (_isPayBill) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  hintText: 'Enter your PayBill Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveShop,
                child: const Text(
                  'Save Shop',
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
    );
  }
}