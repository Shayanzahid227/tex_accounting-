enum UserRole { client, admin }

class AppUser {
  static const String adminEmail = 'asad@gmail.com';
  static const String adminUniqueNumber = 'asad1151';

  final String id;
  final String name;
  final String? email;
  final String uniqueNumber;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    this.email,
    required this.uniqueNumber,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'uniqueNumber': uniqueNumber,
      'role': role.name,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      uniqueNumber: map['uniqueNumber'] ?? '',
      role: UserRole.values.byName(map['role'] ?? 'client'),
    );
  }
}
