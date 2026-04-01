enum InvoiceType { bank, invoice, other }

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
}
