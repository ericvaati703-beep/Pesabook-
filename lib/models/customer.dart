import 'transaction.dart';

class Customer {
  final String name;
  final String phone;
  double amount;
  final List<Transaction> transactions;

  Customer({
    required this.name,
    required this.phone,
    required this.amount,
    List<Transaction>? transactions,
  }) : transactions = transactions ?? [];
}