import 'package:girl_clan/core/model/invoice_model.dart';

/// Admin-only: holds at most **one** client's invoice list in memory — whichever
/// user the admin is viewing last. Opening another client replaces it.
/// Does not prefetch all users; bounded memory (same order as one client list).
/// Cleared on admin logout; never touches Firestore.
class AdminInvoiceViewCache {
  AdminInvoiceViewCache._();
  static final AdminInvoiceViewCache instance = AdminInvoiceViewCache._();

  String? _clientUserId;
  List<Invoice>? _invoices;

  List<Invoice>? get(String clientUserId) {
    if (_clientUserId != clientUserId || _invoices == null) return null;
    return List<Invoice>.from(_invoices!);
  }

  void set(String clientUserId, List<Invoice> invoices) {
    _clientUserId = clientUserId;
    _invoices = List<Invoice>.from(invoices);
  }

  void clear() {
    _clientUserId = null;
    _invoices = null;
  }
}
