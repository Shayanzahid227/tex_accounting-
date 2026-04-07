import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:intl/intl.dart';
import 'package:girl_clan/UI/client/full_screen_image_viewer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:girl_clan/custom_widget/custom_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:girl_clan/core/services/remote_invoice_file_service.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  final RemoteInvoiceFileService _remoteFileService = RemoteInvoiceFileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoice.isImage ? 'Photo Preview' : 'Document Preview',
          style: style18B.copyWith(color: whiteColor),
        ),
        backgroundColor: Colors.deepPurple[900],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: whiteColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: whiteColor),
            tooltip: 'Share/Export',
            onPressed: () => _shareFile(),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, blackColor],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child:
                  widget.invoice.isImage
                      ? Center(
                        child: GestureDetector(
                          onTap: () => _expandImage(),
                          child: Hero(
                            tag:
                                widget.invoice.fileUrl ??
                                widget.invoice.imageUrl ??
                                widget.invoice.id,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: blackColor.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: _InvoicePreviewImage(invoice: widget.invoice),
                              ),
                            ),
                          ),
                        ),
                      )
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(40.sp),
                              decoration: BoxDecoration(
                                color: whiteColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.description_rounded,
                                size: 100.sp,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.w),
                              child: Text(
                                widget.invoice.fileName ?? 'Document',
                                style: style20B.copyWith(color: whiteColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
            Container(
              padding: EdgeInsets.all(32.sp),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isDownloading) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Downloading document...',
                            style: style12B.copyWith(color: primaryColor),
                          ),
                          Text(
                            '${(_downloadProgress * 100).toInt()}%',
                            style: style12B.copyWith(color: primaryColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                          minHeight: 10.h,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ] else ...[
                      Row(
                        children: [
                          _infoItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'Upload Date',
                            value: DateFormat(
                              'MMM dd, yyyy',
                            ).format(widget.invoice.uploadDate),
                          ),
                          const Spacer(),
                          _infoItem(
                            icon: Icons.fingerprint_rounded,
                            label: 'File ID',
                            value:
                                widget.invoice.id.substring(0, 8).toUpperCase(),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                    ],
                    CustomButton(
                      onTap: _isDownloading ? () {} : () => _handleFileAction(),
                      text:
                          _isDownloading
                              ? 'Saving to Device...'
                              : widget.invoice.isImage
                              ? 'Full Screen View'
                              : 'Download and View',
                      backgroundColor:
                          _isDownloading
                              ? primaryColor.withOpacity(0.5)
                              : primaryColor,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFileAction() {
    if (widget.invoice.isImage) {
      _expandImage();
    } else {
      _downloadFile();
    }
  }

  void _expandImage() {
    final url = widget.invoice.fileUrl;
    final local = widget.invoice.imageUrl;
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder:
            (context, animation, secondaryAnimation) => FullScreenImageViewer(
              imageUrl: (url != null && url.isNotEmpty) ? url : (local ?? ''),
              tag:
                  (url != null && url.isNotEmpty)
                      ? url
                      : (local ?? widget.invoice.id),
              isNetwork: url != null && url.isNotEmpty,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _downloadFile() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // 1. Request Permissions based on Platform
      bool hasPermission = false;
      if (Platform.isAndroid) {
        // For Android 11+ (API 30+), we ideally need MANAGE_EXTERNAL_STORAGE for public folders
        // But we first try standard storage permission
        final status = await Permission.storage.request();
        hasPermission = status.isGranted;
        
        if (!hasPermission) {
          // If storage permission is denied, try MANAGE_EXTERNAL_STORAGE (All Files Access)
          final manageStatus = await Permission.manageExternalStorage.request();
          hasPermission = manageStatus.isGranted;
        }
      } else {
        hasPermission = true; // iOS handles via Share UI professionally
      }

      // 2. Simulate Progress for "Neat & Clean" UX
      for (int i = 1; i <= 20; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        setState(() => _downloadProgress = i / 20);
      }

      // 3. Download from cloud (or fallback to local legacy path)
      File downloaded;
      if (widget.invoice.fileUrl != null && widget.invoice.fileUrl!.isNotEmpty) {
        downloaded = await _remoteFileService.downloadToCache(
          invoice: widget.invoice,
          onProgress: (p) {
            if (!mounted) return;
            setState(() => _downloadProgress = p.clamp(0.0, 1.0));
          },
        );
      } else {
        final legacyPath = widget.invoice.imageUrl;
        if (legacyPath == null || legacyPath.isEmpty) {
          throw Exception('File is not available.');
        }
        downloaded = File(legacyPath);
      }

      final fileName =
          widget.invoice.fileName ??
          'PrimeTax_${DateTime.now().millisecondsSinceEpoch}.${downloaded.path.split('.').last}';

      if (hasPermission && Platform.isAndroid) {
        String savePath;
        bool savedInDownloads = false;

        try {
          // Try saving to the public Download folder first
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            savePath = '${downloadsDir.path}/$fileName';
            final newFile = await downloaded.copy(savePath);
            _showSuccess(newFile.path, "Saved in Downloads");
            savedInDownloads = true;
          }
        } catch (e) {
          debugPrint('Failed to save in public Downloads: $e');
        }

        if (!savedInDownloads) {
          // Fallback to app-specific external storage (always accessible)
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            savePath = '${extDir.path}/$fileName';
            final newFile = await downloaded.copy(savePath);
            _showSuccess(newFile.path, "Saved in App External Storage");
          } else {
            // Ultimate fallback to Share sheet
            throw Exception('Could not access device storage');
          }
        }
      } else {
        // Professional fallback/standard for iOS and restricted Android
        await Share.shareXFiles([
          XFile(downloaded.path),
        ], subject: 'Prime Tax Invoice: $fileName');
      }

      setState(() => _isDownloading = false);
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: redColor,
          ),
        );
      }
      setState(() => _isDownloading = false);
    }
  }

  void _showSuccess(String path, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: whiteColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File Downloaded successfully', style: style14B),
                  Text(
                    message,
                    style: style12N.copyWith(
                      color: whiteColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        action: SnackBarAction(
          label: 'OPEN',
          textColor: whiteColor,
          onPressed: () => OpenFilex.open(path),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _shareFile() async {
    if (widget.invoice.fileUrl != null && widget.invoice.fileUrl!.isNotEmpty) {
      // Share by downloading into cache first so share sheet always works.
      final f = await _remoteFileService.downloadToCache(invoice: widget.invoice);
      await Share.shareXFiles(
        [XFile(f.path)],
        text:
            'Prime Tax Invoice - ${widget.invoice.fileName ?? 'Official Record'}',
      );
      return;
    }
    await Share.shareXFiles(
      [XFile(widget.invoice.imageUrl ?? '')],
      text:
          'Prime Tax Invoice - ${widget.invoice.fileName ?? 'Official Record'}',
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: greyBorderColor),
            SizedBox(width: 6.w),
            Text(label, style: style12N.copyWith(color: greyBorderColor)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(value, style: style14B.copyWith(color: blackColor)),
      ],
    );
  }
}

class _InvoicePreviewImage extends StatelessWidget {
  final Invoice invoice;
  const _InvoicePreviewImage({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final url = invoice.fileUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stack) {
          return const Center(child: Icon(Icons.broken_image_outlined, size: 60));
        },
      );
    }

    final local = invoice.imageUrl;
    if (local != null && local.isNotEmpty) {
      return Image.file(File(local), fit: BoxFit.contain);
    }

    return const Center(child: Icon(Icons.image_not_supported_outlined, size: 60));
  }
}
