import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/core/model/invoice_model.dart';

class DatabaseServices {
  final List<AppUser> _users = [
    AppUser(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      uniqueNumber: 'abc123',
      role: UserRole.client,
    ),
    AppUser(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      uniqueNumber: 'xyz789',
      role: UserRole.client,
    ),
  ];

  final List<Invoice> _invoices = [];

  Future<AppUser?> getUserByUniqueNumber(String uniqueNumber) async {
    try {
      return _users.firstWhere((user) => user.uniqueNumber == uniqueNumber);
    } catch (e) {
      return null;
    }
  }

  Future<List<AppUser>> getAllClients() async {
    return _users.where((user) => user.role == UserRole.client).toList();
  }

  Future<void> addClient(AppUser user) async {
    _users.add(user);
  }

  Future<void> deleteClient(String userId) async {
    _users.removeWhere((user) => user.id == userId);
    _invoices.removeWhere((invoice) => invoice.userId == userId);
  }

  Future<List<Invoice>> getInvoicesByUser(String userId) async {
    return _invoices.where((invoice) => invoice.userId == userId).toList();
  }

  Future<void> uploadInvoice(Invoice invoice) async {
    _invoices.add(invoice);
  }
}
