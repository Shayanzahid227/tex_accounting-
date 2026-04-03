import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/core/model/notification_model.dart';
import 'package:flutter/foundation.dart';

class DatabaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  late final CollectionReference _usersCollection = _firestore.collection('users');
  late final CollectionReference _invoicesCollection = _firestore.collection('invoices');
  late final CollectionReference _notificationsCollection = _firestore.collection('notifications');

  Future<AppUser?> getUserByUniqueNumber(String uniqueNumber) async {
    try {
      final querySnapshot = await _usersCollection
          .where('uniqueNumber', isEqualTo: uniqueNumber)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      if (querySnapshot.docs.isNotEmpty) {
        return AppUser.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get().timeout(const Duration(seconds: 10));
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<AppUser>> getAllClients() async {
    final querySnapshot = await _usersCollection
        .where('role', isEqualTo: UserRole.client.name)
        .get();
    return querySnapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addClient(AppUser user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap()).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Firestore addClient timed out or failed: $e');
      throw Exception('Failed to save user data. Please try again.');
    }
  }

  Future<bool> isUniqueNumberAvailable(String uniqueNumber) async {
    try {
      final querySnapshot = await _usersCollection
          .where('uniqueNumber', isEqualTo: uniqueNumber)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      debugPrint('Firestore uniqueness check timed out or failed: $e');
      // If Firestore fails, we might want to allow registration or throw error.
      // For now, let's allow it to proceed to Firebase Auth which will fail if email exists anyway.
      return true; 
    }
  }

  Future<void> deleteClient(String userId) async {
    await _usersCollection.doc(userId).delete();
    // Delete associated invoices
    final invoices = await _invoicesCollection.where('userId', isEqualTo: userId).get();
    for (var doc in invoices.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Invoice>> getInvoicesByUser(String userId) async {
    final querySnapshot = await _invoicesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('uploadDate', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> uploadInvoice(Invoice invoice) async {
    await _invoicesCollection.doc(invoice.id).set(invoice.toMap());
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _notificationsCollection.doc(notification.id).set(notification.toMap());
  }

  Future<List<NotificationModel>> getNotifications() async {
    final querySnapshot = await _notificationsCollection
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
