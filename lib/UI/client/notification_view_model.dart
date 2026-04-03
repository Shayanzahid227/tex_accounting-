import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/model/notification_model.dart';

class NotificationViewModel extends BaseViewModel {
  final DatabaseServices _databaseServices;

  NotificationViewModel({required DatabaseServices databaseServices})
    : _databaseServices = databaseServices;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    setState(ViewState.busy);
    try {
      _notifications = await _databaseServices.getNotifications();
      setState(ViewState.idle);
    } catch (e) {
      setState(ViewState.idle);
      print('Error fetching notifications: $e');
    }
  }
}
