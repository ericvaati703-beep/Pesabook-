import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/customer.dart';
import '../models/shop.dart';
import '../models/transaction.dart';
import 'storage_service.dart';

class RestoreResult {
  final List<Customer> customers;
  final Shop? shop;
  final DateTime? exportedAt;

  RestoreResult({
    required this.customers,
    this.shop,
    this.exportedAt,
  });
}

class BackupService {
  static const String _appName = 'PesaBook';
  static const int _backupVersion = 1;

  // ---------------------------------------------------------------------
  // BACKUP (export)
  // ---------------------------------------------------------------------

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

  // ---------------------------------------------------------------------
  // RESTORE (import)
  // ---------------------------------------------------------------------

  /// Opens the file picker, lets the user choose a backup file, and
  /// parses it. Returns null if the user cancelled. Throws a readable
  /// exception if the file is invalid.
  static Future<RestoreResult?> pickAndParseBackup() async {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (files.isEmpty) {
      return null;
    }

    final file = files.single;

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      throw Exception('Could not read the selected file.');
    }

    final String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      throw Exception('The file is not readable text.');
    }

    final Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected format.');
      }
      data = decoded;
    } catch (_) {
      throw Exception('This file is not a valid PesaBook backup.');
    }

    if (data['app'] != _appName) {
      throw Exception('This is not a PesaBook backup file.');
    }

    final customers = _parseCustomers(data['customers']);
    final shop = _parseShop(data['shop']);
    final exportedAt = _parseExportedAt(data['exported_at']);

    return RestoreResult(
      customers: customers,
      shop: shop,
      exportedAt: exportedAt,
    );
  }

  static List<Customer> _parseCustomers(dynamic raw) {
    if (raw is! List) return [];

    final result = <Customer>[];

    for (final item in raw) {
      if (item is! Map) continue;

      try {
        final name = item['name'] as String?;
        final phone = item['phone'] as String?;
        final amount = item['amount'];

        if (name == null || phone == null || amount == null) continue;

        final transactions = <Transaction>[];
        final rawTx = item['transactions'];

        if (rawTx is List) {
          for (final t in rawTx) {
            if (t is! Map) continue;
            try {
              transactions.add(
                Transaction(
                  type: t['type'] as String,
                  amount: StorageService.roundMoney(t['amount'] as num),
                  date: DateTime.parse(t['date'] as String),
                ),
              );
            } catch (_) {
              // Skip a malformed transaction, keep the rest.
            }
          }
        }

        result.add(
          Customer(
            name: name,
            phone: phone,
            amount: StorageService.roundMoney(amount as num),
            transactions: transactions,
          ),
        );
      } catch (_) {
        // Skip a malformed customer, keep the rest.
      }
    }

    return result;
  }

  static Shop? _parseShop(dynamic raw) {
    if (raw is! Map) return null;

    try {
      return Shop.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseExportedAt(dynamic raw) {
    if (raw is! String) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Writes the parsed backup into local storage, replacing everything.
  static Future<void> applyRestore(RestoreResult result) async {
    await StorageService.saveCustomers(result.customers);

    if (result.shop != null) {
      await StorageService.saveShop(result.shop!);
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}