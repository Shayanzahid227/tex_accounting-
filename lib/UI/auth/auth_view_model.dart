import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/model/user_model.dart';

class AuthViewModel extends BaseViewModel {
  final AuthServices _authServices;

  AuthViewModel({required AuthServices authServices})
    : _authServices = authServices;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<AppUser?> login(String uniqueNumber) async {
    setState(ViewState.busy);
    _errorMessage = null;
    try {
      final user = await _authServices.login(uniqueNumber);
      setState(ViewState.idle);
      return user;
    } catch (e) {
      _errorMessage = e.toString();
      setState(ViewState.idle);
      return null;
    }
  }
}
