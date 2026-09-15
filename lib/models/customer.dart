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

  /// Date when the current unpaid balance began.
  /// Walks history forward, remembering the last point where
  /// the balance hit zero. The first Debt after that point is
  /// when the current debt started.
  DateTime? get currentDebtStartDate {
    if (transactions.isEmpty) return null;

    double running = 0;
    int lastResetIndex = -1;

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];

      if (t.type == 'Debt') {
        running += t.amount;
      } else {
        running -= t.amount;
      }

      if (running <= 0) {
        running = 0;
        lastResetIndex = i;
      }
    }

    for (int i = lastResetIndex + 1; i < transactions.length; i++) {
      if (transactions[i].type == 'Debt') {
        return transactions[i].date;
      }
    }

    return null;
  }

  /// Human-readable label like 'today', '3 days', '2 months'.
  /// Returns empty string if nothing is owed or no start date exists.
  String get debtAgeLabel {
    if (amount <= 0) return '';

    final start = currentDebtStartDate;
    if (start == null) return '';

    final days = DateTime.now().difference(start).inDays;

    if (days <= 0) return 'today';
    if (days == 1) return '1 day';
    if (days < 30) return '$days days';

    final months = (days / 30).floor();
    if (months == 1) return '1 month';
    return '$months months';
  }
}