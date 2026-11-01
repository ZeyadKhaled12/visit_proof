import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import 'main_menu_tabs.dart';

/// The app menu: opened from the menu button at the top of every section.
class MainMenuWidgetDrawer extends StatelessWidget {
  const MainMenuWidgetDrawer(
      {super.key, required this.current, required this.onSelect});
  final MainMenuTab current;
  final ValueChanged<MainMenuTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadiusDirectional.horizontal(end: Radius.circular(28))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                for (final group in MainMenuGroup.values) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                    child: Text(group.label.toUpperCase(),
                        style: AppTheme.font(
                            color: AppTheme.textLightHint,
                            fontSize: AppTheme.textCaption,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1)),
                  ),
                  for (final tab
                      in MainMenuTab.values.where((t) => t.group == group))
                    _Item(
                      tab: tab,
                      selected: tab == current,
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(tab);
                      },
                    ),
                ],
              ],
            ),
          ),
          const _Footer(),
        ],
      ),
    );
  }
}

/// Preferences and account actions pinned to the bottom of the menu.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    const showLanguage = AppLanguage.languageSwitchEnabled;
    final showDarkMode = AppTheme.darkModeEnabled;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLanguage || showDarkMode)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.iconLightGrey.withValues(alpha: .4)),
                ),
                child: Column(
                  children: [
                    if (showLanguage) const _LanguageRow(),
                    if (showLanguage && showDarkMode)
                      Divider(
                          height: 12,
                          color: AppTheme.iconLightGrey.withValues(alpha: .3)),
                    if (showDarkMode) const _DarkModeRow(),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const _LogoutButton(),
          ],
        ),
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
            Icon(Icons.translate_rounded, color: AppTheme.secondary, size: 22),
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

/// Log out, UI only for now: asks for confirmation, then closes the menu.
/// Hook the real sign-out in here once user accounts exist.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.logout_rounded, color: AppTheme.statOrange, size: 30),
        title: Text('Log out?'.tr,
            textAlign: TextAlign.center,
            style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textTitleLarge,
                fontWeight: FontWeight.w800)),
        content: Text('You will need to sign in again to use the app.'.tr,
            textAlign: TextAlign.center,
            style: AppTheme.font(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.textBodyLarge,
                height: 1.4)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'.tr,
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.statOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Log out'.tr,
                style: AppTheme.font(
                    color: AppTheme.onPrimary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.statOrange.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _confirm(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.statOrange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Log out'.tr,
                    style: AppTheme.font(
                        color: AppTheme.statOrange,
                        fontSize: AppTheme.textBodyLarge,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.paddingOf(context).top + 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd),
        borderRadius:
            const BorderRadiusDirectional.only(bottomEnd: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.onPrimary.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.verified_rounded,
                color: AppTheme.onPrimary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visit Proof'.tr,
                    style: AppTheme.font(
                        color: AppTheme.onPrimary,
                        fontSize: AppTheme.textHeadline,
                        fontWeight: FontWeight.w800)),
                Text('Admin'.tr,
                    style: AppTheme.font(
                        color: AppTheme.onPrimary.withValues(alpha: .85),
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.tab, required this.selected, required this.onTap});
  final MainMenuTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? AppTheme.primary.withValues(alpha: .10)
            : AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(selected ? tab.selectedIcon : tab.icon,
                      size: 20,
                      color: selected
                          ? AppTheme.onPrimary
                          : AppTheme.iconGrey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tab.label,
                          style: AppTheme.font(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontSize: AppTheme.textBodyLarge,
                              fontWeight: FontWeight.w800)),
                      Text(tab.hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
