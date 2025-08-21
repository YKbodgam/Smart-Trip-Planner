import 'package:flutter/material.dart';

class Palette {
  // Primary Color
  static const Color primary = Color(0xFF6E71BC);

  // Secondary Colors
  static const Color secondary1 = Color(0xFF2E306B);
  static const Color secondary2 = Color(0xFFBCBEE4);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF989898);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFE8E8E8);
  static const Color ultraLightGrey = Color(0xFFF8F8F8);

  // Text Colors
  static const Color textPrimary = black;
  static const Color textSecondary = grey;

  // Background Colors
  static const Color background = white;
  static const Color backgroundLight = ultraLightGrey;
  static const Color backgroundCard = lightGrey;

  // Border Color
  static const Color border = grey;

  // Disabled Color
  static const Color disabled = Color(0xFFC4C4C4);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
