class Restaurant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String taxId;
  final Map<String, dynamic> address;
  final Map<String, dynamic> serviceArea;

  Restaurant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.taxId,
    required this.address,
    required this.serviceArea,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      taxId: json['taxId'] ?? '',
      address: json['address'] ?? {},
      serviceArea: json['serviceArea'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'taxId': taxId,
      'address': address,
      'serviceArea': serviceArea,
    };
  }
}
