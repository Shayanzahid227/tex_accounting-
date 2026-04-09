import 'package:girl_clan/core/model/invoice_model.dart';

/// Holds the current client's invoice list in memory for the active app session only.
/// Cleared on logout and when the app process is tearing down — never touches Firestore.
class InvoiceSessionCache {
  InvoiceSessionCache._();
  static final InvoiceSessionCache instance = InvoiceSessionCache._();

  String? _userId;
  List<Invoice>? _invoices;

  /// Latest snapshot for [userId], or null if none / different user.
  List<Invoice>? getForUser(String userId) {
    if (_userId != userId || _invoices == null) return null;
    return List<Invoice>.from(_invoices!);
  }

  void set(String userId, List<Invoice> invoices) {
    _userId = userId;
    _invoices = List<Invoice>.from(invoices);
  }

  void clear() {
    _userId = null;
    _invoices = null;
  }
}
