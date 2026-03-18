enum UserRole { client, admin }

class AppUser {
  final String id;
  final String name;
  final String uniqueNumber;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.uniqueNumber,
    required this.role,
  });
}
