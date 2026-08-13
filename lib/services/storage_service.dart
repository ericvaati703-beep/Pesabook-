import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';
import '../models/transaction.dart';

class StorageService {
  static const String customersKey = 'customers';

  static Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();

    final data = customers.map((customer) {
      return {
        'name': customer.name,
        'phone': customer.phone,
        'amount': customer.amount,
        'transactions': customer.transactions.map((transaction) {
          return {
            'type': transaction.type,
            'amount': transaction.amount,
            'date': transaction.date.toIso8601String(),
          };
        }).toList(),
      };
    }).toList();

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

    final List decoded = jsonDecode(jsonString);

    return decoded.map((item) {
      return Customer(
        name: item['name'],
        phone: item['phone'],
        amount: (item['amount'] as num).toDouble(),
        transactions: (item['transactions'] as List).map((t) {
          return Transaction(
            type: t['type'],
            amount: (t['amount'] as num).toDouble(),
            date: DateTime.parse(t['date']),
          );
        }).toList(),
      );
    }).toList();
  }
}