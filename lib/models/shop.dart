class Shop {
  String name;
  String paymentMethod;
  String paymentNumber;
  String? accountNumber;

  Shop({
    required this.name,
    required this.paymentMethod,
    required this.paymentNumber,
    this.accountNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'paymentMethod': paymentMethod,
      'paymentNumber': paymentNumber,
      'accountNumber': accountNumber,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['name'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'M-Pesa Till Number',
      paymentNumber: json['paymentNumber'] ?? '',
      accountNumber: json['accountNumber'],
    );
  }
}