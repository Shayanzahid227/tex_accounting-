import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/auth/login_screen.dart';
import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimationFinished = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });

    // We manually set a timer for the static text switch to match the animation duration
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _isAnimationFinished = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, blackColor],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            /// Brand Animation/Static Text
            Center(
              child: Column(
                children: [
                  if (!_isAnimationFinished)
                    AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'PRIME',
                          textStyle: style25B.copyWith(
                            color: secondaryColor,
                            fontSize: 48.sp,
                            letterSpacing: 12.w,
                            fontWeight: FontWeight.w900,
                          ),
                          duration: const Duration(milliseconds: 2000),
                        ),
                      ],
                      totalRepeatCount: 1,
                    )
                  else
                    Text(
                      'PRIME',
                      style: style25B.copyWith(
                        color: secondaryColor,
                        fontSize: 48.sp,
                        letterSpacing: 12.w,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  SizedBox(height: 10.h),
                  if (!_isAnimationFinished)
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'TAX ACCOUNTING',
                          textStyle: style18B.copyWith(
                            color: ternaryColor,
                            fontSize: 16.sp,
                            letterSpacing: 4.w,
                            fontWeight: FontWeight.w400,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    )
                  else
                    Text(
                      'TAX ACCOUNTING',
                      style: style18B.copyWith(
                        color: ternaryColor,
                        fontSize: 16.sp,
                        letterSpacing: 4.w,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            /// Tagline Animation/Static Text
            if (!_isAnimationFinished)
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'VAT • Tax • Accounting',
                    textStyle: style12N.copyWith(
                      color: whiteColor.withOpacity(0.6),
                      fontSize: 12.sp,
                      letterSpacing: 2.w,
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ),
                ],
                totalRepeatCount: 1,
              )
            else
              Text(
                'VAT • Tax • Accounting',
                style: style12N.copyWith(
                  color: whiteColor.withOpacity(0.6),
                  fontSize: 12.sp,
                  letterSpacing: 2.w,
                ),
              ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
