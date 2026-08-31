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

  String get _defaultMessage {
    return SmsService.createReminderMessage(
      customerName: widget.customer.name,
      amount: widget.customer.amount,
      shopName: _shop?.name,
      paymentMethod: _shop?.paymentMethod,
      paymentNumber: _shop?.paymentNumber,
      accountNumber: _shop?.accountNumber,
    );
  }

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
      _messageController.text = _defaultMessage;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _resetMessage() {
    setState(() {
      _messageController.text = _defaultMessage;
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

  Future<void> _sendWhatsApp() async {
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

    await SmsService.sendWhatsAppMessage(
      phoneNumber: widget.customer.phone,
      message: _messageController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Reminder'),
      ),
      body: SingleChildScrollView(
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

            SizedBox(
              height: 220,
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

            const SizedBox(height: 20),

            const Text(
              'Send via',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sendWhatsApp,
                icon: const Icon(Icons.chat),
                label: const Text(
                  'Send via WhatsApp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _sendSms,
                icon: const Icon(Icons.sms),
                label: const Text(
                  'Send via SMS',
                  style: TextStyle(
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