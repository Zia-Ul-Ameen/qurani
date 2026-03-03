// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand accent — calming green
  static const Color accent = Color(0xFF4A8C6F);
  static const Color accentLight = Color(0xFF6DB38E);
  static const Color accentDark = Color(0xFF2E6B50);

  // Light theme
  static const Color lightBackground = Color(0xFFF8F6F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEEBE4);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF2C2C2C);
  static const Color lightSubtitle = Color(0xFF717171);
  static const Color lightDivider = Color(0xFFE0DDD6);

  // Dark theme
  static const Color darkBackground = Color(0xFF0E1117);
  static const Color darkSurface = Color(0xFF181C25);
  static const Color darkSurfaceVariant = Color(0xFF222831);
  static const Color darkOnBackground = Color(0xFFF0EDE8);
  static const Color darkOnSurface = Color(0xFFE4E0D8);
  static const Color darkSubtitle = Color(0xFF8A8A8A);
  static const Color darkDivider = Color(0xFF2A2E38);

  // High contrast
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF111111);
  static const Color hcOnBackground = Color(0xFFFFFFFF);
  static const Color hcAccent = Color(0xFF00E676);

  // Semantic
  static const Color error = Color(0xFFCF3030);
  static const Color success = Color(0xFF4A8C6F);
  static const Color warning = Color(0xFFC97B2A);
  static const Color ayahHighlight = Color(0xFF4A8C6F);

  // Ayah number badge
  static const Color ayahNumberBg = Color(0xFF4A8C6F);
  static const Color ayahNumberFg = Color(0xFFFFFFFF);
}
