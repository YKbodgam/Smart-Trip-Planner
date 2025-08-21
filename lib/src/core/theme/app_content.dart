import 'package:flutter/material.dart';

import '../utils/const_styles.dart';

class AppTextTheme {
  static TextTheme get textTheme => TextTheme(
    displayLarge: AppTextStyles.headlineLarge,
    displayMedium: AppTextStyles.headlineMedium,
    displaySmall: AppTextStyles.headlineSmall,

    headlineLarge: AppTextStyles.mediumLarge,
    headlineMedium: AppTextStyles.mediumRegular,
    headlineSmall: AppTextStyles.mediumSmall,

    titleLarge: AppTextStyles.bodyLarge,
    titleMedium: AppTextStyles.bodyMedium,
    titleSmall: AppTextStyles.bodySmall,

    bodyLarge: AppTextStyles.labelLarge,
    bodyMedium: AppTextStyles.labelMedium,
    bodySmall: AppTextStyles.labelSmall,

    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );
}
