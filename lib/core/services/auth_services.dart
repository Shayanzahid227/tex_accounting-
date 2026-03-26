import 'package:girl_clan/core/others/base_view_model.dart';

import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:uuid/uuid.dart';

class AuthServices extends BaseViewModel {
  DatabaseServices? _databaseServices;
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  void setDatabaseServices(DatabaseServices db) {
    _databaseServices = db;
  }

  Future<AppUser?> login(String uniqueNumber) async {
    // Check for admin first
    if (uniqueNumber == 'admin') {
      _currentUser = AppUser(
        id: 'admin_1',
        name: 'Super Admin',
        uniqueNumber: 'admin',
        role: UserRole.admin,
      );
      return _currentUser;
    }

    // Lookup in database
    if (_databaseServices != null) {
      final user = await _databaseServices!.getUserByUniqueNumber(uniqueNumber);
      if (user != null) {
        _currentUser = user;
        return _currentUser;
      }
    }

    // Fallback/Mock for testing (optional, or return null if not found)
    _currentUser = AppUser(
      id: 'user_${uniqueNumber}',
      name:
          'Client $uniqueNumber', // This is what we want to avoid for real users
      uniqueNumber: uniqueNumber,
      role: UserRole.client,
    );
    return _currentUser;
  }

  Future<AppUser?> register(String name, String email, String password) async {
    if (_databaseServices != null) {
      // Check if password already exists
      final existingUser = await _databaseServices!.getUserByUniqueNumber(
        password,
      );
      if (existingUser != null) {
        throw Exception(
          'This password is already in use by another account. Please choose a different one.',
        );
      }

      final newUser = AppUser(
        id: const Uuid().v4(),
        name: name,
        email: email,
        uniqueNumber: password,
        role: UserRole.client,
      );

      await _databaseServices!.addClient(newUser);
      _currentUser = newUser;
      return _currentUser;
    }
    return null;
  }

  void logout() {
    _currentUser = null;
  }
}
