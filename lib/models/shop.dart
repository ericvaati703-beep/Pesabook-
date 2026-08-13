class Shop {
  String name;
  String paymentMethod;
  String paymentNumber;

  Shop({
    required this.name,
    required this.paymentMethod,
    required this.paymentNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'paymentMethod': paymentMethod,
      'paymentNumber': paymentNumber,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['name'],
      paymentMethod: json['paymentMethod'],
      paymentNumber: json['paymentNumber'],
    );
  }
}