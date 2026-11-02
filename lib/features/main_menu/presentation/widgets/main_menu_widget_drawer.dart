import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_widgets/g_widget_app_settings.dart';
import '../../../auth/presentation/widgets/auth_widget_account_actions.dart';
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (GWidgetAppSettings.hasAny) ...[
              const GWidgetAppSettings(),
              const SizedBox(height: 8),
            ],
            const AuthWidgetAccountActions(),
          ],
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
