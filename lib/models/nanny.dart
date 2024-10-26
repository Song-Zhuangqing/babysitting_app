class Nanny {
  final int id;
  final String name;
  final String phone;
  final String gender;
  final String email;
  final String address;
  final String certificate;

  Nanny({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.email,
    required this.address,
    required this.certificate,
  });

  factory Nanny.fromJson(Map<String, dynamic> json) {
    return Nanny(
      id: json['nannies_id'] ?? 0, // Assuming ID is an integer
      name: json['nannies_name'] ?? '',
      phone: json['nannies_phone'] ?? '',
      gender: json['nannies_sex'] ?? '',
      email: json['nannies_email'] ?? '',
      address: json['nannies_address'] ?? '',
      certificate: json['nannies_certificate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nannies_id': id,
      'nannies_name': name,
      'nannies_phone': phone,
      'nannies_sex': gender,
      'nannies_email': email,
      'nannies_address': address,
      'nannies_certificate': certificate,
    };
  }
}
