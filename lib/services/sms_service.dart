import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static String createReminderMessage({
    required String customerName,
    required double amount,
    String? shopName,
    String? paymentMethod,
    String? paymentNumber,
    String? accountNumber,
  }) {
    String message =
        'Hello $customerName, this is a friendly reminder that you have '
        'an outstanding balance of KES ${amount.toStringAsFixed(0)}.';

    if (shopName != null && shopName.trim().isNotEmpty) {
      message += '\n\n$shopName';
    }

    if (paymentMethod == 'M-Pesa Till Number') {
      message += '\nTill Number: $paymentNumber';
    } else if (paymentMethod == 'M-Pesa PayBill') {
      message += '\nPayBill Business Number: $paymentNumber';

      if (accountNumber != null && accountNumber.trim().isNotEmpty) {
        message += '\nAccount Number: $accountNumber';
      }
    } else if (paymentMethod == 'Pochi la Biashara') {
      message += '\nPochi la Biashara: $paymentNumber';
    } else if (paymentMethod == 'Phone Number') {
      message += '\nPhone Number: $paymentNumber';
    }

    message += '\n\nPlease pay when you can. Thank you.';

    return message;
  }

  static Future<void> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
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

  static Future<void> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    String cleanNumber = phoneNumber.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+254${cleanNumber.substring(1)}';
    }

    cleanNumber = cleanNumber.replaceFirst('+', '');

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}