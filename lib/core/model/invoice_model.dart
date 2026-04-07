import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceType { bank, invoice, payroll, other }

class Invoice {
  final String id;
  final String userId;
  /// Legacy/local path (older builds). New builds should use [fileUrl].
  final String? imageUrl;
  /// Firebase Storage download URL.
  final String? fileUrl;
  /// Firebase Storage full path (e.g. `invoices/{uid}/{invoiceId}/file.ext`).
  final String? storagePath;
  final DateTime uploadDate;
  final bool isImage;
  final String? fileName;
  final InvoiceType type;
  /// MIME type of the uploaded blob in Storage (e.g. image/jpeg, application/gzip).
  final String? uploadedContentType;
  /// MIME type of the original file before compression (e.g. application/pdf).
  final String? originalContentType;
  /// True when the stored blob is compressed (jpeg recompress for images, gzip for docs).
  final bool isCompressed;
  final int? originalSizeBytes;
  final int? uploadedSizeBytes;

  Invoice({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.fileUrl,
    this.storagePath,
    required this.uploadDate,
    this.isImage = true,
    this.fileName,
    required this.type,
    this.uploadedContentType,
    this.originalContentType,
    this.isCompressed = false,
    this.originalSizeBytes,
    this.uploadedSizeBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      // Keep `imageUrl` for backwards compatibility with existing UI/db.
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'storagePath': storagePath,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'isImage': isImage,
      'fileName': fileName,
      'type': type.name,
      'uploadedContentType': uploadedContentType,
      'originalContentType': originalContentType,
      'isCompressed': isCompressed,
      'originalSizeBytes': originalSizeBytes,
      'uploadedSizeBytes': uploadedSizeBytes,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'],
      fileUrl: map['fileUrl'],
      storagePath: map['storagePath'],
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      isImage: map['isImage'] ?? true,
      fileName: map['fileName'],
      type: InvoiceType.values.byName(map['type'] ?? 'other'),
      uploadedContentType: map['uploadedContentType'],
      originalContentType: map['originalContentType'],
      isCompressed: map['isCompressed'] ?? false,
      originalSizeBytes: map['originalSizeBytes'],
      uploadedSizeBytes: map['uploadedSizeBytes'],
    );
  }
}
