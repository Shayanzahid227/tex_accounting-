import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/core/model/notification_model.dart';
import 'package:uuid/uuid.dart';

class AdminViewModel extends BaseViewModel {
  final DatabaseServices _databaseServices;

  AdminViewModel({required DatabaseServices databaseServices})
    : _databaseServices = databaseServices;

  List<AppUser> _clients = [];
  String _searchQuery = '';

  List<AppUser> get clients =>
      _clients
          .where(
            (user) =>
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.uniqueNumber.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchClients() async {
    setState(ViewState.busy);
    _clients = await _databaseServices.getAllClients();
    setState(ViewState.idle);
  }

  Future<bool> createClient(String name, String uniqueNumber) async {
    setState(ViewState.busy);
    try {
      final newUser = AppUser(
        id: const Uuid().v4(),
        name: name,
        uniqueNumber: uniqueNumber,
        role: UserRole.client,
      );
      await _databaseServices.addClient(newUser);
      await fetchClients();
      setState(ViewState.idle);
      return true;
    } catch (e) {
      setState(ViewState.idle);
      return false;
    }
  }

  Future<void> deleteClient(String userId) async {
    setState(ViewState.busy);
    await _databaseServices.deleteClient(userId);
    await fetchClients();
    setState(ViewState.idle);
  }

  Future<bool> sendNotification(String message) async {
    if (message.isEmpty) return false;
    setState(ViewState.busy);
    try {
      final notification = NotificationModel.createNew(message);
      await _databaseServices.addNotification(notification);
      setState(ViewState.idle);
      return true;
    } catch (e) {
      setState(ViewState.idle);
      return false;
    }
  }
}
