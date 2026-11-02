import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../configs/app_brand.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/demo/demo_seed.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../auth/domain/usecases/enter_as_admin_uc.dart';
import '../../../auth/domain/usecases/login_technician_uc.dart';
import '../../../auth/domain/usecases/logout_uc.dart';
import '../../../auth/presentation/widgets/auth_widget_account_actions.dart';
import 'website_widget_parts.dart';
import '../website_theme.dart';

/// The design studio's controls: every theme color (any color), fonts,
/// text size, light/dark, name, icon or logo, language, and which side of
/// the demo app to look at.
class StudioWidgetPanel extends StatefulWidget {
  const StudioWidgetPanel({super.key, required this.onRequest});
  final VoidCallback onRequest;

  /// Opens the demo app as the admin or as the demo technician.
  static Future<void> viewAs({required bool technician}) async {
    if (technician) {
      await sl<LoginTechnicianUc>().call(const LoginTechnicianParameters(
          email: DemoSeed.technicianEmail,
          password: DemoSeed.technicianPassword));
    } else {
      await sl<EnterAsAdminUc>().call(const NoParameters());
    }
    AuthWidgetAccountActions.backToHome();
  }

  /// The app's own color for [slot], used when the customer has not set one.
  static Color defaultColor(AppBrandColor slot) {
    const palette = AppTheme.light;
    switch (slot) {
      case AppBrandColor.primary:
        return palette.primary;
      case AppBrandColor.secondary:
        return palette.secondary;
      case AppBrandColor.background:
        return palette.scaffoldBackground;
      case AppBrandColor.card:
        return palette.cardColor;
      case AppBrandColor.text:
        return palette.textPrimary;
      case AppBrandColor.success:
        return palette.statGreen;
      case AppBrandColor.warning:
        return palette.pending;
      case AppBrandColor.danger:
        return palette.statOrange;
    }
  }

  static Color colorOf(AppBrandColor slot) =>
      AppBrand.value[slot] ?? defaultColor(slot);

  @override
  State<StudioWidgetPanel> createState() => _StudioWidgetPanelState();
}

class _StudioWidgetPanelState extends State<StudioWidgetPanel> {
  late final _name = TextEditingController(text: AppBrand.value.appName ?? '');
  bool _switching = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  AppBrandModel get _brand => AppBrand.value;

  void _set(AppBrandModel brand) {
    AppBrand.update(brand);
    if (mounted) setState(() {});
  }

