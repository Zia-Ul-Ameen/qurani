// lib/data/models/app_settings_model.dart

import 'package:flutter/material.dart';

class AppSettings {
  final String reciterId;
  final String translationEditionId;
  final double arabicFontSize;
  final double translationFontSize;
  final int themeModeIndex; // 0: system, 1: light, 2: dark
  final bool highContrast;
  final bool reduceMotion;
  final double defaultAudioSpeed;
  final bool showTranslation;

  AppSettings({
    required this.reciterId,
    required this.translationEditionId,
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.themeModeIndex,
    required this.highContrast,
    required this.reduceMotion,
    required this.defaultAudioSpeed,
    required this.showTranslation,
  });

  factory AppSettings.defaults() => AppSettings(
        reciterId: 'ar.alafasy',
        translationEditionId: 'en.sahih',
        arabicFontSize: 28,
        translationFontSize: 16,
        themeModeIndex: 0, // system
        highContrast: false,
        reduceMotion: false,
        defaultAudioSpeed: 1.0,
        showTranslation: true,
      );

  ThemeMode get themeMode {
    switch (themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    String? reciterId,
    String? translationEditionId,
    double? arabicFontSize,
    double? translationFontSize,
    int? themeModeIndex,
    bool? highContrast,
    bool? reduceMotion,
    double? defaultAudioSpeed,
    bool? showTranslation,
  }) =>
      AppSettings(
        reciterId: reciterId ?? this.reciterId,
        translationEditionId: translationEditionId ?? this.translationEditionId,
        arabicFontSize: arabicFontSize ?? this.arabicFontSize,
        translationFontSize: translationFontSize ?? this.translationFontSize,
        themeModeIndex: themeModeIndex ?? this.themeModeIndex,
        highContrast: highContrast ?? this.highContrast,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        defaultAudioSpeed: defaultAudioSpeed ?? this.defaultAudioSpeed,
        showTranslation: showTranslation ?? this.showTranslation,
      );
}
