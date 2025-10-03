import 'package:manage_hive/models/user.dart';

class Product {
  final int? id;
  final User? user; // Maps to the @ManyToOne User field in Java
  final String? productName;
  final double? price;
  final double? tax;

  Product({
    this.id,
    this.user,
    this.productName,
    this.price,
    this.tax,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      // Deserialize the nested User object if present
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
      productName: json['productName'] as String?,
      // Use 'num?' for safe casting from JSON dynamic types to double
      price: (json['price'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serialize the nested User object to JSON
      'user': user?.toJson(),
      'productName': productName,
      'price': price,
      'tax': tax,
    };
  }

  Product copyWith({
    int? id,
    User? user,
    String? productName,
    double? price,
    double? tax,
  }) {
    return Product(
      id: id ?? this.id,
      user: user ?? this.user,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      tax: tax ?? this.tax,
    );
  }
}
