class NGO {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String registrationNumber;
  final Map<String, dynamic> address;
  final List<String> preferredFoodTypes;
  final String ngoType;

  NGO({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.registrationNumber,
    required this.address,
    required this.preferredFoodTypes,
    required this.ngoType,
  });

  factory NGO.fromJson(Map<String, dynamic> json) {
    return NGO(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      address: json['address'] ?? {},
      preferredFoodTypes: List<String>.from(json['preferredFoodTypes'] ?? []),
      ngoType: json['ngoType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'registrationNumber': registrationNumber,
      'address': address,
      'preferredFoodTypes': preferredFoodTypes,
      'ngoType': ngoType,
    };
  }
}
