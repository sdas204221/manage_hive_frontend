import 'sales_line.dart';

class Invoice {
  final int? invoiceNumber;
  final String? customerName;
  final String? customerAddress;
  final DateTime? issueDate;
  final String? paymentMethod;
  final String? paymentTerms;
  final DateTime? paymentDate;
  final double? discount;
  final List<SalesLine>? salesLines;
  final double? subtotal;
  final double? totalAmount;

  Invoice({
    this.invoiceNumber,
    this.customerName,
    this.customerAddress,
    this.issueDate,
    this.paymentMethod,
    this.paymentTerms,
    this.paymentDate,
    this.discount,
    this.salesLines,
    this.subtotal,
    this.totalAmount,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoiceNumber'],
      customerName: json['customerName'],
      customerAddress: json['customerAddress'],
      issueDate: DateTime.parse(json['issueDate']).add(Duration(hours: 5,minutes: 30)),
      paymentMethod: json['paymentMethod'],
      paymentTerms: json['paymentTerms'],
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate']).add(Duration(hours: 5,minutes: 30))
              : null,
      discount: (json['discount'] ?? 0).toDouble(),
      salesLines:
          (json['salesLines'] as List<dynamic>?)
              ?.map((item) => SalesLine.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'issueDate': issueDate?.subtract(Duration(hours: 5,minutes: 30)).toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentTerms': paymentTerms,
      'paymentDate': paymentDate?.subtract(Duration(hours: 5,minutes: 30)).toIso8601String(),
      'discount': discount,
      'salesLines': salesLines?.map((line) => line.toJson()).toList() ?? [],
      'subtotal': subtotal,
      'totalAmount': totalAmount,
    };
  }
}
