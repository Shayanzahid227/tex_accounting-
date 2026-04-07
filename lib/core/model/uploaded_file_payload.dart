class UploadedFilePayload {
  final List<int> bytes;
  final String storageFileName;
  final String originalFileName;
  final String contentType;
  final String originalContentType;
  final bool isCompressed;
  final int originalSizeBytes;
  final int uploadedSizeBytes;

  const UploadedFilePayload({
    required this.bytes,
    required this.storageFileName,
    required this.originalFileName,
    required this.contentType,
    required this.originalContentType,
    required this.isCompressed,
    required this.originalSizeBytes,
    required this.uploadedSizeBytes,
  });
}

