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
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28))),
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
          if (AppTheme.darkModeEnabled) const _DarkModeSwitch(),
        ],
      ),
    );
  }
}

/// Turns dark mode on or off. The app saves the choice and restyles itself.
class _DarkModeSwitch extends StatelessWidget {
  const _DarkModeSwitch();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppTheme.iconLightGrey.withValues(alpha: .4)),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: AppTheme.darkMode,
          builder: (context, dark, _) => Row(
            children: [
              Icon(dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: dark ? AppTheme.primary : AppTheme.pending, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Dark mode',
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(28)),
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
                Text('Visit Proof',
                    style: AppTheme.font(
                        color: AppTheme.onPrimary,
                        fontSize: AppTheme.textHeadline,
                        fontWeight: FontWeight.w800)),
                Text('Admin',
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
