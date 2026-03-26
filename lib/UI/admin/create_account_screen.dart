import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/admin/admin_view_model.dart';
import 'package:girl_clan/UI/auth/login_screen.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:provider/provider.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: style20B),

        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: redColor),
            onPressed: () {
              Provider.of<AuthServices>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, model, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: secondaryColor,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: whiteColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You are logged in as',
                            style: style12N.copyWith(color: greyBorderColor),
                          ),
                          Text(
                            'Administrator',
                            style: style16B.copyWith(color: ternaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Center(
                  child: Text(
                    'what should add here in this scree',
                    style: style16B.copyWith(color: greyBorderColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
