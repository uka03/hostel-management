import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: GeneralColors.backgroundColor,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: GeneralColors.cardColor,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: GeneralColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: GeneralColors.primaryColor),
    ),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: GeneralColors.primaryColor)
      .copyWith(
        primary: GeneralColors.primaryColor,
        surface: GeneralColors.cardColor,
        error: GeneralColors.dangerColor,
      ),
);
