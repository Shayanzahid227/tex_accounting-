import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/admin/admin_view_model.dart';
import 'package:girl_clan/UI/auth/login_screen.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/constants/auth_text_feild.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/custom_widget/custom_button.dart';
import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';

class NotifyClientScreen extends StatefulWidget {
  const NotifyClientScreen({super.key});

  @override
  State<NotifyClientScreen> createState() => _NotifyClientScreenState();
}

class _NotifyClientScreenState extends State<NotifyClientScreen> {
  final TextEditingController _notificationController = TextEditingController();

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          'Notify Clients',
          style: style20B.copyWith(color: whiteColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, model, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                Container(
                  padding: EdgeInsets.all(20.sp),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 60.sp,
                    color: secondaryColor,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Send Global Notification',
                  style: style25B.copyWith(color: whiteColor, fontSize: 24.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'This message will be visible to all clients in their notification tab.',
                  style: style14.copyWith(color: greyBorderColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                Text(
                  'Notification Message',
                  style: style14B.copyWith(color: secondaryColor),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _notificationController,
                    maxLines: 5,
                    style: style16.copyWith(color: whiteColor),
                    decoration: customAuthField3.copyWith(
                      hintText: 'Enter your message here...',
                      hintStyle: style14.copyWith(
                        color: greyBorderColor.withOpacity(0.5),
                      ),
                      fillColor: whiteColor.withOpacity(0.05),
                      filled: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 80.h),
                        child: const Icon(
                          Icons.message_rounded,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                model.state == ViewState.busy
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                      textColor: primaryColor,
                      text: 'Send Notification',
                      backgroundColor: ternaryColor,
                      onTap: () async {
                        if (_notificationController.text.trim().isEmpty) {
                          SnackBarUtils.showTopSnackBar(
                            context,
                            'Please enter a notification message',
                          );
                          return;
                        }

                        final success = await model.sendNotification(
                          _notificationController.text.trim(),
                        );

                        if (success && mounted) {
                          SnackBarUtils.showTopSnackBar(
                            context,
                            'Notification sent successfully!',
                          );
                          _notificationController.clear();
                        } else if (mounted) {
                          SnackBarUtils.showTopSnackBar(
                            context,
                            'Failed to send notification. Please try again.',
                          );
                        }
                      },
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
