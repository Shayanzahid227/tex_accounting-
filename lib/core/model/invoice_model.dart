import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceType { bank, invoice, payroll, other }

class Invoice {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime uploadDate;
  final bool isImage;
  final String? fileName;
  final InvoiceType type;

  Invoice({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.uploadDate,
    this.isImage = true,
    this.fileName,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'isImage': isImage,
      'fileName': fileName,
      'type': type.name,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      isImage: map['isImage'] ?? true,
      fileName: map['fileName'],
      type: InvoiceType.values.byName(map['type'] ?? 'other'),
    );
  }
}
