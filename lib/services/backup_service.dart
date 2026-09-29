import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/customer.dart';
import 'storage_service.dart';

class BackupService {
  static const String _appName = 'PesaBook';
  static const int _backupVersion = 1;

  /// Builds the backup JSON string from current stored data.
  static Future<String> buildBackupJson() async {
    final customers = await StorageService.loadCustomers();
    final shop = await StorageService.loadShop();

    final data = {
      'app': _appName,
      'version': _backupVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'shop': shop?.toJson(),
      'customers': customers.map(_customerToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Map<String, dynamic> _customerToJson(Customer customer) {
    return {
      'name': customer.name,
      'phone': customer.phone,
      'amount': StorageService.roundMoney(customer.amount),
      'transactions': customer.transactions.map((t) {
        return {
          'type': t.type,
          'amount': StorageService.roundMoney(t.amount),
          'date': t.date.toIso8601String(),
        };
      }).toList(),
    };
  }

  /// Writes the backup to a file and opens the Android share sheet.
  /// Returns the file path, or null if something failed.
  static Future<String?> shareBackup() async {
    final json = await buildBackupJson();

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final stamp = '${now.year}-${_two(now.month)}-${_two(now.day)}'
        '-${_two(now.hour)}${_two(now.minute)}';
    final fileName = 'pesabook-backup-$stamp.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'PesaBook backup',
        text: 'PesaBook backup file. Keep this safe — you can restore it '
            'if you lose your phone.',
      ),
    );

    return file.path;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}