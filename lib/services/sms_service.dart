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

    if (paymentMethod == 'M-Pesa Till Number' && paymentNumber != null) {
      message += '\nTill Number: $paymentNumber';
    } else if (paymentMethod == 'M-Pesa PayBill' && paymentNumber != null) {
      message += '\nPayBill Business Number: $paymentNumber';

      if (accountNumber != null && accountNumber.trim().isNotEmpty) {
        message += '\nAccount Number: $accountNumber';
      }
    } else if (paymentMethod == 'Pochi la Biashara' && paymentNumber != null) {
      message += '\nPochi la Biashara: $paymentNumber';
    } else if (paymentMethod == 'Phone Number' && paymentNumber != null) {
      message += '\nPhone Number: $paymentNumber';
    }

    message += '\n\nPlease pay when you can. Thank you.';

    return message;
  }

  /// Opens the Android default Messages/SMS app.
  static Future<void> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanNumber = phoneNumber.trim();

    if (cleanNumber.isEmpty) {
      return;
    }

    // The standard URI for SMS with a pre-filled message
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanNumber,
      queryParameters: {
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to smsto: if sms: fails
        final Uri smstoUri = Uri(
          scheme: 'smsto',
          path: cleanNumber,
          queryParameters: {
            'body': message,
          },
        );
        await launchUrl(
          smstoUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // SMS application could not be opened.
    }
  }

  /// Opens WhatsApp with the customer's number and message.
  static Future<void> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    String cleanNumber = phoneNumber.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    // Convert Kenyan numbers such as 0720592354
    // to international format 25472059354.
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '254${cleanNumber.substring(1)}';
    } else if (cleanNumber.startsWith('+')) {
      cleanNumber = cleanNumber.substring(1);
    }

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanNumber'
          '?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // WhatsApp could not be opened.
    }
  }
}
