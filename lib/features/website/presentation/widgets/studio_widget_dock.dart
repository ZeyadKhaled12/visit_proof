import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../configs/app_brand.dart';
import '../../../../configs/app_theme.dart';
import '../studio_scenario.dart';
import '../website_theme.dart';

/// The app's own colors and the visitor's changes to them.
class StudioDesign {
  StudioDesign._();

  /// The app's own color for [slot], used when the visitor has not set one.
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

  /// The visitor has changed something from the app's own look.
  static bool get isCustom {
    final brand = AppBrand.value;
    return brand.colors.isNotEmpty ||
        brand.hasCustomName ||
        brand.logo != null ||
        brand.iconKey != AppBrand.defaultIconKey ||
        brand.fontArabic != null ||
        brand.fontEnglish != null ||
        brand.fontScale != 1.0 ||
        AppTheme.isDark;
  }

  /// Back to the app's own look.
  static void clear() {
    AppBrand.reset();
    AppTheme.darkMode.value = false;
  }
}

enum _DockTab {
  colors('Colors', Icons.palette_rounded),
  text('Text', Icons.text_fields_rounded),
  identity('Name and logo', Icons.badge_rounded);

  const _DockTab(this._label, this.icon);
  final String _label;
  final IconData icon;
  String get label => _label.tr;
}

/// The design tools beside the live app, opened from the palette in the top
/// bar. A computer's side column shows the scenario's steps until then (on a
/// phone Wizpoo carries them). The app stays visible, so one tap restyles it
/// in front of the visitor.
class StudioWidgetDock extends StatefulWidget {
  const StudioWidgetDock({
    super.key,
    required this.scenario,
    required this.wide,
    required this.designOpen,
    required this.onOffer,
  });

  final StudioScenario scenario;

  /// A tall side column on a computer; a short strip under the app on a
  /// phone.
  final bool wide;

  /// The visitor pressed the palette to change the app's style.
  final bool designOpen;
  final VoidCallback onOffer;

  @override
  State<StudioWidgetDock> createState() => _StudioWidgetDockState();
}

class _StudioWidgetDockState extends State<StudioWidgetDock> {
  _DockTab _tab = _DockTab.colors;
  bool _custom = false;
  AppBrandColor _slot = AppBrandColor.primary;
  late HSVColor _hsv = HSVColor.fromColor(StudioDesign.colorOf(_slot));

