import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class InvoiceViewModel extends BaseViewModel {
  final DatabaseServices _databaseServices;
  final AuthServices _authServices;
  final ImagePicker _picker = ImagePicker();

  InvoiceViewModel({
    required DatabaseServices databaseServices,
    required AuthServices authServices,
  }) : _databaseServices = databaseServices,
       _authServices = authServices;

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      _selectedImage = image;
      notifyListeners();
    }
  }

  Future<bool> uploadInvoice() async {
    if (_selectedImage == null) return false;

    setState(ViewState.busy);
    try {
      final user = _authServices.currentUser;
      if (user == null) return false;

      final invoice = Invoice(
        id: const Uuid().v4(),
        userId: user.id,
        imageUrl: _selectedImage!.path, // In prototype, using local path as URL
        uploadDate: _selectedDate,
      );

      await _databaseServices.uploadInvoice(invoice);
      _selectedImage = null;
      setState(ViewState.idle);
      return true;
    } catch (e) {
      setState(ViewState.idle);
      return false;
    }
  }

  Future<List<Invoice>> getInvoicesByUserId(String userId) async {
    return await _databaseServices.getInvoicesByUser(userId);
  }

  Future<List<Invoice>> getMyInvoices() async {
    final user = _authServices.currentUser;
    if (user == null) return [];
    return await _databaseServices.getInvoicesByUser(user.id);
  }
}
