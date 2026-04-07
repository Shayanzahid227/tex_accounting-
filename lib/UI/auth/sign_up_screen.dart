import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/auth/auth_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/constants/auth_text_feild.dart';
import 'package:girl_clan/custom_widget/custom_button.dart';
import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/UI/root/root_screen.dart';
import 'package:girl_clan/core/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              whiteColor,
              primaryColor.withOpacity(0.05),
              secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Consumer<AuthViewModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.sp),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: primaryColor,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Create Account',
                    style: style25B.copyWith(
                      fontSize: 32.sp,
                      color: ternaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Sign up to manage your taxes',
                    style: style16N.copyWith(color: greyBorderColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),

                  // Name Field
                  Text(
                    'Full Name',
                    style: style14B.copyWith(color: ternaryColor),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
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
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Email Field
                  Text(
                    'Email Address',
                    style: style14B.copyWith(color: ternaryColor),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: style16,
                      keyboardType: TextInputType.emailAddress,
                      decoration: customAuthField3.copyWith(
                        hintText: 'e.g. john@example.com',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Password Field
                  Text(
                    'Create Password',
                    style: style14B.copyWith(color: ternaryColor),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      style: style16,
                      obscureText: _obscurePassword,
                      decoration: customAuthField3.copyWith(
                        hintText: 'Must be unique',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: primaryColor,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (model.errorMessage != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      model.errorMessage!,
                      style: style12.copyWith(color: redColor),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  SizedBox(height: 40.h),
                  model.state == ViewState.busy
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                        text: 'Sign Up',
                        backgroundColor: primaryColor,
                        onTap: () async {
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;

                          if (name.isEmpty) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              'Please enter your full name',
                            );
                            return;
                          }
                          if (email.isEmpty) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              'Please enter your email address',
                            );
                            return;
                          }
                          if (password.isEmpty) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              'Please choose a unique password/number',
                            );
                            return;
                          }

                          final user = await model.register(
                            name,
                            email,
                            password,
                          );

                          if (user != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RootScreen(),
                              ),
                              (route) => false,
                            );
                          } else if (model.errorMessage != null) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              model.errorMessage!,
                            );
                          }
                        },
                      ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: style14.copyWith(color: whiteColor),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Login',
                          style: style14B.copyWith(color: ternaryColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
