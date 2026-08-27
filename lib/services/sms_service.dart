import 'package:url_launcher/url_launcher.dart';

class SmsService {
  /// Creates the default reminder message.
  static String createReminderMessage({
    required String customerName,
    required double amount,
  }) {
    return 'Hello $customerName, this is a friendly reminder that you have an outstanding balance of KES ${amount.toStringAsFixed(0)}. Please pay when you can. Thank you.';
  }

  /// Opens the SMS app with a custom message.
  static Future<void> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    if (phoneNumber.trim().isEmpty) {
      return;
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber.trim(),
      queryParameters: {
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  /// Opens the SMS app with the default reminder message.
  static Future<void> sendReminder({
    required String phoneNumber,
    required String customerName,
    required double amount,
  }) async {
    final message = createReminderMessage(
      customerName: customerName,
      amount: amount,
    );

    await sendCustomMessage(
      phoneNumber: phoneNumber,
      message: message,
    );
  }
}