class SalesLine {
  int? sid;
  final String? description;
  final double? quantity;
  final double? unitPrice;
  final double? tax;

  SalesLine({
    this.sid,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.tax,
  });

  factory SalesLine.fromJson(Map<String, dynamic> json) {
    return SalesLine(
      sid: json['sid'],
      description: json['description'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'tax': tax,
    };
  }
}