  late final _name = TextEditingController(text: AppBrand.value.appName ?? '');
  late final _hex =
      TextEditingController(text: AppBrand.hex(StudioDesign.colorOf(_slot)));
  final _nameFocus = FocusNode();
  final _hexFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.scenario.addListener(_redraw);
    _nameFocus.addListener(_redraw);
    _hexFocus.addListener(_redraw);
  }

  @override
  void dispose() {
    widget.scenario.removeListener(_redraw);
    _name.dispose();
    _hex.dispose();
    _nameFocus.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  AppBrandModel get _brand => AppBrand.value;

  void _set(AppBrandModel brand) {
    AppBrand.update(brand);
    _redraw();
  }

  void _selectTab(_DockTab tab) => setState(() => _tab = tab);

  void _selectSlot(AppBrandColor slot) => setState(() {
        _slot = slot;
        final color = StudioDesign.colorOf(slot);
        _hsv = HSVColor.fromColor(color);
        _hex.text = AppBrand.hex(color);
      });

  void _applySlider(HSVColor hsv) {
    _hsv = hsv;
    _hex.text = AppBrand.hex(hsv.toColor());
    _set(_brand.withColor(_slot, hsv.toColor()));
  }

  void _applyHex(String text) {
    final color = AppBrand.parseHex(text);
    if (color == null) return;
    _hsv = HSVColor.fromColor(color);
    _set(_brand.withColor(_slot, color));
  }

  void _resetSlot() {
    _set(_brand.withColor(_slot, null));
    _selectSlot(_slot);
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    _set(_brand.copyWith(logo: bytes));
  }

  Future<void> _clearDesign() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: WebTheme.surface,
        title: Text('Clear your design?'.tr,
            style: WebTheme.font(
                color: WebTheme.textPrimary, fontWeight: FontWeight.w800)),
        content: Text('The app goes back to its original look.'.tr,
            style: WebTheme.font(
                color: WebTheme.textSecondary,
                fontSize: WebTheme.textBodyLarge)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'.tr,
                style: WebTheme.font(color: WebTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Clear'.tr,
                style: WebTheme.font(
                    color: WebTheme.statOrange, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (clear != true) return;
    StudioDesign.clear();
    _name.clear();
    _selectSlot(_slot);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final typingHere = _nameFocus.hasFocus || _hexFocus.hasFocus;
    // Typing inside the app needs every pixel of the phone's screen.
    if (!widget.wide && media.viewInsets.bottom > 0 && !typingHere) {
      return const SizedBox.shrink();
    }

    if (widget.wide) {
      return Column(
        children: [
          if (widget.designOpen) _tabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: widget.designOpen ? _content() : _guide(),
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: WebTheme.surface,
        border: Border(top: BorderSide(color: WebTheme.iconLightGrey)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabs(),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: media.size.height * .3),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                child: _content(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Row(children: [
        for (final tab in _DockTab.values)
          Expanded(
            child: _TabButton(
              tab: tab,
              selected: tab == _tab,
              onTap: () => _selectTab(tab),
            ),
          ),
        if (StudioDesign.isCustom)
          IconButton(
            tooltip: 'Clear your design'.tr,
            onPressed: _clearDesign,
            icon: const Icon(Icons.restart_alt_rounded,
                color: WebTheme.statOrange, size: 22),
          ),
      ]),
    );
  }

  Widget _content() {
    switch (_tab) {
      case _DockTab.colors:
        return _colors();
      case _DockTab.text:
        return _text();
      case _DockTab.identity:
        return _identity();
    }
  }

  /// A row that scrolls sideways on a phone and wraps on a computer.
  Widget _strip(List<Widget> children) {
    if (widget.wide) {
      return Wrap(spacing: 10, runSpacing: 10, children: children);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: child,
          ),
      ]),
    );
  }

  // --- Scenario ---------------------------------------------------------------

  Widget _guide() {
    final scenario = widget.scenario;
    if (scenario.exploring) {
      return Text(
          'You are exploring a large sample company. Use the menu to start the scenario again.'
              .tr,
          style: WebTheme.font(
              color: WebTheme.textSecondary,
              fontSize: WebTheme.textBody,
              height: 1.5));
    }

    final step = scenario.step;
    final done = step == StudioStep.finished;
    final action = step.action;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: step.isIntro ? 0 : (step.number - 1) / StudioStep.total,
            minHeight: 5,
            color: WebTheme.accent,
            backgroundColor: WebTheme.iconLightGrey,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey(step),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      done ? WebTheme.statGreen : WebTheme.primary,
                  child: done
                      ? const Icon(Icons.check_rounded,
                          color: WebTheme.onPrimary, size: 16)
                      : Text(step.isIntro ? '★' : '${step.number}',
                          style: WebTheme.font(
                              color: WebTheme.onPrimary,
                              fontSize: WebTheme.textSmall,
                              fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!done)
                        Text(
                            (step.technician ? 'Technician' : 'Admin').tr,
                            style: WebTheme.font(
                                color: WebTheme.accentText,
                                fontSize: WebTheme.textCaption,
                                fontWeight: FontWeight.w800)),
                      Text(step.title,
                          style: WebTheme.font(
                              color: WebTheme.textPrimary,
                              fontSize: WebTheme.textSubtitle,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                if (action != null)
                  FilledButton(
                    onPressed: scenario.busy
                        ? null
                        : done
                            ? widget.onOffer
                            : scenario.runAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: WebTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(action.tr,
                        style: WebTheme.font(
                            color: WebTheme.onPrimary,
                            fontSize: WebTheme.textBody,
                            fontWeight: FontWeight.w800)),
                  ),
              ]),
              const SizedBox(height: 6),
              Text(step.hint,
                  style: WebTheme.font(
                      color: WebTheme.textSecondary,
                      fontSize: WebTheme.textBody,
                      height: 1.45)),
            ],
          ),
        ),
        if (widget.wide) ...[
          const SizedBox(height: 18),
          for (final item in StudioStep.values)
            if (item != StudioStep.finished && !item.isIntro)
              _stepLine(item, step),
        ],
      ],
    );
  }

  Widget _stepLine(StudioStep item, StudioStep current) {
    final done = item.index < current.index;
    final active = item == current;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Icon(
            done
                ? Icons.check_circle_rounded
                : active
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
            color: done
                ? WebTheme.statGreen
                : active
                    ? WebTheme.primary
                    : WebTheme.iconLightGrey,
            size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(item.title,
              style: WebTheme.font(
                  color: active ? WebTheme.textPrimary : WebTheme.textSecondary,
                  fontSize: WebTheme.textBodyLarge,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
        ),
      ]),
    );
  }

  // --- Colors -----------------------------------------------------------------

  Widget _colors() {
    final primary = StudioDesign.colorOf(AppBrandColor.primary);
    final secondary = StudioDesign.colorOf(AppBrandColor.secondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _strip([
          _RoundTile(
            tooltip: AppTheme.isDark ? 'Light'.tr : 'Dark'.tr,
            selected: false,
            onTap: () {
              AppTheme.darkMode.value = !AppTheme.isDark;
              _redraw();
            },
            child: Icon(
                AppTheme.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: WebTheme.textPrimary),
          ),
          _RoundTile(
            tooltip: 'Any color you want'.tr,
            selected: _custom,
            gradient: const SweepGradient(colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ]),
            onTap: () => setState(() {
              _custom = !_custom;
              _selectSlot(_slot);
            }),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
          for (final preset in AppBrand.presets)
            _RoundTile(
              tooltip: preset.name.tr,
              selected:
                  preset.primary == primary && preset.secondary == secondary,
              gradient:
                  LinearGradient(colors: [preset.primary, preset.secondary]),
              onTap: () => _set(_brand
                  .withColor(AppBrandColor.primary, preset.primary)
                  .withColor(AppBrandColor.secondary, preset.secondary)),
            ),
        ]),
        if (_custom) ...[
          const SizedBox(height: 10),
          _strip([
            for (final slot in AppBrandColor.values)
              _SlotChip(
                slot: slot,
                color: StudioDesign.colorOf(slot),
                selected: slot == _slot,
                onTap: () => _selectSlot(slot),
              ),
          ]),
          const SizedBox(height: 8),
          // The sliders are drawn left to right in both languages.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(children: [
              SizedBox(
                height: 34,
                child: ColorPickerSlider(TrackType.hue, _hsv, _applySlider,
                    displayThumbColor: true),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: ColorPickerSlider(
                    TrackType.lightness, _hsv, _applySlider,
                    displayThumbColor: true),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(
              width: 112,
              height: 40,
              child: TextField(
                controller: _hex,
                focusNode: _hexFocus,
                maxLength: 7,
                textDirection: TextDirection.ltr,
                onChanged: _applyHex,
                style: WebTheme.font(
                    color: WebTheme.textPrimary, fontSize: WebTheme.textBody),
                decoration: _fieldDecoration(null),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_slot.hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WebTheme.font(
                      color: WebTheme.textSecondary,
                      fontSize: WebTheme.textSmall)),
            ),
            if (_brand[_slot] != null)
              IconButton(
                tooltip: 'Back to default'.tr,
                onPressed: _resetSlot,
                icon: const Icon(Icons.undo_rounded,
                    color: WebTheme.textSecondary, size: 20),
              ),
          ]),
        ],
      ],
    );
  }

  InputDecoration _fieldDecoration(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: WebTheme.font(
            color: WebTheme.textLightHint, fontSize: WebTheme.textBody),
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: WebTheme.searchFieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: WebTheme.iconLightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: WebTheme.iconLightGrey)),
      );

  // --- Text -------------------------------------------------------------------

  Widget _text() {
    final arabic = AppLanguage.isArabic;
    final fonts = arabic ? AppBrand.arabicFonts : AppBrand.englishFonts;
    final selected = arabic
        ? _brand.fontArabic ?? AppTheme.fontFamilyArabic
        : _brand.fontEnglish ?? AppTheme.fontFamily;
    final sample = arabic ? 'زيارة' : 'Visit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _strip([
          for (final font in fonts)
            _Chip(
              selected: font == selected,
              onTap: () => _set(arabic
                  ? _brand.copyWith(fontArabic: font)
                  : _brand.copyWith(fontEnglish: font)),
              child: Text('$sample · $font',
                  style: GoogleFonts.getFont(font,
                      color: WebTheme.textPrimary, fontSize: 14)),
            ),
        ]),
        Row(children: [
          const Icon(Icons.text_decrease_rounded,
              color: WebTheme.textSecondary, size: 20),
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
          const Icon(Icons.text_increase_rounded,
              color: WebTheme.textSecondary, size: 20),
        ]),
      ],
    );
  }

  // --- Name, icon and logo ----------------------------------------------------

  Widget _identity() {
    final logo = _brand.logo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _name,
          focusNode: _nameFocus,
          maxLength: 30,
          style: WebTheme.font(
              color: WebTheme.textPrimary, fontSize: WebTheme.textBodyLarge),
          decoration: _fieldDecoration('Your company or app name'.tr),
          onChanged: (value) => value.trim().isEmpty
              ? _set(_brand.copyWith(clearName: true))
              : _set(_brand.copyWith(appName: value)),
        ),
        const SizedBox(height: 10),
        _strip([
          _RoundTile(
            tooltip: logo == null ? 'Upload your logo'.tr : 'Remove logo'.tr,
            selected: logo != null,
            onTap: logo == null
                ? _pickLogo
                : () => _set(_brand.copyWith(clearLogo: true)),
            child: logo == null
                ? const Icon(Icons.upload_rounded, color: WebTheme.primary)
                : ClipOval(
                    child: Image.memory(logo,
                        width: 44, height: 44, fit: BoxFit.cover)),
          ),
          for (final icon in AppBrand.icons)
            _RoundTile(
              tooltip: icon.label.tr,
              selected: logo == null && _brand.iconKey == icon.key,
              onTap: () =>
                  _set(_brand.copyWith(iconKey: icon.key, clearLogo: true)),
              child: Icon(icon.icon, color: WebTheme.textPrimary),
            ),
        ]),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.tab, required this.selected, required this.onTap});
  final _DockTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? WebTheme.onPrimary : WebTheme.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? WebTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: [
              Icon(tab.icon, color: color, size: 18),
              const SizedBox(height: 2),
              Text(tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WebTheme.font(
                      color: color,
                      fontSize: WebTheme.textCaption,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A one-tap round choice: a theme, an icon or the logo.
class _RoundTile extends StatelessWidget {
  const _RoundTile({
    required this.tooltip,
    required this.selected,
    required this.onTap,
    this.gradient,
    this.child,
  });
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: selected ? WebTheme.primary : Colors.transparent,
                width: 2),
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gradient == null ? WebTheme.locationChipBg : null,
              gradient: gradient,
            ),
            child: child ??
                (selected
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.onTap,
    required this.child,
  });
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: WebTheme.locationChipBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: selected ? WebTheme.primary : Colors.transparent,
              width: 2),
        ),
        child: child,
      ),
    );
  }
}

/// One themed part of the app, with its current color.
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final AppBrandColor slot;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      selected: selected,
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: WebTheme.iconLightGrey),
          ),
        ),
        const SizedBox(width: 6),
        Text(slot.label,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: WebTheme.textSmall,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
