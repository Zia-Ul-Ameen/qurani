// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        bg: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceVariant: AppColors.lightSurfaceVariant,
        onBg: AppColors.lightOnBackground,
        onSurface: AppColors.lightOnSurface,
        subtitle: AppColors.lightSubtitle,
        divider: AppColors.lightDivider,
        accent: AppColors.accent,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        bg: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        onBg: AppColors.darkOnBackground,
        onSurface: AppColors.darkOnSurface,
        subtitle: AppColors.darkSubtitle,
        divider: AppColors.darkDivider,
        accent: AppColors.accentLight,
      );

  static ThemeData get highContrast => _buildTheme(
        brightness: Brightness.dark,
        bg: AppColors.hcBackground,
        surface: AppColors.hcSurface,
        surfaceVariant: const Color(0xFF1A1A1A),
        onBg: AppColors.hcOnBackground,
        onSurface: AppColors.hcOnBackground,
        subtitle: const Color(0xFFCCCCCC),
        divider: const Color(0xFF444444),
        accent: AppColors.hcAccent,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceVariant,
    required Color onBg,
    required Color onSurface,
    required Color subtitle,
    required Color divider,
    required Color accent,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      dividerColor: divider,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onBg,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBg,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: subtitle, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: accent.withValues(alpha: 0.15),
        labelStyle: TextStyle(fontSize: 13, color: onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: divider),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: subtitle,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: onSurface, fontSize: 16),
        bodyMedium: TextStyle(color: onSurface, fontSize: 14),
        bodySmall: TextStyle(color: subtitle, fontSize: 12),
        titleLarge: TextStyle(color: onBg, fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: onBg, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: onBg, fontSize: 14, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: subtitle, fontSize: 11),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: subtitle,
        indicatorColor: accent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: divider,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : subtitle,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent.withValues(alpha: 0.4) : divider,
        ),
      ),
      extensions: [
        AppThemeExtension(
          subtitleColor: subtitle,
          dividerColor: divider,
          surfaceVariant: surfaceVariant,
          background: bg,
        ),
      ],
    );
  }
}

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color subtitleColor;
  final Color dividerColor;
  final Color surfaceVariant;
  final Color background;

  const AppThemeExtension({
    required this.subtitleColor,
    required this.dividerColor,
    required this.surfaceVariant,
    required this.background,
  });

  @override
  AppThemeExtension copyWith({
    Color? subtitleColor,
    Color? dividerColor,
    Color? surfaceVariant,
    Color? background,
  }) =>
      AppThemeExtension(
        subtitleColor: subtitleColor ?? this.subtitleColor,
        dividerColor: dividerColor ?? this.dividerColor,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
        background: background ?? this.background,
      );

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      background: Color.lerp(background, other.background, t)!,
    );
  }
}
