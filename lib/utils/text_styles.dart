import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';

extension GeneralTextStyle on TextTheme {
  /// Screen title: 24 Bold.
  static TextStyle titleText({
    Color? textColor,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    TextDecoration? decoration,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: textColor ?? GeneralColors.textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Section heading: 16 SemiBold.
  static TextStyle sectionText({
    Color? textColor,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      color: textColor ?? GeneralColors.textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Body: 14 Regular (use fontSize 15 for larger body copy).
  static TextStyle bodyText({
    Color? textColor = GeneralColors.textColor,
    double fontSize = 14,
    double? height,
    FontWeight fontWeight = FontWeight.w400,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
    );
  }

  /// Caption: 12 Regular, muted by default.
  static TextStyle captionText({
    Color? textColor,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
  }) {
    return TextStyle(
      color: textColor ?? GeneralColors.mutedColor,
      fontSize: 12,
      fontWeight: fontWeight,
      height: height,
    );
  }
}
