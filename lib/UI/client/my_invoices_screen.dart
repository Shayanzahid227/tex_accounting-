import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/UI/client/monthly_invoices_grid.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyInvoicesScreen extends StatelessWidget {
  const MyInvoicesScreen({super.key, this.userId, required this.selectedYear});
  final String? userId;
  final int selectedYear;

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context);
    final clientName = authServices.currentUser?.name ?? 'Client';

    final List<String> months = List.generate(
      12,
      (index) => DateFormat('MMMM').format(DateTime(selectedYear, index + 1)),
    );

    return Scaffold(
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
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        itemCount: months.length,
        itemBuilder: (context, index) {
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
                  Icons.folder_copy_rounded,
                  color: primaryColor,
                  size: 24.sp,
                ),
              ),
              title: Text(months[index], style: style16B),
              subtitle: Text(
                'View your monthly records',
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
                        (context) => MonthlyInvoicesGrid(
                          monthName: months[index],
                          monthIndex: index + 1,
                          userId: userId,
                          selectedYear: selectedYear,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