  Future<void> _pickColor(AppBrandColor slot) async {
    final before = _brand[slot];
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: WebTheme.surface,
        title: Text(slot.label,
            style: WebTheme.font(
                color: WebTheme.textPrimary, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: StudioWidgetPanel.colorOf(slot),
            onColorChanged: (color) => AppBrand.update(_brand.withColor(slot, color)),
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
            pickerAreaHeightPercent: .7,
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'.tr,
                style: WebTheme.font(color: WebTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Done'.tr,
                style: WebTheme.font(
                    color: WebTheme.primary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    // Cancel puts the previous color back.
    if (accepted != true) _set(_brand.withColor(slot, before));
    if (mounted) setState(() {});
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    _set(_brand.copyWith(logo: bytes));
  }

  Future<void> _viewAs({required bool technician}) async {
    if (_switching) return;
    setState(() => _switching = true);
    await StudioWidgetPanel.viewAs(technician: technician);
    if (mounted) setState(() => _switching = false);
  }

  /// Puts the demo company back as it was when the page opened.
  Future<void> _restartDemo() async {
    if (_switching) return;
    setState(() => _switching = true);
    await LocalPref.sharedPreferences.clear();
    await DemoSeed.run();
    await sl<LogoutUc>().call(const NoParameters());
    AuthWidgetAccountActions.backToHome();
    if (mounted) setState(() => _switching = false);
  }

  void _resetDesign() {
    _name.clear();
    AppBrand.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primary = StudioWidgetPanel.colorOf(AppBrandColor.primary);
    final secondary = StudioWidgetPanel.colorOf(AppBrandColor.secondary);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(children: [
          Expanded(
            child: Text('Design your app'.tr,
                style: WebTheme.font(
                    color: WebTheme.textPrimary,
                    fontSize: WebTheme.textHeadline,
                    fontWeight: FontWeight.w800)),
          ),
          TextButton.icon(
            onPressed: _resetDesign,
            icon: Icon(Icons.restart_alt_rounded,
                color: WebTheme.textSecondary, size: 18),
            label: Text('Reset'.tr,
                style: WebTheme.font(color: WebTheme.textSecondary)),
          ),
        ]),
        Text('Every change shows in the app right away.'.tr,
            style: WebTheme.font(
                color: WebTheme.textSecondary, fontSize: WebTheme.textBody)),

        // --- Colors ----------------------------------------------------------
        _title('Quick color themes'.tr),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in AppBrand.presets)
              _PresetChip(
                preset: preset,
                selected:
                    preset.primary == primary && preset.secondary == secondary,
                onTap: () => _set(_brand
                    .withColor(AppBrandColor.primary, preset.primary)
                    .withColor(AppBrandColor.secondary, preset.secondary)),
              ),
          ],
        ),
        _title('Colors'.tr),
        Text('Tap a color to choose any shade or type its code.'.tr,
            style: WebTheme.font(
                color: WebTheme.textSecondary, fontSize: WebTheme.textSmall)),
        const SizedBox(height: 8),
        for (final slot in AppBrandColor.values)
          _ColorRow(
            slot: slot,
            color: StudioWidgetPanel.colorOf(slot),
            changed: _brand[slot] != null,
            onTap: () => _pickColor(slot),
            onReset: () => _set(_brand.withColor(slot, null)),
          ),
        _title('Mode'.tr),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
                value: false,
                icon: const Icon(Icons.light_mode_rounded),
                label: Text('Light'.tr)),
            ButtonSegment(
                value: true,
                icon: const Icon(Icons.dark_mode_rounded),
                label: Text('Dark'.tr)),
          ],
          selected: {AppTheme.isDark},
          onSelectionChanged: (value) {
            AppTheme.darkMode.value = value.first;
            setState(() {});
          },
        ),

        // --- Text ------------------------------------------------------------
        _title('Fonts'.tr),
        _FontPicker(
          label: 'Arabic font'.tr,
          fonts: AppBrand.arabicFonts,
          selected: _brand.fontArabic ?? AppTheme.fontFamilyArabic,
          sample: 'زيارة ميدانية',
          onPick: (font) => _set(_brand.copyWith(fontArabic: font)),
        ),
        const SizedBox(height: 10),
        _FontPicker(
          label: 'English font'.tr,
          fonts: AppBrand.englishFonts,
          selected: _brand.fontEnglish ?? AppTheme.fontFamily,
          sample: 'Field visit',
          onPick: (font) => _set(_brand.copyWith(fontEnglish: font)),
        ),
        _title('Text size'.tr),
        Row(children: [
          Icon(Icons.text_decrease_rounded, color: WebTheme.textSecondary),
          Expanded(
            child: Slider(
              value: _brand.fontScale,
              min: AppBrand.minFontScale,
              max: AppBrand.maxFontScale,
              divisions: 8,
              activeColor: WebTheme.primary,
              label: '${(_brand.fontScale * 100).round()}%',
              onChanged: (value) => _set(_brand.copyWith(fontScale: value)),
            ),
          ),
          Icon(Icons.text_increase_rounded, color: WebTheme.textSecondary),
        ]),

        // --- Identity --------------------------------------------------------
        _title('App name'.tr),
        TextField(
          controller: _name,
          maxLength: 30,
          style: WebTheme.font(
              color: WebTheme.textPrimary, fontSize: WebTheme.textBodyLarge),
          decoration: InputDecoration(
            hintText: 'e.g. Cool Air Services'.tr,
            hintStyle: WebTheme.font(
                color: WebTheme.textLightHint, fontSize: WebTheme.textBody),
            filled: true,
            fillColor: WebTheme.searchFieldBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: WebTheme.iconLightGrey.withValues(alpha: .5))),
          ),
          onChanged: (value) => value.trim().isEmpty
              ? _set(_brand.copyWith(clearName: true))
              : _set(_brand.copyWith(appName: value)),
        ),
        _title('App icon'.tr),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final icon in AppBrand.icons)
              Tooltip(
                message: icon.label.tr,
                child: InkWell(
                  onTap: () => _set(
                      _brand.copyWith(iconKey: icon.key, clearLogo: true)),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _brand.logo == null && _brand.iconKey == icon.key
                          ? WebTheme.primary
                          : WebTheme.locationChipBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon.icon,
                        color: _brand.logo == null && _brand.iconKey == icon.key
                            ? WebTheme.onPrimary
                            : WebTheme.textSecondary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(children: [
          OutlinedButton.icon(
            onPressed: _pickLogo,
            icon: Icon(Icons.upload_rounded, color: WebTheme.primary),
            label: Text(
                _brand.logo == null ? 'Upload your logo'.tr : 'Change logo'.tr,
                style: WebTheme.font(
                    color: WebTheme.primary, fontWeight: FontWeight.w700)),
          ),
          if (_brand.logo != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(_brand.logo!,
                  width: 40, height: 40, fit: BoxFit.cover),
            ),
            IconButton(
              tooltip: 'Remove logo'.tr,
              onPressed: () => _set(_brand.copyWith(clearLogo: true)),
              icon: Icon(Icons.close_rounded, color: WebTheme.statOrange),
            ),
          ],
        ]),
        _title('Language'.tr),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('العربية')),
            ButtonSegment(value: false, label: Text('English')),
          ],
          selected: {AppLanguage.isArabic},
          onSelectionChanged: (value) {
            AppLanguage.arabic.value = value.first;
            setState(() {});
          },
        ),

        // --- Demo ------------------------------------------------------------
        const SizedBox(height: 28),
        Divider(color: WebTheme.iconLightGrey.withValues(alpha: .5)),
        _title('Try the demo'.tr),
        Text('A sample HVAC company with visits in every step.'.tr,
            style: WebTheme.font(
                color: WebTheme.textSecondary, fontSize: WebTheme.textBody)),
        const SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: AppSession.current,
          builder: (context, session, _) => Row(children: [
            Expanded(
              child: _RoleButton(
                text: 'Admin'.tr,
                icon: Icons.admin_panel_settings_rounded,
                selected: AppSession.isAdmin,
                onTap: _switching ? null : () => _viewAs(technician: false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoleButton(
                text: 'Technician'.tr,
                icon: Icons.engineering_rounded,
                selected: AppSession.isTechnician,
                onTap: _switching ? null : () => _viewAs(technician: true),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text(
            'Technician sign-in: {0} / {1}'.trArgs(
                [DemoSeed.technicianEmail, DemoSeed.technicianPassword]),
            style: WebTheme.font(
                color: WebTheme.textLightHint, fontSize: WebTheme.textSmall)),
        ValueListenableBuilder(
          valueListenable: DemoMode.simulateOnSite,
          builder: (context, simulate, _) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: simulate,
            activeColor: WebTheme.primary,
            onChanged: (value) => DemoMode.simulateOnSite.value = value,
            title: Text('Pretend I am at the site'.tr,
                style: WebTheme.font(
                    color: WebTheme.textPrimary,
                    fontSize: WebTheme.textBodyLarge,
                    fontWeight: FontWeight.w600)),
            subtitle: Text(
                'Turn off to use your real location, as your technicians will.'
                    .tr,
                style: WebTheme.font(
                    color: WebTheme.textSecondary,
                    fontSize: WebTheme.textSmall)),
          ),
        ),
        TextButton.icon(
          onPressed: _switching ? null : _restartDemo,
          icon: Icon(Icons.replay_rounded, color: WebTheme.textSecondary),
          label: Text('Restart the demo data'.tr,
              style: WebTheme.font(color: WebTheme.textSecondary)),
        ),
        const SizedBox(height: 20),
        WebsiteButton(
          text: 'Request this version'.tr,
          icon: Icons.send_rounded,
          expand: true,
          onPressed: widget.onRequest,
        ),
      ],
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: WebTheme.textSubtitle,
                fontWeight: FontWeight.w800)),
      );
}

