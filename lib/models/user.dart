class User {
  final String? username;
  final String? role;
  final String? businessName;
  final String? address;
  final String? phone;
  final String? email;
  final bool? accountLocked;
  final String? password;

  User({
    this.username,
    this.role,
    this.businessName,
    this.address,
    this.phone,
    this.email,
    this.accountLocked,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      role: json['role'],
      businessName: json['businessName'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      accountLocked: json['accountLocked'] ?? false,
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'businessName': businessName,
      'address': address,
      'phone': phone,
      'email': email,
      'accountLocked': accountLocked,
      'password': password,
    };
  }

  User copyWith({
    String? username,
    String? role,
    String? businessName,
    String? address,
    String? phone,
    String? email,
    bool? accountLocked,
    String? password,
  }) {
    return User(
      username: username ?? this.username,
      role: role ?? this.role,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      accountLocked: accountLocked ?? this.accountLocked,
      password: password ?? this.password,
    );
  }

}
