import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/upload_invoice/invoice_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/UI/client/my_invoices_screen.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/services/file_compression_service.dart';
import 'package:girl_clan/core/services/storage_services.dart';
import 'package:provider/provider.dart';

class YearlyInvoicesScreen extends StatelessWidget {
  const YearlyInvoicesScreen({super.key, this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    final clientName = authServices.currentUser?.name ?? 'Client';

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
                'Invoice Library',
                style: style20B.copyWith(color: whiteColor),
              ),
              Text(
                'Welcome, $clientName',
                style: style12N.copyWith(color: greyBorderColor),
              ),
            ],
          ),
          backgroundColor: Colors.deepPurple[900],
          elevation: 0,
          centerTitle: true,
          leading:
              userId != null
                  ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: whiteColor,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                  : null,
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

                final invoices = snapshot.data ?? [];

                final Set<int> uniqueYears = {DateTime.now().year};
                for (var inv in invoices) {
                  uniqueYears.add(inv.uploadDate.year);
                }
                final List<int> sortedYears =
                    uniqueYears.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  itemCount: sortedYears.length,
                  itemBuilder: (context, index) {
                    final year = sortedYears[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.folder_shared_rounded,
                            color: primaryColor,
                            size: 24.sp,
                          ),
                        ),
                        title: Text('$year', style: style16B),
                        subtitle: Text(
                          'View records for $year',
                          style: style12N.copyWith(color: greyBorderColor),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                          color: primaryColor,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MyInvoicesScreen(
                                    userId: userId,
                                    selectedYear: year,
                                  ),
                            ),
                          );
                        },
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
