import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

import 'package:girl_clan/core/model/uploaded_file_payload.dart';

class FileCompressionService {
  static const int _maxImageDimension = 1920;
  static const int _jpegQuality = 75;

  /// - Images: recompress to JPEG (smaller + consistent).
  /// - Documents: gzip-compress only if it meaningfully reduces size.
  Future<UploadedFilePayload> prepareForUpload({
    required File sourceFile,
    required bool isImage,
    required String? originalFileName,
  }) async {
    final resolvedOriginalName =
        (originalFileName?.trim().isNotEmpty ?? false)
            ? originalFileName!.trim()
            : p.basename(sourceFile.path);

    final originalBytes = await sourceFile.readAsBytes();
    final originalSize = originalBytes.length;

    if (isImage) {
      // Compression plugin is not supported on all platforms (e.g. desktop/web).
      // If unavailable, we fall back to uploading the original bytes.
      final canCompressImage =
          !kIsWeb && (Platform.isAndroid || Platform.isIOS);

      final compressed =
          canCompressImage ? await _compressImageToJpeg(originalBytes) : originalBytes;

      final storageFileName =
          (canCompressImage && compressed != originalBytes)
              ? _replaceExtension(resolvedOriginalName, 'jpg')
              : resolvedOriginalName;

      return UploadedFilePayload(
        bytes: compressed,
        storageFileName: storageFileName,
        originalFileName: resolvedOriginalName,
        contentType:
            (canCompressImage && compressed != originalBytes)
                ? 'image/jpeg'
                : (_guessContentTypeFromName(resolvedOriginalName) ??
                    'application/octet-stream'),
        originalContentType: _guessContentTypeFromName(resolvedOriginalName) ??
            'image/*',
        isCompressed: canCompressImage && compressed != originalBytes,
        originalSizeBytes: originalSize,
        uploadedSizeBytes: compressed.length,
      );
    }

    // Documents: try gzip, keep original if gzip isn't worth it.
    final gzipped = GZipEncoder().encode(originalBytes);
    if (gzipped.isEmpty || originalSize == 0) {
      return UploadedFilePayload(
        bytes: originalBytes,
        storageFileName: resolvedOriginalName,
        originalFileName: resolvedOriginalName,
        contentType: _guessContentTypeFromName(resolvedOriginalName) ??
            'application/octet-stream',
        originalContentType: _guessContentTypeFromName(resolvedOriginalName) ??
            'application/octet-stream',
        isCompressed: false,
        originalSizeBytes: originalSize,
        uploadedSizeBytes: originalSize,
      );
    }

    final savedRatio = 1 - (gzipped.length / originalSize);
    final isWorthIt = savedRatio >= 0.05; // at least 5% smaller
    if (!isWorthIt) {
      return UploadedFilePayload(
        bytes: originalBytes,
        storageFileName: resolvedOriginalName,
        originalFileName: resolvedOriginalName,
        contentType: _guessContentTypeFromName(resolvedOriginalName) ??
            'application/octet-stream',
        originalContentType: _guessContentTypeFromName(resolvedOriginalName) ??
            'application/octet-stream',
        isCompressed: false,
        originalSizeBytes: originalSize,
        uploadedSizeBytes: originalSize,
      );
    }

    return UploadedFilePayload(
      bytes: gzipped,
      storageFileName: '${resolvedOriginalName}.gz',
      originalFileName: resolvedOriginalName,
      contentType: 'application/gzip',
      originalContentType: _guessContentTypeFromName(resolvedOriginalName) ??
          'application/octet-stream',
      isCompressed: true,
      originalSizeBytes: originalSize,
      uploadedSizeBytes: gzipped.length,
    );
  }

  Future<List<int>> _compressImageToJpeg(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: _jpegQuality,
        format: CompressFormat.jpeg,
        minWidth: _maxImageDimension,
        minHeight: _maxImageDimension,
        keepExif: false,
      );

      if (result.isEmpty) return bytes;
      // Only use compressed bytes when it is actually smaller.
      if (result.length >= bytes.length) return bytes;
      return result;
    } on MissingPluginException {
      // Plugin not registered on this platform/build.
      return bytes;
    } catch (_) {
      return bytes;
    }
  }

  String _replaceExtension(String fileName, String newExtWithoutDot) {
    final base = p.basenameWithoutExtension(fileName);
    return '$base.$newExtWithoutDot';
  }

  String? _guessContentTypeFromName(String name) {
    final ext = p.extension(name).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.txt':
        return 'text/plain';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return null;
    }
  }
}

