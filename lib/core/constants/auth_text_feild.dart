import 'package:flutter/material.dart';

import 'package:girl_clan/core/constants/colors.dart';
import 'package:girl_clan/core/constants/text_style.dart';

final InputDecoration customAuthField3 = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: ternaryColor),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: ternaryColor),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: ternaryColor),
  ),
  filled: true,
  fillColor: whiteColor,
  hintStyle: style14B.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: ternaryColor,
  ),
  prefixStyle: style20B.copyWith(
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade400,
  ),
  isDense: true,
);

///
///    home screen search etc
///
final InputDecoration customHomeAuthField = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      50,
    ), // Increased border radius for more rounded shape
    borderSide: BorderSide(
      color: Colors.transparent,
    ), // Transparent border to match the image
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      50,
    ), // Increased border radius for more rounded shape
    borderSide: BorderSide(
      color: Colors.transparent,
    ), // Transparent border to match the image
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      50,
    ), // Increased border radius for more rounded shape
    borderSide: BorderSide(
      color: Colors.transparent,
    ), // Transparent border to match the image
  ),
  filled: true,
  fillColor: thinGreyColor, // A light grey fill color to match the image
  hintText: 'Search', // Hint text "Search"
  hintStyle: style14B.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 12, // Slightly larger font size for hint
    color: ternaryColor, // Assuming ternaryColor is a suitable dark grey
  ),
  prefixIcon: Icon(
    Icons.search, // Search icon
    color: ternaryColor, // Icon color
    size: 24,
  ),

  prefixStyle: style20B.copyWith(
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade400,
  ),
  isDense: true, // Make the input field more compact
);
//******* */
//****************************************************************************************************************************************** */
///
///     edit profile text form field decoration
///
///

///
// ignore: non_constant_identifier_names
final InputDecoration EditProfileFieldDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: greyBorderColor.withOpacity(0.1), width: 1.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: greyBorderColor, width: 1.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: borderColor.withOpacity(0.4)),
  ),
  filled: true,
  fillColor: whiteColor,
  hintText: 'DD/MM/YY',
  hintStyle: style14B.copyWith(fontWeight: FontWeight.w400),
  suffixIcon: Padding(padding: EdgeInsets.only(right: 15)),
  isDense: true,
);
