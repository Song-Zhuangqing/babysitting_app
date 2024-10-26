class Parent {
  final int id;
  final String name;
  final String phone;
  final String gender;
  final String email;
  final String address;

  Parent({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.email,
    required this.address,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['parents_id'] ?? 0, // Assuming ID is an integer
      name: json['parents_name'] ?? '',
      phone: json['parents_phone'] ?? '',
      gender: json['parents_sex'] ?? '',
      email: json['parents_email'] ?? '',
      address: json['parents_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parents_id': id,
      'parents_name': name,
      'parents_phone': phone,
      'parents_sex': gender,
      'parents_email': email,
      'parents_address': address,
    };
  }
}
