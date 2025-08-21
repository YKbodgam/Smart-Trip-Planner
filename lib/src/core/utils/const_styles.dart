import 'package:flutter/material.dart';

import 'const_size.dart';

class AppFonts {
  static const String primaryFont = 'Epilogue';
}

class AppFontWeight {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
}

class AppTextStyles {
  static TextStyle _base(double size, FontWeight weight, {FontStyle? style}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      fontFamily: AppFonts.primaryFont,
      fontStyle: style,
    );
  }

  // Headline (display, h1-h3)
  static TextStyle get headlineLarge =>
      _base(AppFontSizes.headlineLargeTextSize(), AppFontWeight.bold);
  static TextStyle get headlineMedium =>
      _base(AppFontSizes.headlineMediumTextSize(), AppFontWeight.bold);
  static TextStyle get headlineSmall =>
      _base(AppFontSizes.headlineSmallTextSize(), AppFontWeight.medium);

  // Title / Sub-headline
  static TextStyle get mediumLarge =>
      _base(AppFontSizes.mediumLargeTextSize(), AppFontWeight.medium);
  static TextStyle get mediumRegular =>
      _base(AppFontSizes.mediumTextSize(), AppFontWeight.regular);
  static TextStyle get mediumSmall =>
      _base(AppFontSizes.mediumSmallTextSize(), AppFontWeight.regular);

  // Body text
  static TextStyle get bodyLarge =>
      _base(AppFontSizes.bodyLargeTextSize(), AppFontWeight.medium);
  static TextStyle get bodyMedium =>
      _base(AppFontSizes.bodyMediumTextSize(), AppFontWeight.regular);
  static TextStyle get bodySmall =>
      _base(AppFontSizes.bodySmallTextSize(), AppFontWeight.light);

  // Labels / Captions
  static TextStyle get labelLarge =>
      _base(AppFontSizes.labelLargeTextSize(), AppFontWeight.medium);
  static TextStyle get labelMedium =>
      _base(AppFontSizes.labelMediumTextSize(), AppFontWeight.regular);
  static TextStyle get labelSmall =>
      _base(AppFontSizes.labelSmallTextSize(), AppFontWeight.light);

  // Italics
  static TextStyle get italicMedium => _base(
    AppFontSizes.mediumTextSize(),
    AppFontWeight.regular,
    style: FontStyle.italic,
  );
}
