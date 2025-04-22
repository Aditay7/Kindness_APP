class NGO {
  final String id;
  final String name;
  final String? contact;

  NGO({
    required this.id,
    required this.name,
    this.contact,
  });

  factory NGO.fromJson(Map<String, dynamic> json) {
    return NGO(
      id: json['_id'],
      name: json['name'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'contact': contact,
    };
  }
}

class Restaurant {
  final String id;
  final String name;
  final String phone;
  final Address address;

  Restaurant({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      address: Address.fromJson(json['address']),
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }
}

class Donation {
  final String id;
  final Restaurant restaurantId;
  final String foodType;
  final String quantity;
  final String status;
  final List<String> allergens;
  final List<String> images;
  final DateTime pickupDeadline;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? claimedAt;
  final NGO? claimedBy;

  Donation({
    required this.id,
    required this.restaurantId,
    required this.foodType,
    required this.quantity,
    required this.status,
    required this.allergens,
    required this.images,
    required this.pickupDeadline,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.claimedAt,
    this.claimedBy,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['_id'],
      restaurantId: json['restaurantId'] is String
          ? Restaurant(
              id: json['restaurantId'],
              name: '',
              phone: '',
              address: Address(street: '', city: '', state: '', country: ''),
            )
          : Restaurant.fromJson(json['restaurantId']),
      foodType: json['foodType'],
      quantity: json['quantity'],
      status: json['status'],
      allergens: List<String>.from(json['allergens']),
      images: List<String>.from(json['images']),
      pickupDeadline: DateTime.parse(json['pickupDeadline']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      claimedAt:
          json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
      claimedBy: json['claimedBy'] != null
          ? (json['claimedBy'] is String
              ? NGO(
                  id: json['claimedBy'],
                  name: 'Unknown NGO',
                )
              : NGO.fromJson(json['claimedBy']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId.id,
      'foodType': foodType,
      'quantity': quantity,
      'status': status,
      'allergens': allergens,
      'images': images,
      'pickupDeadline': pickupDeadline.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'claimedBy': claimedBy?.toJson(),
    };
  }
}
