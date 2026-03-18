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

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text('Admin Dashboard', style: style20B),
        backgroundColor: whiteColor,
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
                    color: secondaryColor.withOpacity(0.08),
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
                            style: style16B.copyWith(color: secondaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Text('Create Client Account', style: style20B),
                SizedBox(height: 8.h),
                Text(
                  'Add a new client to the system by providing their details.',
                  style: style14.copyWith(color: greyBorderColor),
                ),
                SizedBox(height: 32.h),

                Text('Full Name', style: style14B),
                SizedBox(height: 10.h),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: style16,
                    decoration: customAuthField3.copyWith(
                      hintText: 'e.g. John Doe',
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                Text('Unique Login ID', style: style14B),
                SizedBox(height: 10.h),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _numberController,
                    style: style16,
                    decoration: customAuthField3.copyWith(
                      hintText: 'e.g. abc-456',
                      prefixIcon: const Icon(
                        Icons.vpn_key_outlined,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 48.h),

                model.state == ViewState.busy
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                      onTap: () async {
                        if (_nameController.text.isEmpty ||
                            _numberController.text.isEmpty) {
                          SnackBarUtils.showTopSnackBar(
                            context,
                            'Please fill all fields',
                            backgroundColor: redColor,
                          );
                          return;
                        }
                        final success = await model.createClient(
                          _nameController.text,
                          _numberController.text,
                        );
                        if (success) {
                          _nameController.clear();
                          _numberController.clear();
                          SnackBarUtils.showTopSnackBar(
                            context,
                            'Client account created successfully!',
                            backgroundColor: secondaryColor,
                          );
                        }
                      },
                      text: 'Create Client Now',
                      backgroundColor: secondaryColor,
                    ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
