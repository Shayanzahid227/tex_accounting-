import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/auth/login_screen.dart';
import 'package:girl_clan/UI/upload_invoice/invoice_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/custom_widget/custom_button.dart';
import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UploadInvoiceScreen extends StatelessWidget {
  const UploadInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context);
    final clientName = authServices.currentUser?.name ?? 'Client';

    return ChangeNotifierProvider(
      create:
          (context) => InvoiceViewModel(
            databaseServices: Provider.of(context, listen: false),
            authServices: Provider.of(context, listen: false),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Upload Invoice',
            style: style20B.copyWith(color: whiteColor),
          ),
          backgroundColor: Colors.deepPurple[900],
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: redColor),
              onPressed: () {
                authServices.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: Consumer<InvoiceViewModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Icon(
                              Icons.person,
                              color: whiteColor,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,', //
                                style: style12N.copyWith(
                                  color: greyBorderColor,
                                ),
                              ),
                              Text(
                                clientName,
                                style: style16B.copyWith(color: ternaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      'Submit New Invoice',
                      style: style18B.copyWith(color: whiteColor),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please select a clear photo of your invoice',
                      style: style14.copyWith(color: greyBorderColor),
                    ),
                    SizedBox(height: 24.h),
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(context, model),
                      child: Container(
                        height: 220.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: offWhiteColor,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child:
                            model.selectedImage == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(15.sp),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 40.sp,
                                        color: primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Tap to Select Image',
                                      style: style14B.copyWith(
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'Camera or Gallery',
                                      style: style12.copyWith(
                                        color: greyBorderColor,
                                      ),
                                    ),
                                  ],
                                )
                                : Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: Image.file(
                                        File(model.selectedImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Logic to clear image can be added to viewmodel
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: redColor,
                                          radius: 12.r,
                                          child: Icon(
                                            Icons.close,
                                            color: whiteColor,
                                            size: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text('Invoice Date', style: style16B),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: model.selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primaryColor,
                                  onPrimary: whiteColor,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != model.selectedDate) {
                          model.setSelectedDate(picked);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: offWhiteColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              DateFormat(
                                'MMMM dd, yyyy',
                              ).format(model.selectedDate),
                              style: style14B.copyWith(color: primaryColor),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: primaryColor,
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    model.state == ViewState.busy
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                          onTap: () async {
                            final success = await model.uploadInvoice();
                            if (success) {
                              SnackBarUtils.showTopSnackBar(
                                context,
                                'Invoice submitted successfully!',
                                backgroundColor: primaryColor,
                              );
                            } else if (model.selectedImage == null) {
                              SnackBarUtils.showTopSnackBar(
                                context,
                                'Please select an image first',
                              );
                            }
                          },
                          text: 'Submit Invoice',
                          backgroundColor: primaryColor,
                        ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, InvoiceViewModel model) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Image Source', style: style18B),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        model.pickImage(ImageSource.camera);
                      },
                    ),
                    _sourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        model.pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 30.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: style14B),
        ],
      ),
    );
  }
}
