import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:girl_clan/core/model/invoice_model.dart';

class RemoteInvoiceFileService {
  Future<File> downloadToCache({
    required Invoice invoice,
    void Function(double progress)? onProgress,
  }) async {
    final url = invoice.fileUrl;
    if (url == null || url.isEmpty) {
      throw Exception('Missing file URL for this invoice.');
    }

    final cacheDir = await getTemporaryDirectory();
    final invoiceDir = Directory(p.join(cacheDir.path, 'prime_tax_invoices'));
    if (!await invoiceDir.exists()) {
      await invoiceDir.create(recursive: true);
    }

    final baseName = (invoice.fileName?.trim().isNotEmpty ?? false)
        ? invoice.fileName!.trim()
        : '${invoice.id}.${invoice.isImage ? 'jpg' : 'bin'}';

    final targetName =
        invoice.isCompressed && !invoice.isImage ? _stripGz(baseName) : baseName;
    final outFile = File(p.join(invoiceDir.path, '${invoice.id}_$targetName'));

    final bytes = await _downloadBytes(url: url, onProgress: onProgress);

    if (invoice.isCompressed && !invoice.isImage) {
      final decoded = GZipDecoder().decodeBytes(bytes);
      await outFile.writeAsBytes(decoded, flush: true);
      return outFile;
    }

    await outFile.writeAsBytes(bytes, flush: true);
    return outFile;
  }

  Future<Uint8List> _downloadBytes({
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Download failed (${res.statusCode}).');
      }

      final total = res.contentLength;
      final chunks = <int>[];
      var received = 0;

      await for (final chunk in res) {
        chunks.addAll(chunk);
        received += chunk.length;
        if (onProgress != null && total > 0) {
          onProgress(received / total);
        }
      }

      return Uint8List.fromList(chunks);
    } finally {
      client.close(force: true);
    }
  }

  String _stripGz(String name) {
    return name.toLowerCase().endsWith('.gz') ? name.substring(0, name.length - 3) : name;
  }
}

