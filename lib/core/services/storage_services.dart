import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageServices {
  final FirebaseStorage _storage;

  StorageServices({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads bytes to Storage and returns the download URL.
  /// [onProgress] provides 0.0-1.0 progress.
  Future<String> uploadBytes({
    required String storagePath,
    required Uint8List bytes,
    required String contentType,
    required Map<String, String> customMetadata,
    void Function(double progress)? onProgress,
  }) async {
    debugPrint(
      '[Storage] putData path=$storagePath bytes=${bytes.length} contentType=$contentType',
    );
    final ref = _storage.ref(storagePath);
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: contentType, customMetadata: customMetadata),
    );

    StreamSubscription<TaskSnapshot>? sub;
    if (onProgress != null) {
      sub = uploadTask.snapshotEvents.listen((snap) {
        final total = snap.totalBytes;
        final transferred = snap.bytesTransferred;
        if (total > 0) onProgress(transferred / total);
      });
    }

    try {
      await uploadTask;
    } on FirebaseException catch (e, st) {
      debugPrint('[Storage] FirebaseException code=${e.code} message=${e.message}');
      debugPrintStack(stackTrace: st);
      rethrow;
    } catch (e, st) {
      debugPrint('[Storage] upload error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    } finally {
      await sub?.cancel();
    }

    final url = await ref.getDownloadURL();
    debugPrint('[Storage] downloadUrl ok');
    return url;
  }

  Future<void> deleteByPath(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      debugPrint('[Storage] delete failed path=$storagePath err=$e');
    }
  }
}

