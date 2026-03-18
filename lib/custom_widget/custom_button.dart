import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/core/constants/text_style.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45.h,

        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.transparent),
          color: backgroundColor,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Center(
          child: Text(
            text,
            style: style20.copyWith(
              fontSize: 14,
              color:
                  textColor ?? Colors.white, // Or make this also configurable
            ),
          ),
        ),
      ),
    );
  }
}
