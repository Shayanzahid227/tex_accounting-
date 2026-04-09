import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/services/invoice_session_cache.dart';
import 'package:girl_clan/core/services/admin_invoice_view_cache.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServices extends BaseViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseServices? _databaseServices;
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  void setDatabaseServices(DatabaseServices db) {
    _databaseServices = db;
  }

  Future<AppUser?> login(String identifier, {String? password}) async {
    // For both admin and clients, we use Firebase Auth so rules work correctly.
    if (password != null && _databaseServices != null) {
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        ).timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Login timed out. Please check your internet connection.');
        });

        if (userCredential.user != null) {
          final uid = userCredential.user!.uid;
          final existing = await _databaseServices!.getUser(uid);

          // If this is the special admin account, ensure Firestore profile exists with role=admin.
          final isAdminLogin =
              identifier == AppUser.adminEmail && password == AppUser.adminUniqueNumber;

          if (existing == null) {
            if (isAdminLogin) {
              final adminUser = AppUser(
                id: uid,
                name: 'Super Admin',
                email: AppUser.adminEmail,
                uniqueNumber: AppUser.adminUniqueNumber,
                role: UserRole.admin,
              );
              await _databaseServices!.upsertUser(adminUser);
              _currentUser = adminUser;
              return _currentUser;
            }

            await _auth.signOut();
            throw Exception('User profile not found. Contact administrator.');
          }

          // If admin credentials are used, force role to admin (and keep in sync).
          if (isAdminLogin && existing.role != UserRole.admin) {
            final adminUser = AppUser(
              id: uid,
              name: existing.name.isNotEmpty ? existing.name : 'Super Admin',
              email: existing.email ?? AppUser.adminEmail,
              uniqueNumber: existing.uniqueNumber.isNotEmpty
                  ? existing.uniqueNumber
                  : AppUser.adminUniqueNumber,
              role: UserRole.admin,
            );
            await _databaseServices!.upsertUser(adminUser);
            _currentUser = adminUser;
            return _currentUser;
          }

          _currentUser = existing;
          return _currentUser;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw Exception('No account found with these credentials.');
        } else if (e.code == 'invalid-email') {
          throw Exception('Please enter a valid email address.');
        }
        throw Exception('Login error: ${e.message}');
      } catch (e) {
        throw Exception('Login failed. Please try again.');
      }
    }
    return null;
  }

  Future<AppUser?> register(String name, String email, String password) async {
    if (_databaseServices != null) {
      try {
        debugPrint('Starting registration for $email');
        // 1. Check if uniqueNumber (password) is already used
        debugPrint('Checking uniqueness of $password');
        final isAvailable = await _databaseServices!.isUniqueNumberAvailable(password);
        debugPrint('Uniqueness check completed: $isAvailable');
        
        if (!isAvailable) {
          throw Exception('This unique number is already in use. Please choose another.');
        }

        // 2. Create user in Firebase Auth
        debugPrint('Creating Firebase Auth user...');
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ).timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Firebase Authentication timed out. Please check your internet connection.');
        });
        debugPrint('Firebase Auth user created: ${userCredential.user?.uid}');

        if (userCredential.user != null) {
          // 3. Create user profile in Firestore
          debugPrint('Creating Firestore user profile...');
          final newUser = AppUser(
            id: userCredential.user!.uid,
            name: name,
            email: email,
            uniqueNumber: password,
            role: UserRole.client,
          );

          try {
            await _databaseServices!.addClient(newUser);
            debugPrint('Firestore profile created.');
            _currentUser = newUser;
            return _currentUser;
          } catch (e) {
            // ROLLBACK: Delete the Firebase Auth user to prevent an orphaned account without a DB profile
            try {
              await userCredential.user!.delete();
            } catch (_) {}
            
            throw Exception('Database connection failed. Please ensure Cloud Firestore is initialized in your Firebase Console.');
          }
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
        if (e.code == 'email-already-in-use') {
          throw Exception('This email is already registered.');
        } else if (e.code == 'weak-password') {
          throw Exception('The password is too weak.');
        }
        throw Exception('Registration error: ${e.message}');
      } catch (e) {
        debugPrint('Registration Error: $e');
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
    } else {
      debugPrint('Error: DatabaseServices is null');
    }
    return null;
  }

  Future<void> checkSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null && _databaseServices != null) {
      _currentUser = await _databaseServices!.getUser(firebaseUser.uid);
      if (_currentUser == null) {
        // Fallback: If user exists in Auth but no Firestore profile exists (due to a previous failed sync)
        await _auth.signOut();
      }
    }
  }

  Future<void> logout() async {
    InvoiceSessionCache.instance.clear();
    AdminInvoiceViewCache.instance.clear();
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
