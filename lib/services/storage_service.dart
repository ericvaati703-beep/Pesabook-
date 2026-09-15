import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/shop.dart';

class StorageService {
  static const String customersKey = 'customers';
  static const String shopKey = 'shop';

  // NEW: Track data format version so future updates can migrate old data
  static const String versionKey = 'schema_version';
  static const int currentVersion = 1;

  // NEW: Prevent floating-point money errors
  // (e.g., 0.1 + 0.2 becomes 0.30000000000000004)
  static double roundMoney(num value) => (value * 100).round() / 100;

  static Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();

    final data = customers.map((customer) {
      return {
        'name': customer.name,
        'phone': customer.phone,
        // CHANGED: Round money before saving
        'amount': roundMoney(customer.amount),
        'transactions': customer.transactions.map((transaction) {
          return {
            'type': transaction.type,
            // CHANGED: Round money before saving
            'amount': roundMoney(transaction.amount),
            'date': transaction.date.toIso8601String(),
          };
        }).toList(),
      };
    }).toList();

    // NEW: Save version before data
    await prefs.setInt(versionKey, currentVersion);

    await prefs.setString(
      customersKey,
      jsonEncode(data),
    );
  }

  static Future<List<Customer>> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(customersKey);

    if (jsonString == null) {
      return [];
    }

    // CHANGED: Wrapped in try-catch so corrupted data doesn't crash the app
    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((item) {
        return Customer(
          name: item['name'],
          phone: item['phone'],
          // CHANGED: Round on load too, in case old data has float errors
          amount: roundMoney(item['amount']),
          transactions: (item['transactions'] as List).map((t) {
            return Transaction(
              type: t['type'],
              // CHANGED: Round on load too
              amount: roundMoney(t['amount']),
              date: DateTime.parse(t['date']),
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      // If data is corrupted, save a backup and return empty list.
      // The app stays open instead of crashing forever.
      await prefs.setString('${customersKey}_corrupted_backup', jsonString);
      return [];
    }
  }

  static Future<void> saveShop(Shop shop) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      shopKey,
      jsonEncode(shop.toJson()),
    );
  }

  static Future<Shop?> loadShop() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(shopKey);

    if (jsonString == null) {
      return null;
    }

    // CHANGED: Same protection for shop data
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return Shop.fromJson(decoded);
    } catch (e) {
      await prefs.setString('${shopKey}_corrupted_backup', jsonString);
      return null;
    }
  }
}