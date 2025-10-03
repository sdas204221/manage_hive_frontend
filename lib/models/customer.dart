import 'user.dart';

class Customer {
  final int? id;
  final String? name;
  final String? address;
  final String? phone;
  final String? email;
  final User? user; // Maps to the @ManyToOne User field in Java

  Customer({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
    this.user,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      // Deserialize the nested User object if present
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      // Serialize the nested User object to JSON
      'user': user?.toJson(),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    User? user,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      user: user ?? this.user,
    );
  }
}