class _PresetChip extends StatelessWidget {
  const _PresetChip(
      {required this.preset, required this.selected, required this.onTap});
  final AppBrandPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: WebTheme.locationChipBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: selected ? preset.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    LinearGradient(colors: [preset.primary, preset.secondary]),
              ),
            ),
            const SizedBox(width: 8),
            Text(preset.name.tr,
                style: WebTheme.font(
                    color: WebTheme.textPrimary,
                    fontSize: WebTheme.textSmall,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// One theme color: what it colors, its code, and a reset when changed.
class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.slot,
    required this.color,
    required this.changed,
    required this.onTap,
    required this.onReset,
  });
  final AppBrandColor slot;
  final Color color;
  final bool changed;
  final VoidCallback onTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: WebTheme.iconLightGrey.withValues(alpha: .6)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot.label,
                    style: WebTheme.font(
                        color: WebTheme.textPrimary,
                        fontSize: WebTheme.textBodyLarge,
                        fontWeight: FontWeight.w700)),
                Text(slot.hint,
                    style: WebTheme.font(
                        color: WebTheme.textSecondary,
                        fontSize: WebTheme.textCaption)),
              ],
            ),
          ),
          Text(AppBrand.hex(color),
              textDirection: TextDirection.ltr,
              style: WebTheme.font(
                  color: WebTheme.textSecondary,
                  fontSize: WebTheme.textSmall,
                  fontWeight: FontWeight.w700)),
          if (changed)
            IconButton(
              tooltip: 'Back to default'.tr,
              onPressed: onReset,
              icon: Icon(Icons.undo_rounded,
                  color: WebTheme.textSecondary, size: 18),
            )
          else
            const SizedBox(width: 12),
        ]),
      ),
    );
  }
}

/// A font list where each name is written in its own font.
class _FontPicker extends StatelessWidget {
  const _FontPicker({
    required this.label,
    required this.fonts,
    required this.selected,
    required this.sample,
    required this.onPick,
  });
  final String label;
  final List<String> fonts;
  final String selected;
  final String sample;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: fonts.contains(selected) ? selected : fonts.first,
      isExpanded: true,
      dropdownColor: WebTheme.surface,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: WebTheme.font(color: WebTheme.textSecondary),
        filled: true,
        fillColor: WebTheme.searchFieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: [
        for (final font in fonts)
          DropdownMenuItem(
            value: font,
            child: Text('$font · $sample',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.getFont(font,
                    color: WebTheme.textPrimary, fontSize: 15)),
          ),
      ],
      onChanged: (font) {
        if (font != null) onPick(font);
      },
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? WebTheme.primary : WebTheme.locationChipBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? WebTheme.onPrimary : WebTheme.textSecondary),
              const SizedBox(height: 4),
              Text(text,
                  style: WebTheme.font(
                      color:
                          selected ? WebTheme.onPrimary : WebTheme.textPrimary,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
