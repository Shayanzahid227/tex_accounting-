import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/upload_invoice/invoice_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/UI/client/invoice_preview_screen.dart';
import 'package:girl_clan/core/services/file_compression_service.dart';
import 'package:girl_clan/core/services/storage_services.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/services/invoice_session_cache.dart';
import 'package:girl_clan/core/services/admin_invoice_view_cache.dart';
import 'package:provider/provider.dart';

class MonthlyInvoicesGrid extends StatelessWidget {
  final String monthName;
  final int monthIndex;
  final String? userId;
  final int selectedYear;
  final InvoiceType category;

  const MonthlyInvoicesGrid({
    super.key,
    required this.monthName,
    required this.monthIndex,
    this.userId,
    required this.selectedYear,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => InvoiceViewModel(
            databaseServices: Provider.of(context, listen: false),
            authServices: Provider.of(context, listen: false),
            storageServices: Provider.of<StorageServices>(context, listen: false),
            compressionService:
                Provider.of<FileCompressionService>(context, listen: false),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                '${category == InvoiceType.bank
                    ? 'Bank Statement'
                    : category == InvoiceType.invoice
                    ? 'Regular'
                    : category == InvoiceType.payroll
                    ? 'Payroll'
                    : 'Other'} Invoices',
                style: style20B.copyWith(color: whiteColor),
              ),
              Text(
                '$monthName $selectedYear',
                style: style12N.copyWith(color: greyBorderColor),
              ),
            ],
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
        ),
        body: Consumer<InvoiceViewModel>(
          builder: (context, model, child) {
            final authServices = Provider.of<AuthServices>(context, listen: false);
            final selfId = authServices.currentUser?.id ?? '';
            final List<Invoice>? initialFromCache;
            if (userId != null) {
              initialFromCache = AdminInvoiceViewCache.instance.get(userId!);
            } else {
              final cacheKey = selfId.isNotEmpty ? selfId : null;
              initialFromCache =
                  cacheKey != null
                      ? InvoiceSessionCache.instance.getForUser(cacheKey)
                      : null;
            }

            return StreamBuilder<List<Invoice>>(
              initialData: initialFromCache,
              stream:
                  userId != null
                      ? model.streamInvoicesByUserId(userId!)
                      : model.streamMyInvoices(),
              builder: (context, snapshot) {
                final streamList = snapshot.data;
                if (userId != null && streamList != null) {
                  AdminInvoiceViewCache.instance.set(userId!, streamList);
                } else if (userId == null &&
                    streamList != null &&
                    selfId.isNotEmpty) {
                  InvoiceSessionCache.instance.set(selfId, streamList);
                }
                if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 64.sp,
                            color: redColor,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Unable to load invoices',
                            style: style16B.copyWith(color: whiteColor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            snapshot.error.toString(),
                            style: style12N.copyWith(
                              color: greyBorderColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final invoices =
                    snapshot.data
                        ?.where(
                          (inv) =>
                              inv.uploadDate.month == monthIndex &&
                              inv.uploadDate.year == selectedYear &&
                              inv.type == category,
                        )
                        .toList() ??
                    [];

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60.sp,
                          color: greyBorderColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No records found for $monthName',
                          style: style16N.copyWith(color: greyBorderColor),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => InvoicePreviewScreen(
                                  invoice: invoices[index],
                                ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: blackColor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r),
                                ),
                                child:
                                    invoices[index].isImage
                                        ? Hero(
                                          tag:
                                              invoices[index].fileUrl ??
                                              invoices[index].imageUrl ??
                                              invoices[index].id,
                                          child: _InvoiceImageThumb(
                                            invoice: invoices[index],
                                          ),
                                        )
                                        : Container(
                                          color: primaryColor.withOpacity(0.05),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.description_rounded,
                                                  size: 60.sp,
                                                  color: primaryColor,
                                                ),
                                                SizedBox(height: 8.h),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                  ),
                                                  child: Text(
                                                    invoices[index].fileName ??
                                                        'Document',
                                                    style: style12B.copyWith(
                                                      color: primaryColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Invoice #${index + 1}',
                                    style: style12.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.zoom_in_rounded,
                                    size: 16.sp,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _InvoiceImageThumb extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceImageThumb({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final url = invoice.fileUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: primaryColor.withOpacity(0.05),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stack) {
          return Container(
            color: primaryColor.withOpacity(0.05),
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined, color: primaryColor),
          );
        },
      );
    }

    final local = invoice.imageUrl;
    if (local != null && local.isNotEmpty) {
      return Image.file(File(local), fit: BoxFit.cover);
    }

    return Container(
      color: primaryColor.withOpacity(0.05),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: primaryColor),
    );
  }
}
