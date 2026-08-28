import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/shop.dart';
import '../services/sms_service.dart';
import '../services/storage_service.dart';

class SendReminderScreen extends StatefulWidget {
  final Customer customer;

  const SendReminderScreen({
    super.key,
    required this.customer,
  });

  @override
  State<SendReminderScreen> createState() => _SendReminderScreenState();
}

class _SendReminderScreenState extends State<SendReminderScreen> {
  late final TextEditingController _messageController;

  Shop? _shop;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();

    _loadShop();
  }

  Future<void> _loadShop() async {
    final shop = await StorageService.loadShop();

    if (!mounted) return;

    setState(() {
      _shop = shop;
      _isLoading = false;

      _messageController.text = _createDefaultMessage();
    });
  }

  String _createDefaultMessage() {
    final customerName = widget.customer.name;
    final amount = widget.customer.amount.toStringAsFixed(0);

    String message = 'Hello $customerName, ';

    if (_shop != null) {
      message +=
      'this is a friendly reminder from ${_shop!.name} that you have ';
    } else {
      message +=
      'this is a friendly reminder that you have ';
    }

    message += 'an outstanding balance of KES $amount.';

    if (_shop != null) {
      message +=
      ' Please pay via ${_shop!.paymentMethod} '
          '${_shop!.paymentNumber}.';
    } else {
      message += ' Please pay when you can.';
    }

    message += ' Thank you.';

    return message;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _resetMessage() {
    setState(() {
      _messageController.text = _createDefaultMessage();
    });
  }

  Future<void> _sendSms() async {
    if (widget.customer.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This customer does not have a phone number.',
          ),
        ),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message.'),
        ),
      );
      return;
    }

    await SmsService.sendCustomMessage(
      phoneNumber: widget.customer.phone,
      message: _messageController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Send Reminder'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder for ${widget.customer.name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Outstanding balance: KES '
                  '${widget.customer.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            if (_shop != null) ...[
              const SizedBox(height: 8),
              Text(
                'Payment: ${_shop!.paymentMethod} ${_shop!.paymentNumber}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: _resetMessage,
                  child: const Text('Reset to Default'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write your reminder message...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'You can edit the message before sending.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendSms,
                icon: const Icon(Icons.sms),
                label: const Text('Send SMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}