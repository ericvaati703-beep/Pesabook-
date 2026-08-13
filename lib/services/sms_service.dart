import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static String createReminderMessage({
    required String customerName,
    required double amount,
  }) {
    return 'Hello $customerName, this is a friendly reminder that you have an outstanding balance of KES ${amount.toStringAsFixed(0)}. Please pay when you can. Thank you.';
  }

  static Future<void> sendReminder({
    required String phoneNumber,
    required String customerName,
    required double amount,
  }) async {
    final message = createReminderMessage(
      customerName: customerName,
      amount: amount,
    );

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}