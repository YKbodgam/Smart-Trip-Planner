import 'package:flutter/material.dart';

import '../utils/const_styles.dart';
import 'app_content.dart';
import 'app_palette.dart';

class AppTheme {
  static final ThemeData lightThemeData = ThemeData(
    brightness: Brightness.light,
    primaryColor: Palette.primary,
    scaffoldBackgroundColor: Palette.background,
    fontFamily: AppFonts.primaryFont,

    colorScheme: ColorScheme.light(
      primary: Palette.primary,
      onPrimary: Palette.white,
      secondary: Palette.secondary1,
      onSecondary: Palette.white,
      surface: Palette.white,
      onSurface: Palette.textPrimary,
      error: Colors.red,
      onError: Palette.white,
      background: Palette.background,
    ),

    textTheme: AppTextTheme.textTheme.apply(
      bodyColor: Palette.textPrimary,
      displayColor: Palette.textPrimary,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Palette.white,
      iconTheme: const IconThemeData(color: Palette.grey),
      titleTextStyle: AppTextTheme.textTheme.headlineMedium?.copyWith(
        color: Palette.textPrimary,
      ),
    ),

    cardColor: Palette.white,
    canvasColor: Palette.white,

    iconTheme: const IconThemeData(color: Palette.grey),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.ultraLightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Palette.lightGrey,
      thickness: 1,
    ),
  );
}
