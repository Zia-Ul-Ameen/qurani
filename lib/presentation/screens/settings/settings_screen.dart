// lib/presentation/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── AUDIO ─────────────────────────────────────────────────────

          _SectionHeader(title: 'Audio', icon: Icons.headphones),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default Playback Speed', style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.audioSpeeds.map((speed) {
                    final selected = (settings.defaultAudioSpeed - speed).abs() < 0.01;
                    return ChoiceChip(
                      label: Text('${speed}x'),
                      selected: selected,
                      onSelected: (_) => notifier.setAudioSpeed(speed),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Reciter selection
          _SettingCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reciter'),
              subtitle: Text(settings.reciterId),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showReciterSheet(context, ref),
            ),
          ),

          // ─── TRANSLATION ───────────────────────────────────────────────

          const SizedBox(height: 16),
          _SectionHeader(title: 'Translation', icon: Icons.translate),
          _SettingCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Translation Language'),
              subtitle: Text(settings.translationEditionId),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTranslationSheet(context, ref),
            ),
          ),

          // ─── DISPLAY ───────────────────────────────────────────────────

          const SizedBox(height: 16),
          _SectionHeader(title: 'Display', icon: Icons.text_fields),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FontSizeRow(
                  label: 'Arabic Font Size',
                  value: settings.arabicFontSize,
                  min: AppConstants.arabicFontSizeMin,
                  max: AppConstants.arabicFontSizeMax,
                  onChanged: notifier.setArabicFontSize,
                  previewText: 'بِسْمِ اللّه',
                  previewFontFamily: 'KFGQPCUthmanTaha',
                  rtl: true,
                ),
                const Divider(),
                _FontSizeRow(
                  label: 'Translation Font Size',
                  value: settings.translationFontSize,
                  min: AppConstants.translationFontSizeMin,
                  max: AppConstants.translationFontSizeMax,
                  onChanged: notifier.setTranslationFontSize,
                  previewText: 'In the name of Allah',
                  previewFontFamily: null,
                  rtl: false,
                ),
              ],
            ),
          ),

          // ─── THEME ─────────────────────────────────────────────────────

          const SizedBox(height: 16),
          _SectionHeader(title: 'Theme', icon: Icons.palette_outlined),
          _SettingCard(
            child: Column(
              children: [
                _ThemeOption(
                  label: 'System (auto)',
                  icon: Icons.brightness_auto,
                  isSelected: settings.themeModeIndex == 0,
                  onTap: () => notifier.setThemeMode(0),
                ),
                const Divider(height: 1),
                _ThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode,
                  isSelected: settings.themeModeIndex == 1,
                  onTap: () => notifier.setThemeMode(1),
                ),
                const Divider(height: 1),
                _ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode,
                  isSelected: settings.themeModeIndex == 2,
                  onTap: () => notifier.setThemeMode(2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SettingCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('High Contrast'),
              subtitle: const Text('Increases text and border contrast'),
              value: settings.highContrast,
              onChanged: notifier.setHighContrast,
            ),
          ),
          const SizedBox(height: 8),
          _SettingCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduce Motion'),
              subtitle: const Text('Disables animations'),
              value: settings.reduceMotion,
              onChanged: notifier.setReduceMotion,
            ),
          ),

          // ─── STORAGE ───────────────────────────────────────────────────

          const SizedBox(height: 16),
          _SectionHeader(title: 'Storage', icon: Icons.storage_outlined),
          _SettingCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Manage Downloads'),
              subtitle: const Text('View and delete audio files'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/storage'),
            ),
          ),

          // ─── ABOUT ─────────────────────────────────────────────────────

          const SizedBox(height: 16),
          _SectionHeader(title: 'About', icon: Icons.info_outline),
          _SettingCard(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0', style: theme.textTheme.bodySmall),
                  const Divider(height: 20),
                  Text(
                    'Hasanāt Disclaimer',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.hasanatDisclaimer,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showReciterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _ReciterSheet(),
    );
  }

  void _showTranslationSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _TranslationSheet(),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              )),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}

class _FontSizeRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String previewText;
  final String? previewFontFamily;
  final bool rtl;

  const _FontSizeRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.previewText,
    required this.previewFontFamily,
    required this.rtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text('${value.round()}pt',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.accent)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 1).round(),
          onChanged: onChanged,
        ),
        Text(
          previewText,
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontFamily: previewFontFamily,
            fontSize: value,
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? AppColors.accent : null, size: 20),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.accent, size: 18)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      dense: true,
    );
  }
}

class _ReciterSheet extends ConsumerWidget {
  const _ReciterSheet();

  static const _knownReciters = [
    ('Alafasy_128kbps', 'Mishary Rashid Alafasy'),
    ('Abdul_Basit_Murattal_192kbps', 'Abdul Basit Abd us-Samad'),
    ('Husary_128kbps', 'Mahmoud Khalil al-Husary'),
    ('Minshawi_Murattal_128kbps', 'Mohamed Siddiq el-Minshawi'),
    ('Nasser_Alqatami_128kbps', 'Nasser Al Qatami'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsProvider).reciterId;
    final notifier = ref.read(settingsProvider.notifier);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Reciter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ..._knownReciters.map(
            (r) => ListTile(
              title: Text(r.$2),
              trailing: r.$1 == current
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () {
                notifier.setReciter(r.$1);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationSheet extends ConsumerWidget {
  const _TranslationSheet();

  static const _knownTranslations = [
    ('en.asad', 'Muhammad Asad (English)'),
    ('en.pickthall', 'Pickthall (English)'),
    ('en.sahih', 'Saheeh International (English)'),
    ('fr.hamidullah', 'Muhammad Hamidullah (French)'),
    ('tr.diyanet', 'Diyanet (Turkish)'),
    ('ur.jalandhry', 'Fateh Muhammad Jalandhry (Urdu)'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsProvider).translationEditionId;
    final notifier = ref.read(settingsProvider.notifier);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Translation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ..._knownTranslations.map(
            (t) => ListTile(
              title: Text(t.$2),
              trailing: t.$1 == current
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () {
                notifier.setTranslation(t.$1);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
