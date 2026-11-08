import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import '../../demo/demo_mode.dart';
import '../../local/company_settings.dart';
import '../../session/app_session.dart';
import 'g_widget_tour.dart';

/// Language, dark mode and help flag switches in one card, shared by the admin menu,
/// the technician menu and the role selection screen.
class GWidgetAppSettings extends StatelessWidget {
  const GWidgetAppSettings({super.key});

  /// An installed app keeps the light/dark it was designed in.
  static bool get _showDarkMode =>
      AppTheme.darkModeEnabled && !DemoMode.installedApp;

  @override
  Widget build(BuildContext context) {
    const showLanguage = AppLanguage.languageSwitchEnabled;
    final showDarkMode = _showDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.iconLightGrey),
      ),
      child: Column(
        children: [
          if (showLanguage) const _LanguageRow(),
          if (showLanguage && showDarkMode)
            Divider(
                height: 12, color: AppTheme.iconLightGrey.withValues(alpha: .3)),
          if (showDarkMode) const _DarkModeRow(),
          if (showLanguage || showDarkMode)
            Divider(
                height: 12, color: AppTheme.iconLightGrey.withValues(alpha: .3)),
          const _HelpFlagsRow(),
          if (AppSession.isAdmin) ...[
            Divider(
                height: 12, color: AppTheme.iconLightGrey.withValues(alpha: .3)),
            _RequirePhotosRow(
              title: 'Always require before-work photos'.tr,
              read: () => CompanySettings.requireBeforePhotos,
              write: CompanySettings.setRequireBeforePhotos,
            ),
            _RequirePhotosRow(
              title: 'Always require after-work photos'.tr,
              read: () => CompanySettings.requireAfterPhotos,
              write: CompanySettings.setRequireAfterPhotos,
            ),
          ],
        ],
      ),
    );
  }
}

/// English / Arabic. Each option is written in its own language so anyone can
/// find it. The app saves the choice and switches to right-to-left for Arabic.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.arabic,
      builder: (context, arabic, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.translate_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Language'.tr,
                  style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textBodyLarge,
                      fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LanguageOption(
                      label: 'English',
                      selected: !arabic,
                      onTap: () => AppLanguage.arabic.value = false),
                  _LanguageOption(
                      label: 'العربية',
                      selected: arabic,
                      onTap: () => AppLanguage.arabic.value = true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: selected ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.scaffoldBackground,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label,
              style: AppTheme.font(
                  color: selected ? AppTheme.onPrimary : AppTheme.textSecondary,
                  fontSize: AppTheme.textSmall,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

/// Turns dark mode on or off. The app saves the choice and restyles itself.
class _DarkModeRow extends StatelessWidget {
  const _DarkModeRow();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.darkMode,
      builder: (context, dark, _) => Row(
        children: [
          Icon(dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: dark ? AppTheme.primary : AppTheme.pending, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Dark mode'.tr,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textBodyLarge,
                    fontWeight: FontWeight.w700)),
          ),
          Switch.adaptive(
            value: dark,
            activeTrackColor: AppTheme.primary,
            onChanged: (value) => AppTheme.darkMode.value = value,
          ),
        ],
      ),
    );
  }
}

/// A rule the admin sets once for every new visit.
class _RequirePhotosRow extends StatefulWidget {
  const _RequirePhotosRow(
      {required this.title, required this.read, required this.write});
  final String title;
  final bool Function() read;
  final Future<void> Function(bool) write;

  @override
  State<_RequirePhotosRow> createState() => _RequirePhotosRowState();
}

class _RequirePhotosRowState extends State<_RequirePhotosRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.add_a_photo_rounded, color: AppTheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(widget.title,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textBody,
                  fontWeight: FontWeight.w700)),
        ),
        Switch.adaptive(
          value: widget.read(),
          activeTrackColor: AppTheme.primary,
          onChanged: (value) async {
            await widget.write(value);
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }
}

/// Shows or hides the help flags on every screen. The app saves the choice.
class _HelpFlagsRow extends StatelessWidget {
  const _HelpFlagsRow();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GWidgetTour.showFlags,
      builder: (context, show, _) => Row(
        children: [
          Icon(Icons.flag_rounded, color: AppTheme.reward, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Help flags'.tr,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textBodyLarge,
                    fontWeight: FontWeight.w700)),
          ),
          Switch.adaptive(
            value: show,
            activeTrackColor: AppTheme.primary,
            onChanged: (value) => GWidgetTour.showFlags.value = value,
          ),
        ],
      ),
    );
  }
}
