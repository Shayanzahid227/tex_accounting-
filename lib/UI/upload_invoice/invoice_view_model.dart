import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

  PlatformFile? _selectedDocument;
  PlatformFile? get selectedDocument => _selectedDocument;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  InvoiceType? _selectedType;
  InvoiceType? get selectedType => _selectedType;

  void setSelectedType(InvoiceType type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    _pickerError = null;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _selectedImage = image;
        _selectedDocument = null; // Clear document if image is picked
        notifyListeners();
      }
    } catch (e) {
      _pickerError = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }

  String? _pickerError;
  String? get pickerError => _pickerError;

  Future<void> pickDocument() async {
    _pickerError = null;
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        _selectedDocument = result.files.first;
        _selectedImage = null; // Clear image if document is picked
        notifyListeners();
      } else {
        // User cancelled the picker
        print('User cancelled file picker');
      }
    } catch (e) {
      _pickerError = 'Failed to pick document: ${e.toString()}';
      print(_pickerError);
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedImage = null;
    _selectedDocument = null;
    _selectedType = null;
    notifyListeners();
  }

  Future<bool> uploadInvoice() async {
    if ((_selectedImage == null && _selectedDocument == null) ||
        _selectedType == null) {
      return false;
    }

    setState(ViewState.busy);
    try {
      final user = _authServices.currentUser;
      if (user == null) return false;

      final invoice = Invoice(
        id: const Uuid().v4(),
        userId: user.id,
        imageUrl:
            _selectedImage != null
                ? _selectedImage!.path
                : _selectedDocument!.path!,
        uploadDate: _selectedDate,
        isImage: _selectedImage != null,
        fileName: _selectedDocument?.name,
        type: _selectedType!,
      );

      await _databaseServices.uploadInvoice(invoice);
      clearSelection();
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
