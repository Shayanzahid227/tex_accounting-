import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/auth/auth_view_model.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:girl_clan/core/constants/auth_text_feild.dart';
import 'package:girl_clan/custom_widget/custom_button.dart';
import 'package:girl_clan/core/enums/view_state_model.dart';
import 'package:girl_clan/core/model/user_model.dart';
import 'package:girl_clan/UI/root/root_screen.dart'; // Client Root
import 'package:girl_clan/UI/admin/admin_root_screen.dart'; // Admin Root
import 'package:girl_clan/UI/auth/sign_up_screen.dart';
import 'package:girl_clan/core/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
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
                   SizedBox(height: 50.h),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20.sp),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.key, size: 70.sp, color: primaryColor),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    'Welcome Back',
                    style: style25B.copyWith(
                      fontSize: 32.sp,
                      color: ternaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Your Privacy, Our Priority',
                    style: style16N.copyWith(color: greyBorderColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),

                  // Email Field
                  Text(
                    'Email or Admin ID',
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
                      decoration: customAuthField3.copyWith(
                        hintText: 'e.g. email@example.com',
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
                    'Password',
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
                      obscureText: true,
                      decoration: customAuthField3.copyWith(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: primaryColor,
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
                        text: 'Login Now',
                        backgroundColor: primaryColor,
                        onTap: () async {
                          final identifier = _emailController.text.trim();
                          final password = _passwordController.text;

                          if (identifier.isEmpty) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              'Please enter your Email or Admin ID',
                            );
                            return;
                          }

                          if (password.isEmpty) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              'Please enter your password to continue',
                            );
                            return;
                          }

                          final user = await model.login(
                            identifier,
                            password: password,
                          );

                          if (user != null) {
                            if (user.role == UserRole.client) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RootScreen(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminRootScreen(),
                                ),
                              );
                            }
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
                        "Don't have an account? ",
                        style: style14.copyWith(color: whiteColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
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
