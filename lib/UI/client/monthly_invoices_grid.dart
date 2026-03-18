import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/upload_invoice/invoice_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/UI/client/invoice_preview_screen.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:provider/provider.dart';

class MonthlyInvoicesGrid extends StatelessWidget {
  final String monthName;
  final int monthIndex;
  final String? userId;

  const MonthlyInvoicesGrid({
    super.key,
    required this.monthName,
    required this.monthIndex,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    final clientName = authServices.currentUser?.name ?? 'Client';

    return ChangeNotifierProvider(
      create:
          (context) => InvoiceViewModel(
            databaseServices: Provider.of(context, listen: false),
            authServices: Provider.of(context, listen: false),
          ),
      child: Scaffold(
        backgroundColor: offWhiteColor,
        appBar: AppBar(
          title: Column(
            children: [
              Text('$monthName Invoices', style: style20B),
              Text(
                clientName,
                style: style12N.copyWith(color: greyBorderColor),
              ),
            ],
          ),
          backgroundColor: whiteColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<InvoiceViewModel>(
          builder: (context, model, child) {
            return FutureBuilder<List<Invoice>>(
              future:
                  userId != null
                      ? model.getInvoicesByUserId(userId!)
                      : model.getMyInvoices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final invoices =
                    snapshot.data
                        ?.where((inv) => inv.uploadDate.month == monthIndex)
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
                                child: Image.file(
                                  File(invoices[index].imageUrl),
                                  fit: BoxFit.cover,
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
