class Customer {
  final int customerId;
  final String customerCode;
  final String customerName;

  Customer({
    required this.customerId,
    required this.customerCode,
    required this.customerName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      customerCode: json['customer_code'],
      customerName: json['customer_name'],
    );
  }
}
