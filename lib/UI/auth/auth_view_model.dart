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

  AppUser? get currentUser => _authServices.currentUser;

  Future<AppUser?> login(String identifier, {String? password}) async {
    setState(ViewState.busy);
    _errorMessage = null;
    try {
      final user = await _authServices.login(identifier, password: password);
      setState(ViewState.idle);
      return user;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      setState(ViewState.idle);
      return null;
    }
  }

  Future<AppUser?> register(String name, String email, String password) async {
    setState(ViewState.busy);
    _errorMessage = null;
    try {
      final user = await _authServices.register(name, email, password);
      setState(ViewState.idle);
      return user;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      setState(ViewState.idle);
      return null;
    }
  }

  Future<void> checkSession() async {
    setState(ViewState.busy);
    await _authServices.checkSession();
    setState(ViewState.idle);
  }
}
