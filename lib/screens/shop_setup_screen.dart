import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/storage_service.dart';
import '../services/backup_service.dart';
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
  bool _isBackingUp = false;
  bool _isRestoring = false;

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
      _paymentMethod =
      shop.paymentMethod.isEmpty ? 'None' : shop.paymentMethod;
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

  Future<void> _backupNow() async {
    setState(() => _isBackingUp = true);

    try {
      await BackupService.shareBackup();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup created. Send it to Google Drive or email to keep '
                'it safe.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create backup: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreNow() async {
    RestoreResult? parsed;

    try {
      parsed = await BackupService.pickAndParseBackup();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }

    if (parsed == null) return;

    if (!mounted) return;

    final dateLabel = parsed.exportedAt == null
        ? 'unknown date'
        : _formatDate(parsed.exportedAt!);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Restore backup?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will REPLACE all current customers and '
                  'transactions on this phone.',
            ),
            const SizedBox(height: 12),
            Text('Backup date: $dateLabel'),
            Text('Customers: ${parsed!.customers.length}'),
            const SizedBox(height: 12),
            const Text(
              'Any data not in the backup will be lost.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() => _isRestoring = true);

    try {
      await BackupService.applyRestore(parsed);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Restored ${parsed.customers.length} customer(s) from backup.',
          ),
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not restore: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                keyboardType:
                _paymentMethod == 'M-Pesa Till Number' ||
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

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Backup',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Save a copy of your customers and transactions so you never '
                  'lose them. Send the file to Google Drive or email — not just '
                  'WhatsApp — so you can recover if you lose your phone.',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _isBackingUp ? null : _backupNow,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _isBackingUp ? 'Preparing backup...' : 'Back up now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Restore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Load a backup file back into the app. Use this if you got a '
                  'new phone or reinstalled the app.',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _isRestoring ? null : _restoreNow,
                icon: const Icon(Icons.download),
                label: Text(
                  _isRestoring ? 'Restoring...' : 'Restore from backup',
                  style: const TextStyle(
                    fontSize: 16,
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