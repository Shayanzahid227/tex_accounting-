import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/client/monthly_invoices_grid.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/model/invoice_model.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:provider/provider.dart';

class InvoiceCategoryScreen extends StatelessWidget {
  final String monthName;
  final int monthIndex;
  final String? userId;
  final int selectedYear;

  const InvoiceCategoryScreen({
    super.key,
    required this.monthName,
    required this.monthIndex,
    this.userId,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context);
    final clientName = authServices.currentUser?.name ?? 'Client';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              monthName,
              style: style20B.copyWith(color: whiteColor),
            ),
            Text(
              clientName,
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Record Type',
              style: style18B.copyWith(color: whiteColor),
            ),
            SizedBox(height: 8.h),
            Text(
              'View your $monthName $selectedYear records by category',
              style: style14.copyWith(color: greyBorderColor),
            ),
            SizedBox(height: 32.h),
            _categoryFolder(
              context,
              title: 'Bank Statements',
              subtitle: 'Bank statements and related docs',
              type: InvoiceType.bank,
              icon: Icons.account_balance_rounded,
              color: Colors.blue,
            ),
            SizedBox(height: 16.h),
            _categoryFolder(
              context,
              title: 'Invoices',
              subtitle: 'General business invoices',
              type: InvoiceType.invoice,
              icon: Icons.receipt_long_rounded,
              color: Colors.amber,
            ),
            SizedBox(height: 16.h),
            _categoryFolder(
              context,
              title: 'Payroll',
              subtitle: 'Employee payroll and tax records',
              type: InvoiceType.payroll,
              icon: Icons.payments_rounded,
              color: Colors.purple,
            ),
            SizedBox(height: 16.h),
            _categoryFolder(
              context,
              title: 'Other',
              subtitle: 'Other tax-related documents',
              type: InvoiceType.other,
              icon: Icons.more_horiz_rounded,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryFolder(
    BuildContext context, {
    required String title,
    required String subtitle,
    required InvoiceType type,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MonthlyInvoicesGrid(
                  monthName: monthName,
                  monthIndex: monthIndex,
                  userId: userId,
                  selectedYear: selectedYear,
                  category: type,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  color: color,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20.sp),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.sp),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(icon, color: color, size: 28.sp),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: style16B),
                              SizedBox(height: 4.h),
                              Text(
                                subtitle,
                                style: style12N.copyWith(
                                  color: greyBorderColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                          color: greyBorderColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
