import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/others/base_view_model.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/services/file_compression_service.dart';
import 'package:girl_clan/core/services/storage_services.dart';
import 'package:path/path.dart' as p;
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class InvoiceViewModel extends BaseViewModel {
  final DatabaseServices _databaseServices;
  final AuthServices _authServices;
  final StorageServices _storageServices;
  final FileCompressionService _compressionService;
  final ImagePicker _picker = ImagePicker();

  InvoiceViewModel({
    required DatabaseServices databaseServices,
    required AuthServices authServices,
    required StorageServices storageServices,
    required FileCompressionService compressionService,
  }) : _databaseServices = databaseServices,
       _authServices = authServices,
       _storageServices = storageServices,
       _compressionService = compressionService;

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

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _lastUploadError;
  String? get lastUploadError => _lastUploadError;

  Future<bool> uploadInvoice() async {
    if ((_selectedImage == null && _selectedDocument == null) ||
        _selectedType == null) {
      _lastUploadError = 'Please select a file and category first.';
      return false;
    }

    setState(ViewState.busy);
    try {
      final user = _authServices.currentUser;
      if (user == null) {
        _lastUploadError = 'Session expired. Please login again.';
        setState(ViewState.idle);
        return false;
      }

      _uploadProgress = 0.0;
      _lastUploadError = null;
      notifyListeners();

      final isImage = _selectedImage != null;
      final localPath = isImage ? _selectedImage!.path : _selectedDocument!.path;
      if (localPath == null || localPath.isEmpty) {
        _lastUploadError = 'Could not access the selected file.';
        setState(ViewState.idle);
        return false;
      }

      final sourceFile = File(localPath);
      final exists = await sourceFile.exists();
      if (!exists) {
        _lastUploadError = 'Selected file is not found on device storage.';
        setState(ViewState.idle);
        return false;
      }

      final originalFileName = isImage
          ? p.basename(_selectedImage!.path)
          : (_selectedDocument!.name);

      debugPrint(
        '[InvoiceUpload] start user=${user.id} isImage=$isImage localPath=$localPath name=$originalFileName size=${await sourceFile.length()}',
      );

      final payload = await _compressionService.prepareForUpload(
        sourceFile: sourceFile,
        isImage: isImage,
        originalFileName: originalFileName,
      );

      final invoiceId = const Uuid().v4();
      final storagePath =
          'invoices/${user.id}/$invoiceId/${payload.storageFileName}';

      debugPrint(
        '[InvoiceUpload] prepared invoiceId=$invoiceId storagePath=$storagePath originalBytes=${payload.originalSizeBytes} uploadedBytes=${payload.uploadedSizeBytes} compressed=${payload.isCompressed} contentType=${payload.contentType}',
      );

      final downloadUrl = await _storageServices.uploadBytes(
        storagePath: storagePath,
        bytes: Uint8List.fromList(payload.bytes),
        contentType: payload.contentType,
        customMetadata: {
          'invoiceId': invoiceId,
          'userId': user.id,
          'originalFileName': payload.originalFileName,
          'originalContentType': payload.originalContentType,
          'isCompressed': payload.isCompressed.toString(),
          'originalSizeBytes': payload.originalSizeBytes.toString(),
          'uploadedSizeBytes': payload.uploadedSizeBytes.toString(),
        },
        onProgress: (p) {
          _uploadProgress = p.clamp(0.0, 1.0);
          notifyListeners();
        },
      );

      debugPrint('[InvoiceUpload] storage upload complete url=$downloadUrl');

      final invoice = Invoice(
        id: invoiceId,
        userId: user.id,
        // Keep local path only as a legacy fallback; the app should render from fileUrl.
        imageUrl: localPath,
        fileUrl: downloadUrl,
        storagePath: storagePath,
        uploadDate: _selectedDate,
        isImage: isImage,
        fileName: isImage ? payload.storageFileName : _selectedDocument?.name,
        type: _selectedType!,
        uploadedContentType: payload.contentType,
        originalContentType: payload.originalContentType,
        isCompressed: payload.isCompressed,
        originalSizeBytes: payload.originalSizeBytes,
        uploadedSizeBytes: payload.uploadedSizeBytes,
      );

      try {
        await _databaseServices.uploadInvoice(invoice);
      } catch (e) {
        debugPrint('[InvoiceUpload] firestore write failed, cleaning storage path=$storagePath err=$e');
        await _storageServices.deleteByPath(storagePath);
        rethrow;
      }
      debugPrint('[InvoiceUpload] firestore write complete invoiceId=$invoiceId');
      clearSelection();
      setState(ViewState.idle);
      return true;
    } catch (e, st) {
      debugPrint('[InvoiceUpload] FAILED: $e');
      debugPrintStack(stackTrace: st);
      _lastUploadError = e.toString().replaceAll('Exception: ', '');
      setState(ViewState.idle);
      notifyListeners();
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

  Stream<List<Invoice>> streamInvoicesByUserId(String userId) {
    return _databaseServices.streamInvoicesByUser(userId);
  }

  Stream<List<Invoice>> streamMyInvoices() {
    final user = _authServices.currentUser;
    if (user == null) return const Stream<List<Invoice>>.empty();
    return _databaseServices.streamInvoicesByUser(user.id);
  }
}
