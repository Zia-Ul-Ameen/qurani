// lib/core/theme/text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Arabic (Uthmani) — RTL
  static TextStyle arabicAyah({
    double fontSize = 24,
    Color color = AppColors.lightOnBackground,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: 'KFGQPCUthmanTaha',
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        height: 2.2,
        letterSpacing: 0,
      );

  static TextStyle arabicBasmala({
    double fontSize = 28,
    Color color = AppColors.lightOnBackground,
  }) =>
      arabicAyah(fontSize: fontSize, color: color, weight: FontWeight.w700);

  // Translation — LTR
  static TextStyle translationBody({
    double fontSize = 15,
    Color color = AppColors.lightSubtitle,
  }) =>
      TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  // UI
  static const TextStyle surahTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle surahSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.lightSubtitle,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle cardLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle hasanatCounter = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
  );

  static const TextStyle miniPlayerTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}
