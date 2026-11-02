import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

/// The leading button of a screen's top bar: opens the app drawer when the
/// screen sits inside the app menu, or goes back when the screen was opened
/// on top of another one. Screens have their own Scaffold, so this looks up
/// past it for the nearest Scaffold that has a drawer.
class GWidgetMenuButton extends StatelessWidget {
  const GWidgetMenuButton({super.key});

  static ScaffoldState? _drawerScaffold(BuildContext context) {
    var scaffold = context.findAncestorStateOfType<ScaffoldState>();
    while (scaffold != null) {
      if (scaffold.hasDrawer) return scaffold;
      scaffold = scaffold.context.findAncestorStateOfType<ScaffoldState>();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = _drawerScaffold(context);
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;

    // A pushed screen goes back; a menu screen opens the drawer.
    if (canGoBack && scaffold == null) {
      return _button(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.maybePop(context),
      );
    }
    if (scaffold == null) return const SizedBox.shrink();
    return _button(icon: Icons.menu_rounded, onTap: scaffold.openDrawer);
  }

  Widget _button({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.iconLightGrey.withValues(alpha: .4)),
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}
