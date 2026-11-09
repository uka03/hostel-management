import 'package:flutter/material.dart';
import 'package:hostel/utils/colors.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: GeneralColors.backgroundColor,
  colorScheme: ColorScheme.fromSeed(seedColor: GeneralColors.primaryColor)
      .copyWith(
        primary: GeneralColors.primaryColor,
        surface: GeneralColors.cardColor,
        error: GeneralColors.dangerColor,
      ),
);
