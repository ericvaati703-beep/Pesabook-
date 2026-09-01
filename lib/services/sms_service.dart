import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static const MethodChannel _smsChannel =
  MethodChannel('com.example.pesabook1/sms');

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

  /// Opens the Android default Messages/SMS app.
  static Future<void> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanNumber = phoneNumber.trim();

    if (cleanNumber.isEmpty) {
      return;
    }

    // Android: use the native SMS intent.
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool opened = await _smsChannel.invokeMethod<bool>(
          'openSms',
          {
            'phoneNumber': cleanNumber,
            'message': message,
          },
        ) ??
            false;

        if (opened) {
          return;
        }
      } catch (e) {
        // Fall through to the normal sms: URL.
      }
    }

    // Fallback for other platforms such as Chrome.
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